if not lib then print('^1ox_lib must be started before this resource.^0') return end
lib.locale()

---@class Handler : OxClass
local Handler = require 'modules.handler'
local Settings = lib.load('data.vehicle')
local Units = Settings.units == 'mph' and 2.23694 or 3.6

local function startThread(vehicle)
    if not vehicle then return end
    if not Handler or Handler:isActive() then return end

    Handler:setActive(true)

    local oxfuel = Handler:isFuelOx()
    local class = Handler:getClass()

    CreateThread(function()
        while (cache.vehicle == vehicle) and (cache.seat == -1) do

            -- Retrieve latest vehicle data
            local engine, body, speed = Handler:setData({
                ['engine'] = GetVehicleEngineHealth(vehicle),
                ['body'] = GetVehicleBodyHealth(vehicle),
                ['speed'] = GetEntitySpeed(vehicle) * Units
            })

            -- Prevent negative engine health & driveability handler (engine)
            if engine <= 0 then
                if engine < 0 then
                    SetVehicleEngineHealth(cache.vehicle, 0.0)
                end

                if IsVehicleDriveable(vehicle, true) then
                    SetVehicleUndriveable(vehicle, true)
                end
            end

            -- Prevent negative body health
            if body < 0 then
                SetVehicleBodyHealth(cache.vehicle, 0.0)
            end

            -- Driveability handler (fuel)
            if not Handler:isElectric() then
                local fuel = oxfuel and Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)

                if fuel <= 7 then
                    if IsVehicleDriveable(vehicle, true) then
                        SetVehicleUndriveable(vehicle, true)
                    end
                end
            end

            -- Reduce torque after half-life
            if engine < 500 then
                if not Handler:isLimited() then
                    Handler:setLimited(true)

                    CreateThread(function()
                        while (cache.vehicle == vehicle) and (cache.seat == -1) and (Handler:getData('engine') < 500) do
                            local newtorque = (Handler:getData('engine') + 500) / 1100
                            SetVehicleCheatPowerIncrease(vehicle, newtorque)
                            Wait(1)
                        end

                        Handler:setLimited(false)
                    end)
                end
            end

            -- Prevent rotation controls while flipped/airborne
            if Settings.regulated[class] and not Settings.regulated_exclusions[GetEntityModel(vehicle)] then
                local roll, airborne = 0.0, false

                if speed < 2.0 then
                    roll = GetEntityRoll(vehicle)
                else
                    airborne = IsEntityInAir(vehicle)
                end

                if (roll > 75.0 or roll < -75.0) or airborne then
                    if Handler:canControl() then
                        Handler:setControl(false)

                        CreateThread(function()
                            while not Handler:canControl() and cache.seat == -1 do
                                DisableControlAction(2, 59, true) -- Disable left/right
                                DisableControlAction(2, 60, true) -- Disable up/down
                                Wait(1)
                            end

                            if not Handler:canControl() then Handler:setControl(true) end
                        end)
                    end
                else
                    if not Handler:canControl() then Handler:setControl(true) end
                end
            end

            Wait(300)
        end

        Handler:setActive(false)

        -- Retrigger thread if admin spawns a new vehicle while in one
        if cache.vehicle and cache.seat == -1 then
            startThread(cache.vehicle)
        end
    end)
end

AddEventHandler('entityDamaged', function (victim, _, weapon, _)
    if not Handler or not Handler:isActive() then return end
    if victim ~= cache.vehicle then return end
    if GetWeapontypeGroup(weapon) ~= 0 then return end

    -- Damage handler
    local bodyDiff = Handler:getData('body') - GetVehicleBodyHealth(cache.vehicle)
    if bodyDiff > 0 then

        -- Calculate latest damage
        local bodyDamage = bodyDiff * Settings.globalmultiplier * Settings.classmultiplier[Handler:getClass()]
        local newEngine = GetVehicleEngineHealth(cache.vehicle) - bodyDamage

        -- Update engine health
        if newEngine > 0 and newEngine ~= Handler:getData('engine') then
            SetVehicleEngineHealth(cache.vehicle, newEngine)
        else
            SetVehicleEngineHealth(cache.vehicle, 0.0)
        end
    end

    -- Impact handler
    local speedDiff = Handler:getData('speed') - (GetEntitySpeed(cache.vehicle) *  Units)
    if speedDiff >= Settings.threshold.speed then

        -- Handle wheel loss
        if Settings.breaktire then
            if bodyDiff >= Settings.threshold.health then
                math.randomseed(GetGameTimer())
                Handler:breakTire(cache.vehicle, math.random(0, 1))
            end
        end

        -- Handle heavy impact (disable vehicle)
        if speedDiff >= Settings.threshold.heavy then
            SetVehicleUndriveable(cache.vehicle, true)
            SetVehicleEngineHealth(cache.vehicle, 0.0)
            SetVehicleEngineOn(cache.vehicle, false, true, false)
        end
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

lib.onCache('seat', function(seat)
    if seat == -1 then
        startThread(cache.vehicle)
    end
end)

CreateThread(function()
    Handler = Handler:new()

    if cache.seat == -1 then
        startThread(cache.vehicle)
    end
end)
