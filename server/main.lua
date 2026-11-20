local PICTURES = '@whip_media_props/img/props/%s.webp'

Prices = {}
for key, it in pairs(Config.CoreItems) do Prices[key] = it.price end
for _, it in ipairs(Config.Items) do Prices[it.key] = it.price end

local function feed(def)
    return function(source)
        local hunger = Whip.core:GetItemSetting(def.key, 'hunger') or def.hunger or 0
        local thirst = Whip.core:GetItemSetting(def.key, 'thirst') or def.thirst or 0
        local ok, why = true, nil
        if hunger > 0 then ok, why = Whip.core:AddStat(source, 'hunger', hunger, 'item:' .. def.key) end
        if ok and thirst > 0 then ok, why = Whip.core:AddStat(source, 'thirst', thirst, 'item:' .. def.key) end
        return ok, why
    end
end

local function open(def)
    return function(source)
        local o = def.opens
        local fits, why = Whip.core:CanFitItem(source, o.item, o.amount)
        if not fits then return false, why or 'No room for them' end
        local ok, err = Whip.core:AddItem(source, o.item, o.amount, nil, { reason = 'opened ' .. def.key })
        if not ok then return false, err or 'Could not open it' end
        return true
    end
end

local function smoke(def)
    return function(source)
        if exports.whip_core:GetHeldPropsTag(source) then return false, 'Your hands are full' end
        TriggerClientEvent('pure-247:smoke', source, def.smoke)
        return true
    end
end

local function registerItems()
    for _, it in ipairs(Config.Items) do
        local edible = (it.hunger or 0) > 0 or (it.thirst or 0) > 0
        local special = it.opens ~= nil or it.smoke ~= nil
        local ok, why = Whip.core:RegisterItem(it.key, {
            name = it.name, desc = it.desc, weight = it.weight or 0.2, type = edible and 'consumable' or 'misc',
            stack = true, maxStack = it.maxStack or 20, usable = edible or special, cooldown = (edible or special) and 3 or nil,
            prop = it.prop or it.picture,

            image = it.picture and PICTURES:format(it.picture) or nil,
            settings = edible and {
                { key = 'hunger', type = 'int', default = it.hunger or 0, min = 0, max = 100, label = 'Hunger restored' },
                { key = 'thirst', type = 'int', default = it.thirst or 0, min = 0, max = 100, label = 'Thirst restored' },
            } or nil,
        })
        if not ok then Whip.startProblem('item %s refused: %s', it.key, tostring(why)) end
        if edible then Whip.core:RegisterUseHandler(it.key, feed(it)) end
        if it.opens then Whip.core:RegisterUseHandler(it.key, open(it)) end
        if it.smoke then Whip.core:RegisterUseHandler(it.key, smoke(it)) end
    end
end

local function removeOldShops()
    CreateThread(function()
        for _, st in ipairs(Config.Stores) do
            local shop = exports.whip_core:GetShop({ key = 'pure-247_' .. st.key })
            if shop then
                local ok, why = exports.whip_core:DeleteShop(shop.shopId)
                print(ok and ('[pure-247] removed the old WHIP shop of %s (the clerk sells now)'):format(st.key)
                    or ('^3[pure-247] old WHIP shop of %s not removed: %s^7'):format(st.key, tostring(why)))
            end
        end
    end)
end

exports('GetStores', function()
    local out = {}
    for _, st in ipairs(Config.Stores) do
        local goods = {}
        for item, price in pairs(Prices) do goods[item] = price end
        out[#out + 1] = { key = 'pure-247_' .. st.key, name = st.name, coords = vector3(st.pos.x, st.pos.y, st.pos.z), goods = goods }
    end
    return out
end)

Whip.register(function()
    registerItems()
    removeOldShops()
end)

Whip.sayStarted()
