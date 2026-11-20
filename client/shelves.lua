if not Config.Shelves or not Config.Shelves.enabled then return end

local MEDIA = 'https://cfx-nui-whip_media_props/img/props/%s.webp'
local OWN = ('https://cfx-nui-%s/html/img/items/%%s.webp'):format(GetCurrentResourceName())
local CORE = 'img/items/%s.webp'
local NEAR, FAR = 30.0, 40.0

local SHOP = 'pure247_shop'
local CLIPS = {

    low  = { dict = 'anim@scripted@player@freemode@gen_grab@male@', clip = 'low_lh', at = 0.48 },

    med  = { dict = 'anim@scripted@player@freemode@gen_grab@male@', clip = 'med_lh', at = 0.9, flag = 48 },
    high = { dict = 'anim@scripted@player@freemode@gen_grab@male@', clip = 'high_lh', at = 0.63 },

    take = { dict = 'pure247_basket_take', clip = 'basket_take', at = 0.667 },
    put  = { dict = 'anim@scripted@player@freemode@gen_grab@male@', clip = 'low_rh', at = 0.48 },
    stuff = { clip = 'stuff_basket', at = 1.60 },
    left  = { clip = 'stuff_left', at = 0.95 },
    right = { clip = 'stuff_right', at = 0.95 },
}

local PLAIN = { dict = 'anim@scripted@player@freemode@gen_grab@male@', low = 'low_lh', med = 'med_lh', high = 'high_lh',
                at = { low = 0.48, med = 0.58, high = 0.63 } }
local busy = false
local fistOn = nil

local function carryPose() return CarryPoses[GlobalState['pure-247:carryPose'] or 1] or CarryPoses[1] end

local prices = {}
local up = {}

local defs = {}
for _, it in ipairs(Config.Items) do defs[it.key] = it end
local CORE_NAMES = { drink = 'Water', food = 'Burger' }

local function nameOf(item) return (defs[item] and defs[item].name) or CORE_NAMES[item] or item end
local function pictureOf(item)
    local d = defs[item]
    if d and d.picture then return MEDIA:format(d.picture) end
    if d then return OWN:format(item) end
    return CORE:format(item)
end
local function priceText(store, item)
    local p = prices[store] and tonumber(prices[store][item])
    return p and ('$%d'):format(p) or ''
end

local function loadDict(d)
    if HasAnimDictLoaded(d) then return true end
    RequestAnimDict(d)
    local t = GetGameTimer() + 1500
    while not HasAnimDictLoaded(d) and GetGameTimer() < t do Wait(0) end
    return HasAnimDictLoaded(d)
end

local function play(a, upperOnly, loop)
    if not loadDict(a.dict) then return end
    TaskPlayAnim(PlayerPedId(), a.dict, a.clip, 4.0, -4.0, loop and -1 or 1000, loop and 49 or 48, 0.0, false, false, false)
end

local function holdingBasket()
    local B = Config.Shelves.basket
    return B and B.model and exports.whip_core:GetOwnHeldProp(B.model, 'basket') ~= nil
end

local function hanging() return holdingBasket() end

local CLOSE = 1.2

local function faceFor(target)
    local ped = PlayerPedId()
    local me = GetEntityCoords(ped)
    local d = vector2(target.x - me.x, target.y - me.y)
    if #d > CLOSE then
        exports.whip_core:Notify('Too far: step closer', 'error')
        return false
    end
    local heading = GetHeadingFromVector_2d(d.x, d.y)
    local diff = math.abs(((heading - GetEntityHeading(ped)) + 180.0) % 360.0 - 180.0)
    if diff > 8.0 then
        TaskAchieveHeading(ped, heading, 350)
        local t = GetGameTimer() + 450
        repeat Wait(0) until GetGameTimer() > t
            or math.abs(((heading - GetEntityHeading(ped)) + 180.0) % 360.0 - 180.0) < 6.0
    end
    SetEntityHeading(ped, heading)
    FreezeEntityPosition(ped, true)
    return true
end

local function playShop(dict, clip, flag)
    if not loadDict(dict) then return 0 end
    local ped = PlayerPedId()

    if ((flag or 0) & 16) == 0 then
        for _, c in ipairs(CarryPoses) do StopAnimTask(ped, c.dict, c.clip, 4.0) end
        if fistOn then StopAnimTask(ped, SHOP, fistOn, 4.0) fistOn = nil end
    end
    local ms = math.floor((GetAnimDuration(dict, clip) or 2.0) * 1000)
    TaskPlayAnim(ped, dict, clip, 6.0, -4.0, ms, flag or 0, 0.0, false, false, false)
    return ms
end
local function finish(started, ms)
    local left = ms - (GetGameTimer() - started)
    if left > 0 then Wait(left - 120) end
    FreezeEntityPosition(PlayerPedId(), false)
    if hanging() then play(carryPose(), true, true) end
    busy = false
end

local function closed(store)
    local list = GlobalState['pure-247:closed']
    local t = type(list) == 'table' and list[store]
    if t and GetCloudTimeAsInt() < t then
        exports.whip_core:Notify('The store is closed: the clerk is down', 'error')
        return true
    end
    return false
end

local function grab(store, index, coords)
    if busy or closed(store) then return end
    busy = true
    local ped = PlayerPedId()
    local dz = coords.z - GetEntityCoords(ped).z
    local h = dz < -0.35 and 'low' or (dz > 0.5 and 'high' or 'med')
    local c = CLIPS[h]
    if not faceFor(coords) then busy = false return end
    local started, ms, at = GetGameTimer(), 0, c.at
    if holdingBasket() then
        ms = playShop(c.dict or SHOP, c.clip, c.flag or 0)
    else
        ms = playShop(PLAIN.dict, PLAIN[h], 0); at = PLAIN.at[h]
    end
    Wait(math.floor(at * 1000))
    TriggerServerEvent('pure-247:grab', store, index)
    finish(started, ms)
end

local TAKE_AHEAD, TAKE_RIGHT = 0.515, 0.06
local TAKE_NEAR, TAKE_FAR = 0.40, 0.65

local function standForTake(stand)
    local ped = PlayerPedId()
    local me = GetEntityCoords(ped)
    local d = vector2(stand.x - me.x, stand.y - me.y)
    local dist = #d
    if dist > TAKE_FAR then
        exports.whip_core:Notify('Too far: step closer', 'error')
        return false
    end
    if dist < TAKE_NEAR then
        exports.whip_core:Notify('Too close: step back', 'error')
        return false
    end
    if not faceFor(stand) then return false end
    local f = d / dist
    local spot = vector2(stand.x, stand.y) - f * TAKE_AHEAD - vector2(f.y, -f.x) * TAKE_RIGHT
    SetEntityCoordsNoOffset(ped, spot.x, spot.y, me.z, false, false, false)
    return true
end

local function takeBasket(store, stand)
    if busy or closed(store) then return end
    busy = true
    local ready
    if holdingBasket() then ready = faceFor(stand) else ready = standForTake(stand) end
    if not ready then busy = false return end
    local started = GetGameTimer()
    local c = CLIPS.take
    local ms = holdingBasket() and 0 or playShop(c.dict or SHOP, c.clip, 0)
    if ms > 0 then Wait(math.floor(c.at * 1000)) end
    TriggerServerEvent('pure-247:takeBasket', store)
    finish(started, ms)
end

local function putUp(store)
    local ids = {}
    for i, g in ipairs(Rooms.goodsAt(store)) do
        local id, why = exports.whip_core:AddAction({
            id = ('pure-247:%s:%d'):format(store, i), group = 'pure-247:shelves',
            at = { coords = g.coords },

            label = ('%s  %s'):format(nameOf(g.item), priceText(store, g.item)),
            image = pictureOf(g.item),
            reach = 2.0, seeFrom = 2.5, scale = 0.6, focusMode = 'aim',
            onSelect = function() grab(store, i, g.coords) end,
        })
        if id then ids[#ids + 1] = id else print(('^3[pure-247] %s at %s: no prompt (%s)^7'):format(g.item, store, tostring(why))) end
    end
    local stand = Rooms.at(store, 'stand')
    if stand then
        local id = exports.whip_core:AddAction({
            id = ('pure-247:%s:basket'):format(store), group = 'pure-247:shelves',
            at = { coords = stand }, label = 'Take a basket', focusMode = 'aim', reach = 2.0, seeFrom = 4.0,
            onSelect = function() takeBasket(store, stand) end,
        })
        if id then ids[#ids + 1] = id end
    end
    up[store] = ids
end

local function takeDown(store)
    for _, id in ipairs(up[store] or {}) do exports.whip_core:RemoveAction(id) end
    up[store] = nil
end

local function fetchPrices()
    CreateThread(function()
        local p = exports.whip_core:Callback('pure-247:prices')
        if type(p) ~= 'table' then return end
        prices = p

        for store in pairs(up) do takeDown(store) putUp(store) end
    end)
end

CreateThread(function()
    while not exports.whip_core:IsPlayerLoaded() do Wait(1000) end
    fetchPrices()
    local carrying = false
    while true do
        local ped = PlayerPedId()
        local me = GetEntityCoords(ped)
        for key, room in pairs(Config.Rooms) do
            local d = #(me - vector3(room.x, room.y, room.z))
            if d < NEAR and not up[key] then putUp(key)
            elseif d > FAR and up[key] then takeDown(key) end
        end
        local holding = hanging()
        local fists = LocalPlayer.state['pure-247:fists']
        local fist = fists == 'LR' and 'hold_both' or (fists == 'L' and 'hold_left' or (fists == 'R' and 'hold_right' or nil))
        if busy then

        elseif fist and not exports.whip_core:IsEmoting() then
            if fistOn then StopAnimTask(ped, SHOP, fistOn, 2.0) fistOn = nil end
        elseif holding and not exports.whip_core:IsEmoting() then
            local c = carryPose()
            if not IsEntityPlayingAnim(ped, c.dict, c.clip, 3) then play(c, true, true) end
            carrying = true
        elseif carrying then
            for _, c in ipairs(CarryPoses) do StopAnimTask(ped, c.dict, c.clip, 2.0) end
            carrying = false
        end
        if fistOn and not fist then
            StopAnimTask(ped, SHOP, fistOn, 2.0)
            fistOn = nil
        end
        Wait(500)
    end
end)

Whip.register(function() up = {} end)

AddEventHandler('whip_core:player:loaded', fetchPrices)
RegisterNetEvent('pure-247:pricesChanged', fetchPrices)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, c in ipairs(CarryPoses) do StopAnimTask(PlayerPedId(), c.dict, c.clip, 2.0) end
end)

RegisterNetEvent('pure-247:paid', function(p)
    if type(p) ~= 'table' then return end
    CreateThread(function()
        local t = GetGameTimer() + 3000
        while busy and GetGameTimer() < t do Wait(100) end
        busy = true
        local function step(c, flag, event, arg)
            local started = GetGameTimer()
            local ms = playShop(SHOP, c.clip, flag)
            if ms <= 0 then return end
            Wait(math.floor(c.at * 1000))
            if event then TriggerServerEvent(event, arg) end
            local left = ms - (GetGameTimer() - started)
            if left > 80 then Wait(left - 80) end
        end
        if p.hand then
            if p.left then step(CLIPS.left, 48, 'pure-247:stuffed', 'left') end
            if p.right then step(CLIPS.right, 48, 'pure-247:stuffed', 'right') end
            busy = false
            return
        end
        for _ = 1, math.max(1, math.min(4, tonumber(p.stuffs) or 1)) do
            step(CLIPS.stuff, 48, 'pure-247:stuffed', 'basket')
        end

        local stand = p.store and Rooms.at(p.store, 'stand')
        local ped = PlayerPedId()
        if stand then
            local me = GetEntityCoords(ped)
            local d = vector2(stand.x - me.x, stand.y - me.y)
            local fwd = #d > 0.05 and d / #d or vector2(0.0, 1.0)
            local spot = vector2(stand.x, stand.y) - fwd * 0.55
            if #(spot - vector2(me.x, me.y)) > 0.3 then
                TaskFollowNavMeshToCoord(ped, spot.x, spot.y, me.z, 1.0, 15000, 0.25, 0, GetHeadingFromVector_2d(fwd.x, fwd.y))
                play(carryPose(), true, true)
                local until_ = GetGameTimer() + 15000
                repeat
                    Wait(100)
                    local c = GetEntityCoords(ped)
                until #(vector2(c.x, c.y) - spot) < 0.35 or GetGameTimer() > until_
            end
        end
        if not stand or faceFor(stand) then

            local started = GetGameTimer()
            local put = CLIPS.put
            local ms = playShop(put.dict or SHOP, put.clip, 0)
            Wait(math.floor(put.at * 1000))
            TriggerServerEvent('pure-247:returned')
            local left = ms - (GetGameTimer() - started)
            if left > 80 then Wait(left - 80) end
            FreezeEntityPosition(ped, false)
        else
            TriggerServerEvent('pure-247:returned')
        end
        busy = false
    end)
end)

RegisterNetEvent('pure-247:clerkGive', function(netId, model, grabMs, giveMs)
    if type(model) ~= 'string' or not NetworkDoesNetworkIdExist(netId) then return end
    local started = GetGameTimer()
    local clerk = NetToPed(netId)
    if not DoesEntityExist(clerk) or #(GetEntityCoords(clerk) - GetEntityCoords(PlayerPedId())) > 30.0 then return end
    local h = joaat(model)
    if not IsModelInCdimage(h) then return end
    RequestModel(h)
    local t = GetGameTimer() + 1500
    while not HasModelLoaded(h) and GetGameTimer() < t do Wait(0) end
    if not HasModelLoaded(h) then return end
    local wait = (tonumber(grabMs) or 2330) - (GetGameTimer() - started)
    if wait > 0 then Wait(wait) end
    if not DoesEntityExist(clerk) then SetModelAsNoLongerNeeded(h) return end
    local o = CreateObjectNoOffset(h, GetEntityCoords(clerk), false, false, false)
    SetEntityCollision(o, false, false)
    AttachEntityToEntity(o, clerk, GetPedBoneIndex(clerk, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, true, 1, true)
    SetModelAsNoLongerNeeded(h)
    wait = (tonumber(giveMs) or 6130) - (GetGameTimer() - started)
    Wait(math.max(0, wait))
    DeleteObject(o)
end)

RegisterNetEvent('pure-247:receive', function(netId, giveMs)
    if busy then return end
    busy = true
    local started = GetGameTimer()
    local ped = PlayerPedId()
    local clerk = NetworkDoesNetworkIdExist(netId) and NetToPed(netId) or 0
    if clerk ~= 0 and DoesEntityExist(clerk) then
        TaskTurnPedToFaceEntity(ped, clerk, 600)
    end
    local c = CLIPS.med
    local wait = (tonumber(giveMs) or 6130) - math.floor(c.at * 1000) - (GetGameTimer() - started)
    if wait > 0 then Wait(wait) end
    local ms = playShop(c.dict, c.clip, c.flag)
    Wait(math.max(0, ms - 120))
    if hanging() then play(carryPose(), true, true) end
    busy = false
end)

RegisterNetEvent('pure-247:clerkSpeak', function(netId, line)
    if type(line) ~= 'string' or not NetworkDoesNetworkIdExist(netId) then return end
    local clerk = NetToPed(netId)
    if DoesEntityExist(clerk) then PlayPedAmbientSpeechNative(clerk, line, 'SPEECH_PARAMS_FORCE_SHOUTED') end
end)

RegisterNetEvent('pure-247:smoke', function(emote)
    if type(emote) == 'string' then exports.whip_core:PlayEmote(emote) end
end)
