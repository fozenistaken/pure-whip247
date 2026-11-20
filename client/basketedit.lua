CarryPoses = {
    { dict = 'move_weapon@jerrycan@generic', clip = 'idle', label = 'Arm down (jerrycan)' },
    { dict = 'missfbi4prepp1', clip = '_idle_garbage_man', label = 'Bag at the side' },
    { dict = 'move_p_m_zero_rucksack', clip = 'walk_rucksack_rightarm', label = 'Hand on a strap' },
    { dict = 'anim@heists@box_carry@', clip = 'idle', label = 'Both hands, in front' },
}

local STEPS = { { m = 0.002, d = 1.0 }, { m = 0.005, d = 2.5 }, { m = 0.01, d = 5.0 }, { m = 0.03, d = 15.0 } }
local K = { left = 174, right = 175, up = 172, down = 173, pgup = 10, pgdn = 11, shift = 21,
            wheelUp = 15, wheelDown = 14, enter = 191, back = 194, n1 = 157, n2 = 158, n3 = 160, n4 = 164 }

local editing = false

local function loadDict(d)
    if HasAnimDictLoaded(d) then return true end
    RequestAnimDict(d)
    local t = GetGameTimer() + 2000
    while not HasAnimDictLoaded(d) and GetGameTimer() < t do Wait(0) end
    return HasAnimDictLoaded(d)
end

local function freezePose(ped, pose)
    if not loadDict(pose.dict) then return end
    ClearPedTasksImmediately(ped)
    TaskPlayAnim(ped, pose.dict, pose.clip, 8.0, -8.0, -1, 49, 0.0, false, false, false)
    Wait(250)
    SetEntityAnimSpeed(ped, pose.dict, pose.clip, 0.0)
end

RegisterNetEvent('pure-247:basketEdit', function(cur)
    if editing or type(cur) ~= 'table' then return end
    editing = true
    local ped = PlayerPedId()
    local hash = joaat(cur.model)
    RequestModel(hash)
    local t = GetGameTimer() + 3000
    while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(0) end
    if not HasModelLoaded(hash) then
        exports.whip_core:Notify('The basket model is not loaded (is pure-247 streaming it?)', 'error')
        editing = false
        return
    end
    local o = { cur.offset[1], cur.offset[2], cur.offset[3] }
    local r = { cur.rot[1], cur.rot[2], cur.rot[3] }
    local poseIdx = math.max(1, math.min(#CarryPoses, tonumber(cur.pose) or 1))
    local step = 2
    local obj = CreateObject(hash, GetEntityCoords(ped), false, false, false)
    SetEntityCollision(obj, false, false)
    local bone = GetPedBoneIndex(ped, cur.bone)
    local function attach()

        AttachEntityToEntity(obj, ped, bone, o[1] + 0.0, o[2] + 0.0, o[3] + 0.0, r[1] + 0.0, r[2] + 0.0, r[3] + 0.0, true, true, false, true, 1, true)
    end
    local function show()
        exports.whip_core:ShowText(('Basket hold  %s | x %.3f  y %.3f  z %.3f   ·   turn %.1f  %.1f  %.1f   ·   step %s m / %s°   ·   '
            .. '[Arrows] move  [PgUp/PgDn] up/down  [Shift] turn  [Wheel] step  [1-4] pose  [Enter] save  [Backspace] cancel')
            :format(CarryPoses[poseIdx].label, o[1], o[2], o[3], r[1], r[2], r[3], STEPS[step].m, STEPS[step].d), { position = 'top' })
    end
    FreezeEntityPosition(ped, true)
    freezePose(ped, CarryPoses[poseIdx])
    attach(); show()

    local done, save = false, false
    while not done do
        for _, c in pairs(K) do DisableControlAction(0, c, true) end
        DisableControlAction(0, 24, true); DisableControlAction(0, 25, true); DisableControlAction(0, 200, true)
        local changed = false
        local turning = IsDisabledControlPressed(0, K.shift)
        local function key(c) return IsDisabledControlJustPressed(0, c) end
        local s = STEPS[step]
        local pairs_ = { { K.right, 1, 1 }, { K.left, 1, -1 }, { K.up, 2, 1 }, { K.down, 2, -1 }, { K.pgup, 3, 1 }, { K.pgdn, 3, -1 } }
        for _, p in ipairs(pairs_) do
            if key(p[1]) then
                if turning then r[p[2]] = (r[p[2]] + p[3] * s.d) % 360 else o[p[2]] = o[p[2]] + p[3] * s.m end
                changed = true
            end
        end
        if key(K.wheelUp) then step = math.min(#STEPS, step + 1) changed = true end
        if key(K.wheelDown) then step = math.max(1, step - 1) changed = true end
        for i, c in ipairs({ K.n1, K.n2, K.n3, K.n4 }) do
            if key(c) and CarryPoses[i] then poseIdx = i; freezePose(ped, CarryPoses[i]); changed = true end
        end
        if key(K.enter) then done, save = true, true end
        if key(K.back) then done = true end
        if changed then attach(); show() end
        Wait(0)
    end

    DeleteEntity(obj)
    SetModelAsNoLongerNeeded(hash)
    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)
    exports.whip_core:HideText()
    if save then
        TriggerServerEvent('pure-247:saveBasketPose', { o[1], o[2], o[3] }, { r[1], r[2], r[3] }, poseIdx)
    end
    editing = false
end)
