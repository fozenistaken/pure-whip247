Clerks = {}

local COUNTER = {}
for _, it in ipairs(Config.Items) do
    if it.counter then COUNTER[#COUNTER + 1] = it end
end
local busy = {}

local GIVE = { dict = 'pure247_clerk', clip = 'clerk_cig' }
local GRAB_MS, HANDOVER_MS, DONE_MS = 2330, 6130, 6950

local function ask(src, storeKey, item)
    local c = Clerks[storeKey]
    if not c then return false, 'Nobody is at the counter' end
    if busy[storeKey] then return false, 'The clerk is busy' end
    local ok, why = AddToTab(src, storeKey, item, true)
    if not ok then return false, why end
    busy[storeKey] = true
    local model
    for _, it in ipairs(COUNTER) do if it.key == item then model = it.prop end end
    Whip.core:SetNpcState(c.npcId, { anim = GIVE })
    TriggerClientEvent('pure-247:clerkGive', -1, c.netId, model, GRAB_MS, HANDOVER_MS)
    TriggerClientEvent('pure-247:receive', src, c.netId, HANDOVER_MS)
    CreateThread(function()
        Wait(HANDOVER_MS)
        if GetPlayerPed(src) ~= 0 then
            local added, err = AddToTab(src, storeKey, item)
            if not added then exports.whip_core:NotifyPlayer(src, err or 'You could not take it', 'error') end
        end
        Wait(DONE_MS - HANDOVER_MS)
        Whip.core:SetNpcState(c.npcId, { anim = false })
        busy[storeKey] = nil
    end)
end

function ClerkCounter()
    local brands = {}
    for _, it in ipairs(COUNTER) do
        if #brands < 6 then brands[#brands + 1] = { id = it.key, label = ('%s  $%d'):format(it.name, it.price) } end
    end
    return brands
end
ClerkAsk = function(src, storeKey, item) return ask(src, storeKey, item) end

local function pick(weights)
    local total = 0
    for _, w in pairs(weights) do total = total + math.max(0, tonumber(w) or 0) end
    if total <= 0 then return 'nothing' end
    local r = math.random() * total
    for _, mode in ipairs({ 'shout', 'cower', 'chase', 'nothing' }) do
        r = r - math.max(0, tonumber(weights[mode]) or 0)
        if r <= 0 then return mode end
    end
    return 'nothing'
end

local function speak(st, netId, line)
    local at = vector3(st.pos.x, st.pos.y, st.pos.z)
    for _, id in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(id)
        if ped ~= 0 and #(GetEntityCoords(ped) - at) < 60.0 then
            TriggerClientEvent('pure-247:clerkSpeak', tonumber(id), netId, line)
        end
    end
end

local function settle(storeKey, c, patch)
    if Clerks[storeKey] ~= c then return end
    patch.conditions = patch.conditions or {}
    patch.conditions.invincible = true
    Whip.core:SetNpcState(c.npcId, patch)
    busy[storeKey] = nil
end

function ClerkReact(storeKey, src)
    local S = Config.Shoplift
    local c, st = Clerks[storeKey], Rooms.store(storeKey)
    if not c or not st or busy[storeKey] or not StoreOpen(storeKey) then return 'nothing' end
    local mode = pick(S.reactions or {})
    if mode == 'nothing' then return mode end
    busy[storeKey] = true
    Whip.core:SetNpcState(c.npcId, { conditions = { invincible = false } })
    if mode == 'shout' then
        Whip.core:SetNpcState(c.npcId, { anim = { dict = 'mp_am_hold_up', clip = 'wary_loop' } })
        speak(st, c.netId, 'GENERIC_INSULT_HIGH')
        exports.whip_core:NotifyPlayer(src, 'The clerk yells: "Hey! You didn\'t pay for that!"', 'error')
        CreateThread(function()
            Wait(6000)
            settle(storeKey, c, { anim = false })
        end)
    elseif mode == 'cower' then
        Whip.core:SetNpcState(c.npcId, { anim = { dict = 'mp_am_hold_up', clip = 'cower_loop' } })
        speak(st, c.netId, 'GENERIC_FRIGHTENED_HIGH')
        CreateThread(function()
            Wait(15000)
            settle(storeKey, c, { anim = false })
        end)
    else
        local ok, why = Whip.core:SetNpcState(c.npcId, { conditions = { canMove = true }, hostileTo = { people = { src } },
            range = math.max(10.0, math.min(60.0, S.chaseMeters or 30.0)), pace = 'run' })
        if not ok then
            print(('^3[pure-247] clerk of %s cannot chase: %s^7'):format(storeKey, tostring(why)))
            settle(storeKey, c, {})
            return 'nothing'
        end
        speak(st, c.netId, 'GENERIC_INSULT_HIGH')
        exports.whip_core:NotifyPlayer(src, 'The clerk comes after you!', 'error')
        CreateThread(function()
            Wait(math.floor(math.max(5, math.min(60, S.chaseSeconds or 20)) * 1000))
            Whip.core:SetNpcState(c.npcId, { hostileTo = false, range = false, pace = 'walk', post = st.pos })
            Wait(15000)
            settle(storeKey, c, { conditions = { canMove = false } })
        end)
    end
    return mode
end

local function spawnOne(st)
    local npcId, netId = Whip.core:SpawnNpc({
        model = Config.Keeper, coords = st.pos, behaviour = 'stand',
        conditions = { invincible = true, canMove = false, reacts = false, flees = false },
        interior = true,
    }, { fightBack = false })
    if npcId then
        Clerks[st.key] = { npcId = npcId, netId = netId }
    else
        print(('^3[pure-247] clerk of %s not made: %s^7'):format(st.key, tostring(netId)))
    end
end

local downUntil = {}

function StoreOpen(storeKey)
    return not (downUntil[storeKey] and os.time() < downUntil[storeKey])
end

local function syncClosed()
    local list = {}
    for key, t in pairs(downUntil) do if os.time() < t then list[key] = t end end
    GlobalState['pure-247:closed'] = list
end

local function spawnAll()
    for _, st in ipairs(Config.Stores) do
        local c = Clerks[st.key]
        if StoreOpen(st.key) and (not c or not exports.whip_core:GetNpc(c.npcId)) then
            downUntil[st.key] = nil
            spawnOne(st)
        end
    end
    syncClosed()
end

AddEventHandler('whip_core:npc:killed', function(e)
    if type(e) ~= 'table' then return end
    for key, c in pairs(Clerks) do
        if c.npcId == e.npcId then
            Clerks[key] = nil
            busy[key] = nil
            downUntil[key] = os.time() + math.floor(math.max(1, math.min(60, Config.ClerkDownMinutes or 10)) * 60)
            syncClosed()
            if StoreClosed then StoreClosed(key) end
            print(('[pure-247] the clerk of %s was killed: the store is closed for %d minutes'):format(key, math.floor(Config.ClerkDownMinutes or 10)))
            return
        end
    end
end)

local function blips()
    if (Config.Blip.sprite or 0) <= 0 then return end
    for _, st in ipairs(Config.Stores) do
        exports.whip_core:ShowBlip('everyone', 'store:' .. st.key, {
            coords = vector3(st.pos.x, st.pos.y, st.pos.z), label = st.name,
            sprite = Config.Blip.sprite, color = Config.Blip.color, shortRange = true,
        })
    end
end

Whip.register(function()
    Clerks = {}
    blips()
    if #GetPlayers() > 0 then spawnAll() end
end)
AddEventHandler('whip_core:player:loaded', function() spawnAll() end)

CreateThread(function()
    while true do
        Wait(30000)
        if #GetPlayers() > 0 then
            spawnAll()
        end
    end
end)
