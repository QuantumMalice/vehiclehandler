if not lib.checkDependency('ox_lib', '3.14.0') then print('Update ox_lib to v3.14.0 or newer!') return end

local Utils = require 'modules.utils'
local Framework = Utils.Detect.Framework()

if Framework ~= false then
    if Framework == 'ox' then
        AddEventHandler('ox:playerLogout', function(source, userid, charid)
            TriggerClientEvent('vehiclehandler:playerlogout', source)
        end)
    elseif Framework == 'qb' then
        RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
            TriggerClientEvent('vehiclehandler:playerlogout', source)
        end)
    elseif Framework == 'es' then
        RegisterNetEvent('esx:onPlayerLogout', function()
            TriggerClientEvent('vehiclehandler:playerlogout', source)
        end)
    end
end

lib.callback.register('vehiclehandler:server:sync', function(source)
    return true
end)

lib.addCommand('fix', {
    help = 'Repair current vehicle',
    restricted = 'qbcore.god'
}, function(source, args, raw)
    TriggerClientEvent('vehiclehandler:client:adminfix', source)
end)

-- Items
if GetResourceState('ox_inventory') == 'started' then
    RegisterNetEvent('vehiclehandler:removeItem', function(item)
        local src = source
        exports.ox_inventory:RemoveItem(src, item, 1)
    end)

    RegisterNetEvent('vehiclehandler:server:removewashingkit', function(veh)
        local src = source
        exports.ox_inventory:RemoveItem(src, 'cleaningkit', 1)
        TriggerClientEvent('vehiclehandler:client:SyncWash', -1, veh)
    end)
end