if not Config.Shelves or not Config.Shelves.enabled or not Config.Shelves.basket or not Config.Shelves.basket.model then return end

local B = Config.Shelves.basket
local BASKET = joaat(B.model)
local RANGE = 25.0
local FLOOR = -0.392

local SPOTS = {
    { -0.10, -0.055 }, { 0.10, 0.055 }, { -0.10, 0.055 }, { 0.10, -0.055 },
    { -0.035, -0.06 }, { 0.035, 0.06 }, { -0.035, 0.06 }, { 0.035, -0.06 },
}

local MAX_SIZE = 0.45

local shown = {}

local function clear(id)
    local s = shown[id]
    if not s then return end
    for _, o in ipairs(s.props) do
        if DoesEntityExist(o) then DeleteObject(o) end
    end
    shown[id] = nil
end

local function loadModel(name)
    local h = joaat(name)
    if not IsModelInCdimage(h) then return nil end
    RequestModel(h)
    local t = GetGameTimer() + 2000
    while not HasModelLoaded(h) and GetGameTimer() < t do Wait(0) end
    return HasModelLoaded(h) and h or nil
end

local function basketOf(ped)
    if ped == PlayerPedId() then return exports.whip_core:GetOwnHeldProp(B.model, 'basket') end
    for _, o in ipairs(GetGamePool('CObject')) do
        if GetEntityModel(o) == BASKET and GetEntityAttachedTo(o) == ped then return o end
    end
    return nil
end

local function fill(id, basket, list)
    clear(id)
    local s = { basket = basket, key = table.concat(list, ','), props = {} }
    shown[id] = s
    local c = GetEntityCoords(basket)
    for i, item in ipairs(list) do
        local spot = SPOTS[i]
        if not spot then break end
        local m = Goods.model(item)
        local h = m and loadModel(m)
        if h and DoesEntityExist(basket) then
            local o = CreateObjectNoOffset(h, c.x, c.y, c.z, false, false, false)
            SetEntityCollision(o, false, false)
            local mn, mx = GetModelDimensions(h)
            if math.max(mx.x - mn.x, mx.y - mn.y, mx.z - mn.z) > MAX_SIZE then
                DeleteObject(o)
                SetModelAsNoLongerNeeded(h)
                goto continue
            end
            local x, y, z, ry = spot[1], spot[2], FLOOR - mn.z, 0.0
            if mx.z - mn.z > 0.17 then

                ry, x, z = 90.0, 0.0, FLOOR + math.max(mx.x, -mn.x)
            end
            AttachEntityToEntity(o, basket, 0, x, y, z, 0.0, ry, (i % 2) * 25.0, false, false, false, false, 2, true)
            SetModelAsNoLongerNeeded(h)
            s.props[#s.props + 1] = o
        end
        ::continue::
    end
end

AddStateBagChangeHandler('pure-247:goods', nil, function(bagName, _, value)
    if type(value) == 'table' and #value > 0 then return end
    local ply = GetPlayerFromStateBagName(bagName)
    if ply and ply ~= 0 then clear(GetPlayerServerId(ply)) end
end)

CreateThread(function()
    while true do
        if next(shown) then
            for id, s in pairs(shown) do
                if not DoesEntityExist(s.basket) then clear(id) end
            end
            Wait(100)
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1500
        local me = GetEntityCoords(PlayerPedId())
        local seen = {}
        for _, pid in ipairs(GetActivePlayers()) do
            local sid = GetPlayerServerId(pid)
            local list = Player(sid).state['pure-247:goods']
            local ped = GetPlayerPed(pid)
            if type(list) == 'table' and #list > 0 and ped ~= 0 and #(GetEntityCoords(ped) - me) < RANGE then
                seen[sid] = true
                sleep = 700
                local s = shown[sid]
                local basket = s and s.basket
                if not basket or not DoesEntityExist(basket) or GetEntityAttachedTo(basket) ~= ped then basket = basketOf(ped) end
                if basket and basket ~= 0 then
                    if not s or s.basket ~= basket or s.key ~= table.concat(list, ',') then fill(sid, basket, list) end
                elseif s then
                    clear(sid)
                end
            end
        end
        for sid in pairs(shown) do
            if not seen[sid] then clear(sid) end
        end
        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for id in pairs(shown) do clear(id) end
end)
