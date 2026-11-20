Rooms = {}

local function toWorld(room, x, y, z)
    local r = math.rad(room.yaw)
    local c, n = math.cos(r), math.sin(r)
    return vector3(room.x + x * c - y * n, room.y + x * n + y * c, room.z + z)
end

function Rooms.world(storeKey, p)
    local room = Config.Rooms[storeKey]
    return room and toWorld(room, p.x, p.y, p.z) or nil
end

function Rooms.goodsAt(storeKey)
    local room = Config.Rooms[storeKey]
    if not room or not Racks then return {} end
    local out = {}
    for _, rack in ipairs(Racks.rooms[room.kind] or {}) do
        local r = math.rad(rack.yaw)
        local c, n = math.cos(r), math.sin(r)
        for _, g in ipairs(Racks.models[rack.model] or {}) do
            local lx = rack.at.x + g.at.x * c - g.at.y * n
            local ly = rack.at.y + g.at.x * n + g.at.y * c
            out[#out + 1] = { item = g.item, coords = toWorld(room, lx, ly, rack.at.z + g.at.z) }
        end
    end
    for _, s in ipairs(Racks.spots[room.kind] or {}) do
        out[#out + 1] = { item = s.item, coords = toWorld(room, s.at.x, s.at.y, s.at.z) }
    end
    return out
end

function Rooms.at(storeKey, spot)
    local room = Config.Rooms[storeKey]
    local s = room and Config.RoomSpots[room.kind] and Config.RoomSpots[room.kind][spot]
    if type(s) ~= 'vector3' then return nil end
    return toWorld(room, s.x, s.y, s.z)
end

function Rooms.row(storeKey, cat, n)
    local room = Config.Rooms[storeKey]
    local r = room and Config.RoomSpots[room.kind] and Config.RoomSpots[room.kind][cat]
    if type(r) ~= 'table' or not r.at then return nil end
    local out = {}
    for i = 1, n do
        local d = (i - (n + 1) / 2) * r.spacing
        out[i] = {
            coords = toWorld(room, r.at.x + r.axis.x * d, r.at.y + r.axis.y * d, r.at.z),
            heading = ((r.face or 0.0) + room.yaw) % 360.0,
        }
    end
    return out
end

function Rooms.store(storeKey)
    for _, st in ipairs(Config.Stores) do
        if st.key == storeKey then return st end
    end
    return nil
end

local CORE_NAMES = { drink = 'Water', food = 'Burger' }
function Rooms.goods(cat)
    local list = {}
    for _, it in ipairs(Config.Items) do
        if it.cat == cat then list[#list + 1] = { key = it.key, name = it.name, picture = it.picture, prop = it.prop or it.picture } end
    end
    local core = {}
    for key, it in pairs(Config.CoreItems) do if it.cat == cat then core[#core + 1] = key end end
    table.sort(core)
    for _, key in ipairs(core) do
        list[#list + 1] = { key = key, name = CORE_NAMES[key] or key, core = true, prop = Config.ShelfProps and Config.ShelfProps[key] }
    end
    return list
end
