lib.versionCheck("QuantumMalice/vehiclehandler")

if not lib.checkDependency('ox_lib', '3.24.0', true) then return end

if GetResourceState('ox_inventory') == 'started' then
    if not lib.checkDependency('ox_inventory', '2.41.0', true) then return end

    exports('cleaningkit', function(event, item, inventory, slot, data)
        if event == 'usingItem' then
            local success = lib.callback.await('vehiclehandler:basicwash', inventory.id)
            if success then return else return false end
        end
    end)

    exports('tirekit', function(event, item, inventory, slot, data)
        if event == 'usingItem' then
            local success = lib.callback.await('vehiclehandler:basicfix', inventory.id, 'tirekit')
            if success then return else return false end
        end
    end)

    exports('repairkit', function(event, item, inventory, slot, data)
        if event == 'usingItem' then
            local success = lib.callback.await('vehiclehandler:basicfix', inventory.id, 'smallkit')
            if success then return else return false end
        end
    end)

    exports('advancedrepairkit', function(event, item, inventory, slot, data)
        if event == 'usingItem' then
            local success = lib.callback.await('vehiclehandler:basicfix', inventory.id, 'bigkit')
            if success then return else return false end
        end
    end)
end

lib.callback.register('vehiclehandler:sync', function()
    return true
end)

lib.addCommand('fix', {
    help = 'Repair current vehicle',
    restricted = 'group.admin'
}, function(source, args, raw)
    lib.callback('vehiclehandler:adminfix', source, function() end)
end)

lib.addCommand('wash', {
    help = 'Clean current vehicle',
    restricted = 'group.admin'
}, function(source, args, raw)
    lib.callback('vehiclehandler:adminwash', source, function() end)
end)

lib.addCommand('setfuel', {
    help = 'Set vehicle fuel level',
    params = {
        {
            name = 'level',
            type = 'number',
            help = 'Amount of fuel to set',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local level = args.level

    if level then
        lib.callback('vehiclehandler:adminfuel', source, function() end, level)
    end
end)