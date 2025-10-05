local Progress = lib.load('data.progress')
local Settings = lib.load('data.vehicle')

local BONES <const> = {
    [0] =   'wheel_lf',
            'wheel_rf',
            'wheel_lm',
            'wheel_rm',
            'wheel_lr',
            'wheel_rr'
}

---@class privateHandlerData
---@field active boolean
---@field limited boolean
---@field control boolean
---@field class number | false
---@field model number | false
---@field data table
---@field oxfuel boolean
---@field electric boolean

---@class Handler : OxClass
---@field private private privateHandlerData
---@diagnostic disable-next-line: assign-type-mismatch
local Handler = lib.class('vehiclehandler')

function Handler:constructor()
    self:setActive(false)
    self:setLimited(false)
    self:setControl(true)
    self.private.oxfuel = GetResourceState('ox_fuel') == 'started' and true or false
end

---@return boolean active
function Handler:isActive() return self.private.active end

---@return boolean limited
function Handler:isLimited() return self.private.limited end

---@return boolean control
function Handler:canControl() return self.private.control end

---@return number | false class
function Handler:getClass() return self.private.class end

---@return number | false class
function Handler:getModel() return self.private.model end

---@return boolean oxfuel
function Handler:isFuelOx() return self.private.oxfuel end

---@return boolean electric
function Handler:isElectric() return self.private.electric end

---@param state string
---@return number | nil
function Handler:getData(state)
    if not state or type(state) ~= 'string' then return end

    return self.private.data[state]
end

---@return boolean isValid
function Handler:isValid()
    if not cache.ped then return false end
    if cache.vehicle or IsPedInAnyPlane(cache.ped) then return true end

    return false
end

---@param vehicle number
---@param coords vector3
---@return boolean isTireBroken
function Handler:isTireBroken(vehicle, coords)
    if not vehicle or not coords then return false end

    for k,v in pairs(BONES) do
        local bone = GetEntityBoneIndexByName(vehicle, v)

        if bone ~= -1 then
            if IsVehicleTyreBurst(vehicle, k, true) then
                local pos = GetWorldPositionOfEntityBone(vehicle, bone)

                if #(coords - pos) < 2.5 then
                    return true
                end
            end
        end
    end

    return false
end

---@param state boolean
function Handler:setActive(state)
    if state ~= nil and type(state) == 'boolean' then
        self.private.active = state

        if state then
            self.private.class = GetVehicleClass(cache.vehicle) or false
            self.private.model = GetEntityModel(cache.vehicle)
            self.private.electric = GetIsVehicleElectric(self.private.model)
        else
            self.private.class = false
            self.private.model = false
            self.private.electric = false
            self.private.data = {['engine'] = 0, ['body'] = 0, ['speed'] = 0}
        end
    end
end

---@param state boolean
function Handler:setLimited(state)
    if state ~= nil and type(state) == 'boolean' then
        self.private.limited = state
    end
end

---@param state boolean
function Handler:setControl(state)
    if state ~= nil and type(state) == 'boolean' then
        self.private.control = state
    end
end

---@param data table<string, number>[]
---@return table<string, number>[] | nil, table<string, number>[] | nil, table<string, number>[] | nil data
function Handler:setData(data)
    if not data then return end

    self.private.data = data

    return data['engine'], data['body'], data['speed']
end

---@param vehicle number
---@return boolean | nil, vector3 | nil, number | nil, number | nil enginedata
function Handler:getEngineData(vehicle)
    if not vehicle or vehicle == 0 then return end

    local backengine = Settings.backengine[self.private.model]
    local distance = backengine and -2.5 or 2.5
    local index = backengine and 5 or 4
    local offset = GetOffsetFromEntityInWorldCoords(vehicle, 0, distance, 0)
    local engine = GetVehicleEngineHealth(vehicle)

    return backengine, offset, index, engine
end

---@param vehicle number
---@param index number
function Handler:breakTire(vehicle, index)
    if vehicle == nil or type(vehicle) ~= 'number' then return end
    if index == nil or type(index) ~= 'number' then return end

    local bone = GetEntityBoneIndexByName(vehicle, BONES[index])

    if bone ~= -1 then
        if not IsVehicleTyreBurst(vehicle, index, true) then

            lib.callback('vehiclehandler:sync', false, function()
                SetVehicleTyreBurst(vehicle, index, true, 1000.0)
                BreakOffVehicleWheel(vehicle, index, false, true, true, false)
            end)
        end
    end
end

---@param vehicle number
---@param coords vector3
---@return boolean success
function Handler:fixTire(vehicle, coords)
    local found = self:isTireBroken(vehicle, coords)
    if not found then return false end

    local lastengine = GetVehicleEngineHealth(vehicle)
    local lastbody = GetVehicleBodyHealth(vehicle)
    local lastdirt = GetVehicleDirtLevel(vehicle)
    local success = false

    LocalPlayer.state:set("inv_busy", true, true)

    if lib.progressCircle(Progress['tirekit']) then
        success = true

        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleFixed(vehicle)
            SetVehicleEngineHealth(vehicle, lastengine)
            SetVehicleBodyHealth(vehicle, lastbody)
            SetVehicleDirtLevel(vehicle, lastdirt)
        end)
    end

    LocalPlayer.state:set("inv_busy", false, true)

    return success
end

---@param vehicle number
---@param coords vector3
---@param fixtype string
---@return boolean success
function Handler:fixVehicle(vehicle, coords, fixtype)
    local backengine, offset, hoodindex, engine = self:getEngineData(vehicle)

    if fixtype == 'smallkit' and engine < 500 or fixtype == 'bigkit' and engine < 1000 then
        if #(coords - offset) < 2.0 then
            local success = false

            LocalPlayer.state:set("inv_busy", true, true)

            if hoodindex then
                lib.callback('vehiclehandler:sync', false, function()
                    SetVehicleDoorOpen(vehicle, hoodindex, false, false)
                end)
            end

            if lib.progressCircle(Progress[fixtype]) then
                success = true
            end

            if hoodindex then
                lib.callback('vehiclehandler:sync', false, function()
                    SetVehicleDoorShut(vehicle, hoodindex, false)
                end)

                repeat Wait(100)
                until not IsVehicleDoorFullyOpen(vehicle, hoodindex)
            end

            if success then
                lib.callback('vehiclehandler:sync', false, function()
                    if fixtype == 'smallkit' then
                        SetVehicleEngineHealth(vehicle, 500.0)

                        if GetVehicleBodyHealth(vehicle) < 500 then
                            SetVehicleBodyHealth(vehicle, 500.0)
                        end
                    elseif fixtype == 'bigkit' then
                        SetVehicleFixed(vehicle)
                    end

                    SetVehicleUndriveable(vehicle, false)
                end)
            end

            LocalPlayer.state:set("inv_busy", false, true)

            return success
        else
            if backengine then
                lib.notify({
                    title = locale('notify.backEngine'),
                    type = 'error'
                })
            end
        end
    else
        lib.notify({
            title = locale('notify.cannotRepair'),
            type = 'error'
        })
    end

    return false
end

---@param fixtype string
---@return boolean | nil success
function Handler:basicfix(fixtype)
    if not cache.ped then return false end
    if not fixtype or type(fixtype) ~= 'string' then return false end

    local coords = GetEntityCoords(cache.ped)
    local vehicle,_ = lib.getClosestVehicle(coords, 3.0, false)
	if vehicle == nil or vehicle == 0 then return false end

    if fixtype == 'tirekit' then
        return self:fixTire(vehicle, coords)
    elseif fixtype == 'smallkit' or fixtype == 'bigkit' then
        return self:fixVehicle(vehicle, coords, fixtype)
    end
end

---@return boolean success
function Handler:basicwash()
    if not cache.ped then return false end

    local pos = GetEntityCoords(cache.ped)
    local vehicle,_ = lib.getClosestVehicle(pos, 3.0, false)
	if vehicle == nil or vehicle == 0 then return false end

    local vehpos = GetEntityCoords(vehicle)
    if #(pos - vehpos) > 3.0 or cache.vehicle then return false end

    local success = false
    LocalPlayer.state:set("inv_busy", true, true)
    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_MAID_CLEAN", 0, true)

    if lib.progressCircle(Progress['cleankit']) then
        success = true

        lib.callback('vehiclehandler:sync', false, function()
            SetVehicleDirtLevel(vehicle, 0.0)
            WashDecalsFromVehicle(vehicle, 1.0)
        end)
    end

    ClearAllPedProps(cache.ped)
    ClearPedTasks(cache.ped)

    LocalPlayer.state:set("inv_busy", false, true)

    return success
end

---@return boolean success
function Handler:adminfix()
    if not self:isValid() then return false end

    lib.callback('vehiclehandler:sync', false, function()
        SetVehicleFixed(cache.vehicle)
        ResetVehicleWheels(cache.vehicle, true)

        if self:isFuelOx() then
            Entity(cache.vehicle).state.fuel = 100.0
        end

        SetVehicleFuelLevel(cache.vehicle, 100.0)
        DecorSetFloat(cache.vehicle, '_FUEL_LEVEL', GetVehicleFuelLevel(cache.vehicle))

        SetVehicleUndriveable(cache.vehicle, false)
        SetVehicleEngineOn(cache.vehicle, true, true, true)
    end)

    return true
end

---@return boolean success
function Handler:adminwash()
    if not self:isValid() then return false end

    lib.callback('vehiclehandler:sync', false, function()
        SetVehicleDirtLevel(cache.vehicle, 0.0)
        WashDecalsFromVehicle(cache.vehicle, 1.0)
    end)

    return true
end

---@param newlevel number
---@return boolean success
function Handler:adminfuel(newlevel)
    if not self:isValid() then return false end
    if not newlevel then return false end

    newlevel = lib.math.clamp(newlevel, 0.0, 100.0) + 0.0

    lib.callback('vehiclehandler:sync', false, function()
        if self:isFuelOx() then
            Entity(cache.vehicle).state.fuel = newlevel
        end

        SetVehicleFuelLevel(cache.vehicle, newlevel)
        DecorSetFloat(cache.vehicle, '_FUEL_LEVEL', GetVehicleFuelLevel(cache.vehicle))

        SetVehicleUndriveable(cache.vehicle, false)
        SetVehicleEngineOn(cache.vehicle, true, true, true)
    end)

    return true
end

return Handler