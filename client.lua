if not lib.checkDependency('ox_lib', '3.14.0') then print('Update ox_lib to v3.14.0 or newer!') return end

local Utils = require 'modules.utils'
local Vehicle = require 'modules.class.vehicle'
local Settings = lib.load('data.vehicle')

local fuelscript = Utils.Detect.Fuel()
local speedunit = Settings.units == 'mph' and 2.23694 or 3.6
local listening = false

local function startThreads()
    listening = true
    local vehEntity = Vehicle:getEntity()
    local vehClass = Vehicle:getClass()
    local airborne, torqueReduction = false, false
    local speedBuffer, healthBuffer, bodyBuffer, roll = {0.0,0.0}, {0.0,0.0}, {0.0,0.0}, 0.0

    function startTorqueReduction()
        torqueReduction = true
        CreateThread(function()

            while Vehicle:getSeat() == -1 do

                -- Update vehicle torque
                if healthBuffer[1] < 500 then
                    local newtorque = (healthBuffer[1] + 500) / 1100
                    SetVehicleCheatPowerIncrease(vehEntity, newtorque)
                else
                    torqueReduction = false
                    break
                end

                Wait(1)
            end

            torqueReduction = false
        end)
    end

    CreateThread(function()
        while Vehicle:getSeat() == -1 do
            if Vehicle:getEntity() ~= vehEntity then
                vehEntity = Vehicle:getEntity()
            end

            bodyBuffer[1] = GetVehicleBodyHealth(vehEntity)
            healthBuffer[1] = GetVehicleEngineHealth(vehEntity)
            speedBuffer[1] = GetEntitySpeed(vehEntity) * speedunit

            -- Driveability handler (health, fuel)
            local fuelLevel = GetVehicleFuelLevel(vehEntity)
            if healthBuffer[1] <= 0 or fuelLevel <= 6.4 then
                if IsVehicleDriveable(vehEntity, true) then
                    SetVehicleUndriveable(vehEntity, true)
                end
            end

            -- Prevent rotation controls while flipped/airborne
            if Settings.regulated[vehClass] then
                if speedBuffer[1] < 2.0 then
                    if airborne then airborne = false end
                    roll = GetEntityRoll(vehEntity)
                else
                    airborne = IsEntityInAir(vehEntity)
                end

                if (roll > 75.0 or roll < -75.0) or airborne then
                    SetVehicleOutOfControl(vehEntity, false, false)
                end
            end

            -- Damage handler
            local bodyDiff = bodyBuffer[2] - bodyBuffer[1]
            if bodyDiff >= 1 then

                -- Calculate latest damage
                local bodyDamage = bodyDiff * Settings.globalmultiplier * Settings.classmultiplier[vehClass]
                local vehicleHealth = healthBuffer[1] - bodyDamage

                -- Engage torque reduction thread
                if vehicleHealth < 500 then
                    if not torqueReduction then
                        startTorqueReduction()
                    end
                end

                -- Update vehicle health
                if vehicleHealth ~= healthBuffer[1] and vehicleHealth > 0 then
                    SetVehicleEngineHealth(vehEntity, vehicleHealth)
                elseif vehicleHealth ~= 0 then
                    SetVehicleEngineHealth(vehEntity, 0.0) -- prevent negative engine health
                end

                -- Prevent negative body health
                if bodyBuffer[1] < 0 then
                    SetVehicleBodyHealth(vehEntity, 0.0)
                end

                -- Prevent negative tank health (explosion)
                if GetVehiclePetrolTankHealth(vehEntity) < 0 then
                    SetVehiclePetrolTankHealth(vehEntity, 0.0)
                end
            end

            -- Handle collision impact
            local speedDiff = speedBuffer[2] - speedBuffer[1]
            if speedDiff >= Settings.threshold.speed then

                -- Handle wheel loss
                if bodyDiff >= Settings.threshold.health then
                    local chance = math.random(0,1)
                    BreakOffVehicleWheel(vehEntity, chance, true, false, true, false)
                end

                -- Handle heavy impact
                if speedDiff >= Settings.threshold.heavy then
                    SetVehicleUndriveable(vehEntity, true)
                    SetVehicleEngineHealth(vehEntity, 0.0) -- Disable vehicle completely
                end
            end

            -- Store data for next cycle
            bodyBuffer[2] = bodyBuffer[1]
            healthBuffer[2] = healthBuffer[1]
            speedBuffer[2] = speedBuffer[1]

            Wait(100)
        end

        listening, airborne, torqueReduction = false, false, false
        speedBuffer, healthBuffer, bodyBuffer, roll = {0.0,0.0}, {0.0,0.0}, {0.0,0.0}, 0.0
    end)
end

lib.onCache('vehicle', function(newVeh)
    Vehicle:setEntity(newVeh)
end)

lib.onCache('seat', function(newSeat)
	Vehicle:updateData(newSeat, seated)
    if Utils.Player.Seated(newSeat) and newSeat == -1 then
        if not listening then
            startThreads()
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    local veh, seat = Utils.Player.Data()

    Vehicle = Vehicle:new({
        ref = veh,
        class = veh and GetVehicleClass(veh) or false,
        seat = seat,
        active = Utils.Player.Seated(seat)
    })

    startThreads()
end)

RegisterNetEvent('vehiclehandler:playerlogout', function()
    Vehicle:resetData()
end)

RegisterNetEvent('vehiclehandler:client:adminfix', function()
    if not cache.ped then return end
    if Vehicle:isActive() or IsPedInAnyPlane(cache.ped) then
        Utils.Vehicle.Repair(Vehicle:getEntity(), fuelscript)
    end
end)

-- Items
if GetResourceState('ox_inventory') == 'started' then
    -- Cleaning
    local function CleanVehicle(veh)
        if lib.progressCircle({
            duration = math.random(10000, 20000),
            position = 'middle',
            label = 'Cleaning the vehicle',
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = false,
                mouse = false,
            },
            anim = {
                scenario = 'WORLD_HUMAN_MAID_CLEAN',
            },
        }) then
            lib.notify({
                description = 'Vehicle cleaned!',
                position = 'top-right',
                icon = 'soap',
                type = 'success',
            })
            SetVehicleDirtLevel(veh, 0.1)
            SetVehicleUndriveable(veh, false)
            WashDecalsFromVehicle(veh, 1.0)
            TriggerServerEvent('vehiclehandler:server:removewashingkit', veh)
        else
            lib.notify({
                description = 'Cleaning aborted!',
                position = 'top-right',
                icon = 'soap',
                type = 'error',
            })
        end
    end

    RegisterNetEvent('vehiclehandler:client:SyncWash', function(veh)
        SetVehicleDirtLevel(veh, 0.1)
        SetVehicleUndriveable(veh, false)
        WashDecalsFromVehicle(veh, 1.0)
    end)

    RegisterNetEvent('vehiclehandler:client:CleanVehicle', function()
        if not cache.ped then return end
        local pos = GetEntityCoords(cache.ped)
        local veh = lib.getClosestVehicle(pos, 3.0, true)
        if veh ~= nil and veh ~= 0 then
            local vehpos = GetEntityCoords(veh)
            if #(pos - vehpos) < 3.0 and not IsPedInAnyVehicle(cache.ped, false) then
                CleanVehicle(veh)
            end
        else
            lib.notify({
                description = 'You are not near a vehicle!',
                position = 'top-right',
                icon = 'toolbox',
                type = 'error',
            })
        end
    end)

    -- Repairkits
    BackEngineVehicles = {
        [`ninef`] = true,
        [`adder`] = true,
        [`vagner`] = true,
        [`t20`] = true,
        [`infernus`] = true,
        [`zentorno`] = true,
        [`reaper`] = true,
        [`comet2`] = true,
        [`jester`] = true,
        [`jester2`] = true,
        [`cheetah`] = true,
        [`cheetah2`] = true,
        [`prototipo`] = true,
        [`turismor`] = true,
        [`pfister811`] = true,
        [`ardent`] = true,
        [`nero`] = true,
        [`nero2`] = true,
        [`tempesta`] = true,
        [`vacca`] = true,
        [`bullet`] = true,
        [`osiris`] = true,
        [`entityxf`] = true,
        [`turismo2`] = true,
        [`fmj`] = true,
        [`re7b`] = true,
        [`tyrus`] = true,
        [`italigtb`] = true,
        [`penetrator`] = true,
        [`monroe`] = true,
        [`ninef2`] = true,
        [`stingergt`] = true,
        [`surfer`] = true,
        [`surfer2`] = true,
        [`comet3`] = true,
    }

    local function IsBackEngine(vehModel)
        if BackEngineVehicles[vehModel] then return true else return false end
    end

    local function RepairVehicle(veh)
        local backEngine = IsBackEngine(GetEntityModel(veh))
        local doorIndex = backEngine and 5 or 4

        SetVehicleDoorOpen(veh, doorIndex, false, false)
        TaskPlayAnim(cache.ped, 'mini@repair', 'fixing_a_player', 8.0, 8.0, -1, 1, 0, false, false, false) -- This might be changed

        local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'hard'}, {'w', 'a', 's', 'd'})
        if success then
            TriggerServerEvent('vehiclehandler:removeItem', "repairkit")
            lib.notify({
                description = 'Vehicle repaired!',
                position = 'top-right',
                icon = 'toolbox',
                type = 'success',
            })
            SetVehicleUndriveable(veh, false)
            SetVehicleEngineHealth(veh, 500.0)
            for i = 0, 5 do
                SetVehicleTyreFixed(veh, i)
                SetVehicleWheelHealth(veh, i, 1000.0)
            end
            SetVehicleEngineOn(veh, true, false, false)
            SetVehicleDoorShut(veh, doorIndex, false)
            ClearPedTasks(cache.ped) -- This might be changed
        else
            ClearPedTasks(cache.ped) -- This might be changed
            lib.notify({
                description = 'You have failed!',
                position = 'top-right',
                icon = 'toolbox',
                type = 'error',
            })
            SetVehicleDoorShut(veh, doorIndex, false)
        end
    end

    local function RepairVehicleFull(veh)
        local backEngine = IsBackEngine(GetEntityModel(veh))
        local doorIndex = backEngine and 5 or 4

        SetVehicleDoorOpen(veh, doorIndex, false, false)
        TaskPlayAnim(cache.ped, 'mini@repair', 'fixing_a_player', 8.0, 8.0, -1, 1, 0, false, false, false) -- This might be changed

        local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'hard'}, {'w', 'a', 's', 'd'})
        if success then
            TriggerServerEvent('vehiclehandler:removeItem', "advancedrepairkit")
            lib.notify({
                description = 'Vehicle repaired!',
                position = 'top-right',
                icon = 'toolbox',
                type = 'success',
            })
            SetVehicleUndriveable(veh, false)
            SetVehicleEngineHealth(veh, 1000.0)
            SetVehiclePetrolTankHealth(veh, 1000.0)
            SetVehicleBodyHealth(veh, 1000.0)
            ResetVehicleWheels(veh, true)
            for i = 0, 5 do
                SetVehicleTyreFixed(veh, i)
                SetVehicleWheelHealth(veh, i, 1000.0)
            end
            SetVehicleFixed(veh)
            SetVehicleEngineOn(veh, true, false, false)
            SetVehicleDoorShut(veh, doorIndex, false)
            ClearPedTasks(cache.ped) -- This might be changed
        else
            ClearPedTasks(cache.ped) -- This might be changed
            lib.notify({
                description = 'You have failed!',
                position = 'top-right',
                icon = 'toolbox',
                type = 'error',
            })
            SetVehicleDoorShut(veh, doorIndex, false)
        end
    end

    RegisterNetEvent('vehiclehandler:client:RepairVehicle', function()
        if not cache.ped then return end
        local pos = GetEntityCoords(cache.ped)
        local veh = lib.getClosestVehicle(pos, 10.0, true)
        local engineHealth = GetVehicleEngineHealth(veh)
        if veh ~= nil and veh ~= 0 and engineHealth > -1.0 then -- Check if vehicle is destroyed
            if veh ~= nil and veh ~= 0 and engineHealth < 500 then
                local vehpos = GetEntityCoords(veh)
                if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(cache.ped, false) then
                    local drawpos = GetOffsetFromEntityInWorldCoords(veh, 0, 2.5, 0)
                    if (IsBackEngine(GetEntityModel(veh))) then
                        drawpos = GetOffsetFromEntityInWorldCoords(veh, 0, -2.5, 0)
                    end
                    if #(pos - drawpos) < 2.0 and not IsPedInAnyVehicle(cache.ped, false) then
                        RepairVehicle(veh)
                    end
                else
                    if #(pos - vehpos) > 4.9 then
                        lib.notify({
                            description = 'You are too far from the vehicle!',
                            position = 'top-right',
                            icon = 'toolbox',
                            type = 'error',
                        })
                    else
                        lib.notify({
                            description = 'The vehicle\'s engine cannot be repaired from the interior!',
                            position = 'top-right',
                            icon = 'toolbox',
                            type = 'error',
                        })
                    end
                end
            else
                if veh == nil or veh == 0 then
                    lib.notify({
                        description = 'You are not near a vehicle!',
                        position = 'top-right',
                        icon = 'toolbox',
                        type = 'error',
                    })
                else
                    lib.notify({
                        description = 'The vehicle is fine and needs better tools!',
                        position = 'top-right',
                        icon = 'toolbox',
                        type = 'error',
                    })
                end
            end
        else
            lib.notify({
                description = 'This vehicle is destroyed and cannot be repaired',
                position = 'top-right',
                icon = 'toolbox',
                type = 'error',
            })
        end
    end)

    RegisterNetEvent('vehiclehandler:client:RepairVehicleFull', function()
        if not cache.ped then return end
        local pos = GetEntityCoords(cache.ped)
        local veh = lib.getClosestVehicle(pos, 10.0, true)
        local engineHealth = GetVehicleEngineHealth(veh)
        if veh ~= nil and veh ~= 0 and engineHealth > -1.0 then -- Check if vehicle is destroyed
            if veh ~= nil and veh ~= 0 then
                local vehpos = GetEntityCoords(veh)
                if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(cache.ped, false) then
                    local drawpos = GetOffsetFromEntityInWorldCoords(veh, 0, 2.5, 0)
                    if (IsBackEngine(GetEntityModel(veh))) then
                        drawpos = GetOffsetFromEntityInWorldCoords(veh, 0, -2.5, 0)
                    end
                    if #(pos - drawpos) < 2.0 and not IsPedInAnyVehicle(cache.ped, false) then
                        RepairVehicleFull(veh)
                    end
                else
                    if #(pos - vehpos) > 4.9 then
                        lib.notify({
                            description = 'You are too far from the vehicle!',
                            position = 'top-right',
                            icon = 'toolbox',
                            type = 'error',
                        })
                    else
                        lib.notify({
                            description = 'The vehicle\'s engine cannot be repaired from the interior!',
                            position = 'top-right',
                            icon = 'toolbox',
                            type = 'error',
                        })
                    end
                end
            else
                lib.notify({
                    description = 'You are not near a vehicle!',
                    position = 'top-right',
                    icon = 'toolbox',
                    type = 'error',
                })
            end
        else
            lib.notify({
                description = 'This vehicle is destroyed and cannot be repaired',
                position = 'top-right',
                icon = 'toolbox',
                type = 'error',
            })
        end
    end)
end