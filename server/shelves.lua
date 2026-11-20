if not Config.Shelves or not Config.Shelves.enabled then return end

local S = Config.Shelves
local baskets = {}
local clerkPts = {}
local after = {}
local goods = {}

local function say(src, text, kind) exports.whip_core:NotifyPlayer(src, text, kind or 'info') end

local function priceAt(_, item)
    local p = tonumber(Prices[item])
    return p and p >= 0 and math.floor(p) or nil
end

local function nameOf(item)
    local def = exports.whip_core:GetItemDef(item)
    return def and def.name or item
end

local function inStore(src, storeKey)
    local st = Rooms.store(storeKey)
    local ped = GetPlayerPed(src)
    if not st or ped == 0 then return false end
    local c = GetEntityCoords(ped)
    return #(c - vector3(st.pos.x, st.pos.y, st.pos.z)) <= 15.0
end

local function priced(b)
    local lines, total, count = {}, 0, 0
    for item, qty in pairs(b.lines) do
        local price = priceAt(b.store, item)
        if price then
            lines[#lines + 1] = { item = item, qty = qty, price = price }
            total = total + price * qty
            count = count + qty
        end
    end
    table.sort(lines, function(a, c) return a.item < c.item end)
    return lines, total, count
end

local TAG = 'basket'
local FULL_TAG = GetCurrentResourceName() .. ':' .. TAG

local function holdBasket(src)
    local B = S.basket
    if not B or not B.model then return end
    local ok, why = exports.whip_core:HoldProps(src, { { model = B.model, bone = B.bone, offset = B.offset, rot = B.rot } }, TAG)
    if not ok then print(('^3[pure-247] basket not put in the hand: %s^7'):format(tostring(why))) end
end

local HANDS_TAG = 'hands'
local FULL_HANDS = GetCurrentResourceName() .. ':' .. HANDS_TAG

local function units(b)
    local n = 0
    for item, qty in pairs(b.lines) do n = n + qty * (Goods.isBig(item) and 2 or 1) end
    return n
end

local function handsOf(lines)
    local list = {}
    for item, qty in pairs(lines) do for _ = 1, qty do list[#list + 1] = item end end
    table.sort(list)
    if list[1] and Goods.isBig(list[1]) then return { right = list[1] } end
    return { left = list[1], right = list[2] }
end

local function holdHeld(src, held)
    local props = {}
    for _, hand in ipairs({ 'left', 'right' }) do
        local h = held[hand] and Goods.hold(held[hand], hand)
        if h then props[#props + 1] = h end
    end
    if #props > 0 then exports.whip_core:HoldProps(src, props, HANDS_TAG)
    elseif exports.whip_core:GetHeldPropsTag(src) == FULL_HANDS then exports.whip_core:DropHeldProps(src, HANDS_TAG) end

    local fists = (held.left and 'L' or '') .. (held.right and 'R' or '')
    Player(src).state:set('pure-247:fists', fists ~= '' and fists or nil, true)
end

local function holdHands(src, b) holdHeld(src, handsOf(b.lines)) end

local function letGoBasket(src)
    Player(src).state:set('pure-247:fists', nil, true)
    local tag = exports.whip_core:GetHeldPropsTag(src)
    if tag == FULL_TAG then exports.whip_core:DropHeldProps(src, TAG)
    elseif tag == FULL_HANDS then exports.whip_core:DropHeldProps(src, HANDS_TAG) end
end

local function finishAfter(src)
    local a = after[src]
    if not a then return end
    after[src] = nil
    Player(src).state:set('pure-247:goods', nil, true)
    letGoBasket(src)
end

local function showList(src)
    if not S.showList then return end
    local b = baskets[src]
    if not b then exports.whip_core:HidePlayerText(src) return end
    local lines, total = priced(b)
    local parts = {}
    for i, l in ipairs(lines) do
        if i > 4 then parts[#parts + 1] = ('+%d more'):format(#lines - 4) break end
        parts[#parts + 1] = ('%d× %s'):format(l.qty, nameOf(l.item))
    end
    local row = #parts > 0 and table.concat(parts, '  ·  ') or 'empty: take goods off the racks'
    exports.whip_core:ShowPlayerText(src, ('%s  $%d | %s'):format(b.hand and 'In your hands' or 'Basket', total, row),
        { position = 'top', icon = 'pickup' })
end

local function syncGoods(src)
    local b = baskets[src]
    local list = nil
    if b and not b.hand then
        list = {}
        for item in pairs(b.lines) do list[#list + 1] = item end
        table.sort(list)
    end
    Player(src).state:set('pure-247:goods', list, true)
end

local function dropBasket(src, why)
    local b = baskets[src]
    if not b then return end
    baskets[src] = nil
    syncGoods(src)
    if clerkPts[src] then RefreshClerk(src) end
    letGoBasket(src)
    if S.showList then exports.whip_core:HidePlayerText(src) end
    if why then say(src, why) end
end

local pay

local function tillLabel(b)
    local _, total, count = priced(b)
    return ('Pay $%d · %d item%s'):format(total, count, count == 1 and '' or 's')
end

local function clerkMenu(src, store)
    local b = baskets[src]
    local opts, label = {}, 'Clerk'
    if b and b.store == store and next(b.lines) then
        label = tillLabel(b)
        opts[#opts + 1] = { id = 'cash', label = 'Pay in cash' }
        opts[#opts + 1] = { id = 'bank', label = 'Pay by card' }
        opts[#opts + 1] = { id = 'empty', label = 'Put it all back' }
    end
    local brands = ClerkCounter and ClerkCounter() or {}
    if #brands > 0 then opts[#opts + 1] = { id = 'cigs', label = 'Ask for cigarettes', options = brands } end
    return label, opts
end

function RefreshClerk(src, store)
    local cur = clerkPts[src]
    store = store or (cur and cur.store)
    if not store then return end
    local clerk = Clerks and Clerks[store]
    local netId = clerk and clerk.netId and NetworkGetEntityFromNetworkId(clerk.netId) ~= 0 and clerk.netId or nil
    local label, opts = clerkMenu(src, store)
    if cur and cur.store == store and cur.netId == netId and cur.pointId then
        exports.whip_core:UpdatePoint(cur.pointId, { label = label, options = opts })
        return
    end
    if cur and cur.pointId then exports.whip_core:RemovePoint(cur.pointId) end
    clerkPts[src] = nil
    local where
    if netId then
        where = { netId = netId, offset = vector3(0.0, 0.0, 0.15) }
    else
        local at = Rooms.at(store, 'pay')
        if not at then return end
        where = { coords = at }
    end
    local id, why = exports.whip_core:AddPoint({
        at = where, label = label, talk = true, options = opts,
        audience = { people = { src } }, reach = 2.5, seeFrom = 8.0,
        onUse = function(source, use)
            if (use.path or ''):sub(1, 5) == 'cigs/' then return ClerkAsk(source, store, use.option) end
            return pay(source, use.option)
        end,
    })
    if id then clerkPts[src] = { store = store, pointId = id, netId = netId }
    else print(('^3[pure-247] clerk prompt not made: %s^7'):format(tostring(why))) end
end

local function dropClerk(src)
    local cur = clerkPts[src]
    if cur and cur.pointId then exports.whip_core:RemovePoint(cur.pointId) end
    clerkPts[src] = nil
end

local function showTill(src)
    local b = baskets[src]
    if b then RefreshClerk(src, b.store) end
end

pay = function(src, option)
    local b = baskets[src]
    if not b then return false, 'Your basket is empty' end
    if option == 'empty' then
        dropBasket(src, 'You put everything back on the shelves')
        return true
    end
    local lines, total = priced(b)
    if #lines == 0 then dropBasket(src) return false, 'Nothing in your basket is for sale any more' end
    for _, l in ipairs(lines) do
        local fits, why = exports.whip_core:CanFitItem(src, l.item, l.qty)
        if not fits then return false, ('No room for %d %s: %s'):format(l.qty, nameOf(l.item), why or 'your pockets are full') end
    end
    local me = exports.whip_core:GetPlayer(src)
    local session = me and me.session
    local receipt, why = exports.whip_core:ChargePlayer(src, total, {
        method = option == 'bank' and 'bank' or 'cash', reason = ('24/7: %d items'):format(#lines),
    })
    if not receipt then return false, why end

    if not exports.whip_core:IsSessionCurrent(src, session) then
        exports.whip_core:RefundPlayer(receipt)
        return false, 'That did not go through'
    end

    local undelivered, bought = 0, {}
    for _, l in ipairs(lines) do
        local where = exports.whip_core:AddItem(src, l.item, l.qty, nil, { reason = '24/7 shelf purchase', noDrop = true })
        if where then
            bought[#bought + 1] = { itemKey = l.item, price = l.price, amount = l.qty }
        else
            undelivered = undelivered + l.price * l.qty
        end
    end
    if undelivered > 0 then exports.whip_core:RefundPlayer(receipt, undelivered) end
    local store = b.store

    local count, list = 0, {}
    for item, qty in pairs(b.lines) do count = count + qty list[#list + 1] = item end
    table.sort(list)
    baskets[src] = nil
    if clerkPts[src] then RefreshClerk(src) end
    if S.showList then exports.whip_core:HidePlayerText(src) end
    local held = b.hand and handsOf(b.lines) or nil
    after[src] = { store = store, hand = b.hand, list = list, held = held, stuffs = math.min(count, 4),
                   untilMs = GetGameTimer() + 40000 }
    TriggerClientEvent('pure-247:paid', src, { store = store, hand = b.hand == true, stuffs = math.min(count, 4),
        left = held and held.left ~= nil, right = held and held.right ~= nil })
    say(src, ('Paid $%d. Thanks for shopping at 24/7!'):format(total - undelivered), 'success')
    CreateThread(function()
        Whip.core:LogActivity(src, 'pure-247_shelf_purchase', { detail = ('%s: $%d'):format(store, total - undelivered) })
    end)

    TriggerEvent('pure-247:purchased', {
        source = src, shopKey = 'pure-247_' .. store, store = store, paymentMethod = receipt.method, items = bought,
    })
    return true
end

function AddToTab(src, store, item, checkOnly)
    local price = priceAt(store, item)
    if not price then return false, 'That is not for sale here' end
    local b = baskets[src]
    if b and b.store ~= store then
        if checkOnly then b = nil else dropBasket(src) b = nil end
    end
    if not checkOnly then finishAfter(src) end
    local fresh = false
    if not b then

        b = { store = store, lines = {}, hand = true }
        fresh = true
    end
    if b.hand and units(b) + (Goods.isBig(item) and 2 or 1) > (S.handUnits or 2) then
        return false, next(b.lines) and 'Your hands are full: take a basket from the stack by the door'
            or 'That is too big to carry: take a basket from the stack by the door'
    end
    local n = 0 for _ in pairs(b.lines) do n = n + 1 end
    if not b.lines[item] and n >= S.maxLines then return false, 'Your basket is full' end
    if (b.lines[item] or 0) >= S.maxEach then return false, ('That is all the %s you can take'):format(nameOf(item)) end
    if checkOnly then return true end
    if fresh then
        baskets[src] = b
        if not b.hand then holdBasket(src) end
    end
    b.lines[item] = (b.lines[item] or 0) + 1
    if b.hand then holdHands(src, b) end
    syncGoods(src)
    showTill(src)
    if S.showList then
        showList(src)
    else
        local _, total = priced(b)
        say(src, ('+1 %s · $%d, pay the clerk'):format(nameOf(item), total))
    end
    return true
end

Whip.register(function()

    Whip.core:SecureEvent('pure-247:grab', {
        rateLimit = 300, burst = 5,
        params = { { 'store', 'string', 24 }, { 'index', 'id', 1, 200 } },
    }, function(src, _, store, index)
        if not Config.Rooms[store] or not inStore(src, store) then return false, 'You are not in that store' end

        goods[store] = goods[store] or Rooms.goodsAt(store)
        local g = goods[store][index]
        if not g then return false, 'That is not for sale here' end
        local ped = GetPlayerPed(src)
        if ped == 0 or #(GetEntityCoords(ped) - g.coords) > 3.0 then return false, 'Too far from the shelf' end
        return AddToTab(src, store, g.item)
    end)

    Whip.core:SecureEvent('pure-247:takeBasket', {
        rateLimit = 800,
        params = { { 'store', 'string', 24 } },
    }, function(src, _, store)
        if not Config.Rooms[store] or not inStore(src, store) then return false, 'You are not in that store' end
        local b = baskets[src]
        finishAfter(src)
        if b and b.store == store then
            if b.hand then

                b.hand = nil
                holdBasket(src)
                syncGoods(src)
                showList(src)
                return
            end
            if next(b.lines) == nil then dropBasket(src, 'You put the basket back') return end
            return false, 'You already have a basket'
        end
        if b then dropBasket(src) end
        baskets[src] = { store = store, lines = {} }
        holdBasket(src)
        syncGoods(src)
        showList(src)
    end)

    Whip.core:SecureEvent('pure-247:stuffed', {
        rateLimit = 300, burst = 4,
        params = { { 'hand', 'string', 8 } },
    }, function(src, _, hand)
        local a = after[src]
        if not a then return end
        if a.hand then
            if hand ~= 'left' and hand ~= 'right' then return end
            a.held[hand] = nil
            holdHeld(src, a.held)
            if not a.held.left and not a.held.right then after[src] = nil end
            return
        end

        local take = math.ceil(#a.list / math.max(1, a.stuffs))
        for _ = 1, take do table.remove(a.list) end
        a.stuffs = math.max(0, a.stuffs - 1)
        Player(src).state:set('pure-247:goods', #a.list > 0 and a.list or nil, true)
    end)

    Whip.core:SecureEvent('pure-247:returned', { rateLimit = 500 }, function(src)
        local a = after[src]
        if a and not a.hand then finishAfter(src) end
    end)

    Whip.core:SecureCallback('pure-247:prices', { rateLimit = 2000 }, function()
        local out = {}
        for key in pairs(Config.Rooms) do out[key] = Prices end
        return out
    end)
end)

CreateThread(function()
    while true do
        Wait(4000)
        for src, b in pairs(baskets) do
            local st = Rooms.store(b.store)
            local ped = GetPlayerPed(src)
            if ped == 0 or not st then
                dropBasket(src)
            elseif #(GetEntityCoords(ped) - vector3(st.pos.x, st.pos.y, st.pos.z)) > (S.leaveMeters or 25) then
                dropBasket(src, b.hand and 'You left the store: what you had not paid for went back on the shelves'
                    or 'You left the store: your basket went back on the shelves')
            elseif exports.whip_core:GetHeldPropsTag(src) == nil then

                if b.hand then holdHands(src, b) elseif S.basket and S.basket.model then holdBasket(src) end
            end
        end

        local now = GetGameTimer()
        for src, a in pairs(after) do
            if GetPlayerPed(src) == 0 or now > a.untilMs then finishAfter(src) end
        end
    end
end)

AddEventHandler('playerDropped', function() dropBasket(source) after[source] = nil dropClerk(source) end)

CreateThread(function()
    while true do
        Wait(1500)
        local seen = {}
        for _, id in ipairs(GetPlayers()) do
            local src = tonumber(id)
            local ped = GetPlayerPed(src)
            if ped ~= 0 then
                local c = GetEntityCoords(ped)
                for _, st in ipairs(Config.Stores) do
                    if #(c - vector3(st.pos.x, st.pos.y, st.pos.z)) < 15.0 then
                        seen[src] = true
                        local cur = clerkPts[src]

                        local clerk = Clerks and Clerks[st.key]
                        local live = clerk and clerk.netId and NetworkGetEntityFromNetworkId(clerk.netId) ~= 0 and clerk.netId or nil
                        if not cur or cur.store ~= st.key or cur.netId ~= live then RefreshClerk(src, st.key) end
                        break
                    end
                end
            end
        end
        for src in pairs(clerkPts) do
            if not seen[src] then dropClerk(src) end
        end
    end
end)

local POSE_KVP = 'pure-247:basketPose:v2'
local function applyPose(p)
    local B = S.basket
    if not B then return end
    if type(p) == 'table' then
        if type(p.offset) == 'table' then B.offset = p.offset end
        if type(p.rot) == 'table' then B.rot = p.rot end
        if tonumber(p.pose) then B.pose = math.floor(tonumber(p.pose)) end
    end
    GlobalState['pure-247:carryPose'] = B.pose or 1
end
do
    local ok, saved = pcall(json.decode, GetResourceKvpString(POSE_KVP) or 'null')
    applyPose(ok and saved or nil)
end

Whip.command('basketedit', { dev = true, console = false }, function(src)
    local B = S.basket
    if not B or not B.model then return say(src, 'Config.Shelves.basket has no model', 'error') end
    if exports.whip_core:GetHeldPropsTag(src) == FULL_TAG then exports.whip_core:DropHeldProps(src, TAG) end
    TriggerClientEvent('pure-247:basketEdit', src, { model = B.model, bone = B.bone, offset = B.offset, rot = B.rot, pose = B.pose or 1 })
end)

local function num3(t, lim)
    if type(t) ~= 'table' then return nil end
    local out = {}
    for i = 1, 3 do
        local v = tonumber(t[i])
        if not v or v ~= v or math.abs(v) > lim then return nil end
        out[i] = math.floor(v * 1000 + 0.5) / 1000
    end
    return out
end

Whip.register(function()
    Whip.core:SecureEvent('pure-247:saveBasketPose', {
        rateLimit = 2000,
        params = { { 'offset', 'any' }, { 'rot', 'any' }, { 'pose', 'int', 1, 4 } },
    }, function(src, _, offset, rot, pose)
        if not IsPlayerAceAllowed(src, 'whip.devtools') then return false, 'Only staff place the basket' end
        local o, r = num3(offset, 1.0), num3(rot, 360.0)
        if not o or not r then return false, 'That placement could not be read' end
        local p = { offset = o, rot = r, pose = pose }
        SetResourceKvp(POSE_KVP, json.encode(p))
        applyPose(p)
        holdBasket(src)
        local line = ('offset = { %.3f, %.3f, %.3f }, rot = { %.1f, %.1f, %.1f }, pose = %d'):format(o[1], o[2], o[3], r[1], r[2], r[3], pose)
        print('[pure-247] basket hold saved (kept across restarts): ' .. line)
        say(src, 'Basket hold saved for everyone', 'success')
    end)
end)
