local Utils = {}

Utils.Detect = {}
Utils.Player = {}
Utils.Vehicle = {}

-- Detection utility
function Utils.Detect.Framework()
    local frameworks = { 'ox_core', 'qb-core', 'es_extended' }
    for _, v in pairs(frameworks) do
        if GetResourceState(v) == 'started' then
            return string.sub(v, 1, 2)
        end
    end

    return false
end

function Utils.Detect.Fuel()
    if GetResourceState('ox_fuel') == 'started' then
        return string.sub('ox_fuel', 1, 2)
    end

    return false
end

-- Player utility
function Utils.Player.Data()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local seat = false
    if veh and veh > 0 then
        local max = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
        for i=1,max do
            local index = i-2
            if GetPedInVehicleSeat(veh, index) == ped then
                seat = index
            end
        end
    else
        veh = false
    end
    return veh, seat
end

function Utils.Player.Seated(seat)
	return seat and true or false
end

-- Vehicle utility
function Utils.Vehicle.Repair(veh, script)
    lib.callback('vehiclehandler:server:sync', -1, function()
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
        SetVehicleDirtLevel(veh, 0.0)

        if script == 'ox' then
            Entity(veh).state.fuel = 100.0
        else
            SetVehicleFuelLevel(veh, 100.0)
            DecorSetFloat(veh, '_FUEL_LEVEL', GetVehicleFuelLevel(vehicle))
        end

        SetVehicleEngineOn(veh, true, true, false)
    end)
end

return Utils