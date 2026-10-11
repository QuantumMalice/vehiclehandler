if not lib then print('^1ox_lib must be started before this resource.^0') return end
lib.locale()

lib.versionCheck("QuantumMalice/vehiclehandler")

if GetResourceState('ox_inventory') == 'started' then
    exports('cleaningkit', function(event, item, inventory)
        if event == 'usingItem' then
            local success = lib.callback.await('vehiclehandler:basicwash', inventory.id)
            if success then return else return false end
        end
    end)

    exports('tirekit', function(event, item, inventory)
        if event == 'usingItem' then
            local success = lib.callback.await('vehiclehandler:basicfix', inventory.id, 'tirekit')
            if success then return else return false end
        end
    end)

    exports('repairkit', function(event, item, inventory)
        if event == 'usingItem' then
            local success = lib.callback.await('vehiclehandler:basicfix', inventory.id, 'smallkit')
            if success then return else return false end
        end
    end)

    exports('advancedrepairkit', function(event, item, inventory)
        if event == 'usingItem' then
            local success = lib.callback.await('vehiclehandler:basicfix', inventory.id, 'bigkit')
            if success then return else return false end
        end
    end)
end

lib.callback.register('vehiclehandler:sync', function()
    return true
end)

---@param vehicle number?
---@return boolean
local function isVehicle(vehicle)
    return vehicle ~= nil and vehicle ~= 0 and DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2
end

---@param source number
---@return number? vehicle
local function getPlayerVehicle(source)
    local vehicle <const> = GetVehiclePedIsIn(GetPlayerPed(source), false)
    if isVehicle(vehicle) then return vehicle end
end

---Vehicle damage, dirt and fuel sync from the vehicle's owner, so admin changes are applied there
---(falling back to `fallback`, usually the admin, when no player owns it)
---@param vehicle number
---@param fallback number?
---@param event string
local function sendToOwner(vehicle, fallback, event, ...)
    local owner = NetworkGetEntityOwner(vehicle)
    if not owner or owner <= 0 then owner = fallback end
    if not owner then return end

    TriggerClientEvent(event, owner, NetworkGetNetworkIdFromEntity(vehicle), ...)
end

---ox_fuel only lets the server raise fuel (clients can only report lower), so the replicated state is set here.
---Called after the owner's event so their game already has the new level when ox_fuel next compares the two.
---@param vehicle number
---@param level number
local function setVehicleFuel(vehicle, level)
    if GetResourceState('ox_fuel') ~= 'started' then return end

    Entity(vehicle).state:set('fuel', level, true)
end

---@param vehicle number
---@param fallback number?
---@return boolean success
local function fixVehicle(vehicle, fallback)
    if not isVehicle(vehicle) then return false end

    sendToOwner(vehicle, fallback, 'vehiclehandler:client:applyFix')
    setVehicleFuel(vehicle, 100.0)

    return true
end

---@param vehicle number
---@param level number
---@param fallback number?
---@return boolean success
local function setFuel(vehicle, level, fallback)
    if not isVehicle(vehicle) or type(level) ~= 'number' then return false end

    level = lib.math.clamp(level, 0.0, 100.0) + 0.0

    sendToOwner(vehicle, fallback, 'vehiclehandler:client:applyFuel', level)
    setVehicleFuel(vehicle, level)

    return true
end

exports('fixVehicle', fixVehicle)
exports('setFuel', setFuel)

lib.addCommand('fix', {
    help = locale('commands.fix.help'),
    restricted = 'group.admin'
}, function(source)
    local vehicle <const> = getPlayerVehicle(source)
    if vehicle then fixVehicle(vehicle, source) end
end)

lib.addCommand('wash', {
    help = locale('commands.wash.help'),
    restricted = 'group.admin'
}, function(source)
    local vehicle <const> = getPlayerVehicle(source)
    if vehicle then sendToOwner(vehicle, source, 'vehiclehandler:client:applyWash') end
end)

lib.addCommand('setfuel', {
    help = locale('commands.setfuel.help'),
    params = {
        {
            name = locale('commands.setfuel.params.name'),
            type = locale('commands.setfuel.params.type'),
            help = locale('commands.setfuel.params.help'),
        },
    },
    restricted = 'group.admin'
}, function(source, args)
    local level = tonumber(args.level)
    local vehicle <const> = getPlayerVehicle(source)

    if level and vehicle then setFuel(vehicle, level, source) end
end)
