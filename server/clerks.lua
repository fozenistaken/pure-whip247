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

local function spawnAll()
    for _, st in ipairs(Config.Stores) do
        local c = Clerks[st.key]
        if not c or not exports.whip_core:GetNpc(c.npcId) then spawnOne(st) end
    end
end

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
