local ox_lib, msg_lib = lib.checkDependency('ox_lib', '3.24.0')
if not ox_lib then print(msg_lib) return end

if GetResourceState('ox_inventory') == 'started' then
    local ox_inv, msg_inv = lib.checkDependency('ox_inventory', '2.41.0')
    if not ox_inv then print(msg_inv) return end
end

---@class Handler : OxClass
local Handler = require 'modules.handler'
local Settings = lib.load('data.vehicle')

local function startThread(vehicle)
    if not vehicle then return end
    if not Handler or Handler:isActive() then return end

    Handler:setActive(true)

    local oxfuel = Handler:isFuelOx()
    local units = Handler:getUnits()
    local class = GetVehicleClass(vehicle) or false
    local speedBuffer, healthBuffer, bodyBuffer, roll, airborne = {0.0,0.0}, {0.0,0.0}, {0.0,0.0}, 0.0, false

    CreateThread(function()
        while (cache.vehicle == vehicle) and (Handler:getSeat() == -1) do

            -- Retrieve latest vehicle data
            bodyBuffer[1] = GetVehicleBodyHealth(vehicle)
            healthBuffer[1] = GetVehicleEngineHealth(vehicle)
            speedBuffer[1] = GetEntitySpeed(vehicle) * units

            -- Driveability handler (health, fuel)
            local fuelLevel = oxfuel and Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
            if healthBuffer[1] <= 0 or fuelLevel <= 6.4 then
                if IsVehicleDriveable(vehicle, true) then
                    SetVehicleUndriveable(vehicle, true)
                end
            end

            -- Reduce torque after half-life
            if not Handler:isLimited() then
                if healthBuffer[1] < 500 then
                    Handler:setLimited(true)

                    CreateThread(function()
                        while (cache.vehicle == vehicle) and (Handler:getSeat() == -1) and (healthBuffer[1] < 500) do
                            local newtorque = (healthBuffer[1] + 500) / 1100
                            SetVehicleCheatPowerIncrease(vehicle, newtorque)
                            Wait(1)
                        end

                        Handler:setLimited(false)
                    end)
                end
            end

            -- Prevent rotation controls while flipped/airborne
            if Settings.regulated[class] then
                if speedBuffer[1] < 2.0 then
                    if airborne then airborne = false end
                    roll = GetEntityRoll(vehicle)
                else
                    airborne = IsEntityInAir(vehicle)
                end

                if (roll > 75.0 or roll < -75.0) or airborne then
                    if Handler:canControl() then
                        Handler:setControl(false)

                        CreateThread(function()
                            while not Handler:canControl() and Handler:getSeat() == -1 do
                                DisableControlAction(2, 59, true) -- Disable left/right
                                DisableControlAction(2, 60, true) -- Disable up/down
                                Wait(1)
                            end

                            if not Handler:canControl() then Handler:setControl(true) end
                        end)
                    end
                else
                    if not Handler:canControl() then
                        Handler:setControl(true)
                    end
                end
            end

            -- Damage handler
            local bodyDiff = bodyBuffer[2] - bodyBuffer[1]
            if bodyDiff >= 1 then

                -- Calculate latest damage
                local bodyDamage = bodyDiff * Settings.globalmultiplier * Settings.classmultiplier[class]
                local vehicleHealth = healthBuffer[1] - bodyDamage

                -- Update engine health
                if vehicleHealth ~= healthBuffer[1] and vehicleHealth > 0 then
                    SetVehicleEngineHealth(vehicle, vehicleHealth)
                elseif vehicleHealth ~= 0 then
                    SetVehicleEngineHealth(vehicle, 0.0) -- prevent negative engine health
                end

                -- Prevent negative body health
                if bodyBuffer[1] < 0 then
                    SetVehicleBodyHealth(vehicle, 0.0)
                end

                -- Prevent negative tank health (explosion)
                if GetVehiclePetrolTankHealth(vehicle) < 0 then
                    SetVehiclePetrolTankHealth(vehicle, 0.0)
                end
            end

            -- Impact handler
            local speedDiff = speedBuffer[2] - speedBuffer[1]
            if speedDiff >= Settings.threshold.speed then

                -- Handle wheel loss
                if Settings.breaktire then
                    if bodyDiff >= Settings.threshold.tire then
                        math.randomseed(GetGameTimer())
                        Handler:breakTire(vehicle, math.random(0, 1))
                    end
                end

                -- Handle heavy impact
                if speedDiff >= Settings.threshold.heavy then
                    SetVehicleUndriveable(vehicle, true)
                    SetVehicleEngineHealth(vehicle, 0.0) -- Disable vehicle completely
                end
            end

            -- Store data for next cycle
            bodyBuffer[2] = bodyBuffer[1]
            healthBuffer[2] = healthBuffer[1]
            speedBuffer[2] = speedBuffer[1]

            Wait(100)
        end

        Handler:setActive(false)

        -- Retrigger thread if admin spawns a new vehicle while in one
        if cache.vehicle and cache.seat == -1 then
            if Handler:isLimited() then Handler:setLimited(false) end
            startThread(cache.vehicle)
        end
    end)
end

lib.onCache('seat', function(seat)
    Handler:setSeat(seat)

    if seat == -1 then
        startThread(cache.vehicle)
    end
end)

lib.callback.register('vehiclehandler:basicfix', function(fixtype)
    if not Handler then return end
    return Handler:basicfix(fixtype)
end)

lib.callback.register('vehiclehandler:basicwash', function()
    if not Handler then return end
    return Handler:basicwash()
end)

lib.callback.register('vehiclehandler:adminfix', function()
    if not Handler or not Handler:isActive() then return end
    return Handler:adminfix()
end)

lib.callback.register('vehiclehandler:adminwash', function()
    if not Handler or not Handler:isActive() then return end
    return Handler:adminwash()
end)

lib.callback.register('vehiclehandler:adminfuel', function(newlevel)
    if not Handler or not Handler:isActive() then return end
    return Handler:adminfuel(newlevel)
end)

CreateThread(function()
    Handler = Handler:new(cache.seat)
    if cache.seat == -1 then
        startThread(cache.vehicle)
    end
end)