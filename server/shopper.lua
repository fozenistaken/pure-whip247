Shopper = {}

local list = {}
local aisles = {}
local COWER = { dict = 'mp_am_hold_up', clip = 'cower_loop' }

local function cfg() return Config.Shopper or {} end

local function facesGoods(p, goods, gap)
    local best, bd = nil, math.huge
    for _, g in ipairs(goods) do
        local d = math.sqrt((g.coords.x - p.x) ^ 2 + (g.coords.y - p.y) ^ 2)
        if d < bd then best, bd = g, d end
    end
    if not best or bd < gap * 0.85 then return false end
    local h = math.rad(p.w)
    return ((best.coords.x - p.x) * -math.sin(h) + (best.coords.y - p.y) * math.cos(h)) / bd >= 0.7
end

local function aislesOf(storeKey)
    if aisles[storeKey] then return aisles[storeKey] end
    local room, st = Config.Rooms[storeKey], Rooms.store(storeKey)
    local out = {}
    if room and st and Racks then
        local gap = tonumber(cfg().rackGap) or 0.75
        local goods = Rooms.goodsAt(storeKey)
        for _, rack in ipairs(Racks.rooms[room.kind] or {}) do
            local sides = {}
            for _, g in ipairs(Racks.models[rack.model] or {}) do
                local side = g.at.x >= 0 and 1 or -1
                local s = sides[side] or { far = 0.0, y = 0.0, n = 0 }
                s.far, s.y, s.n = math.max(s.far, math.abs(g.at.x)), s.y + g.at.y, s.n + 1
                sides[side] = s
            end
            local r = math.rad(rack.yaw)
            local c, n = math.cos(r), math.sin(r)
            for _, side in ipairs({ -1, 1 }) do
                local s = sides[side]
                if s then
                    local sx, sy = side * (s.far + gap), s.y / s.n
                    local p = Rooms.world(storeKey, vector3(rack.at.x + sx * c - sy * n, rack.at.y + sx * n + sy * c, 0.0))
                    local spot = vector4(p.x, p.y, st.pos.z, (rack.yaw + room.yaw + (side == 1 and 180.0 or 0.0) - 90.0) % 360.0)
                    if facesGoods(spot, goods, gap) then out[#out + 1] = spot end
                end
            end
        end
    end
    aisles[storeKey] = out
    return out
end
Shopper.aislesOf = aislesOf

function Shopper.reset() list = {} end

local function pause()
    local p = cfg().pauseSeconds or { 8, 20 }
    local lo = math.max(3, math.floor(tonumber(p[1]) or 8))
    return math.random(lo, math.max(lo, math.floor(tonumber(p[2]) or 20)))
end

function Shopper.ensure(st)
    local S = cfg()
    if not S.enabled then return end
    local s = list[st.key]
    if s and exports.whip_core:GetNpc(s.npcId) then return end
    list[st.key] = nil
    local pts, models = aislesOf(st.key), S.models or {}
    if #pts == 0 or #models == 0 then return end
    local at = math.random(#pts)
    local npcId, netId = Whip.core:SpawnNpc({
        model = models[math.random(#models)], coords = pts[at], behaviour = 'stand',
        conditions = { invincible = true, canMove = true, reacts = false, flees = false },
        interior = true,
    }, { fightBack = false })
    if npcId then
        list[st.key] = { npcId = npcId, netId = netId, at = at, next = os.time() + pause() }
    else
        print(('^3[pure-247] shopper of %s not made: %s^7'):format(st.key, tostring(netId)))
    end
end

function Shopper.startle(storeKey, seconds, leave)
    local s = list[storeKey]
    if not s then return end
    s.hold, s.leave = os.time() + seconds, leave
    Whip.core:SetNpcState(s.npcId, { anim = COWER })
end

local function walkOut(storeKey, s)
    list[storeKey] = nil
    local door = Rooms.at(storeKey, 'stand')
    if door then Whip.core:SetNpcState(s.npcId, { anim = false, post = door, pace = 'walk' }) end
    CreateThread(function()
        Wait(door and 12000 or 0)
        exports.whip_core:DespawnNpc(s.npcId)
    end)
end

CreateThread(function()
    while true do
        Wait(3000)
        local now = os.time()
        for key, s in pairs(list) do
            if s.hold then
                if now >= s.hold then
                    s.hold = nil
                    if s.leave then
                        walkOut(key, s)
                    else
                        Whip.core:SetNpcState(s.npcId, { anim = false })
                        s.next = now + 2
                    end
                end
            elseif now >= s.next then
                local pts = aislesOf(key)
                local i = math.random(#pts)
                if i == s.at and #pts > 1 then i = i % #pts + 1 end
                s.at, s.next = i, now + pause()
                Whip.core:SetNpcState(s.npcId, { post = pts[i], pace = 'walk' })
            end
        end
    end
end)
