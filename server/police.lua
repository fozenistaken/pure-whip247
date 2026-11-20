Police = {}

local lastCall = {}

local function cfg() return Config.Shoplift and Config.Shoplift.police or nil end

function Police.onDuty()
    local P = cfg()
    if not P then return 0 end
    local seen, n = {}, 0
    for _, job in ipairs(P.jobs or {}) do
        local ok, list = pcall(function() return Whip.core:GetClockedOnEmployees(job) end)
        for _, e in ipairs(ok and type(list) == 'table' and list or {}) do
            if e.source and not seen[e.source] then seen[e.source] = true n = n + 1 end
        end
    end
    return n
end

function Police.enough()
    local P = cfg()
    return P ~= nil and Police.onDuty() >= (tonumber(P.minOnDuty) or 0)
end

function Police.call(store, kind, info, delaySeconds, at)
    local P = cfg()
    if not P or not P.resource or GetResourceState(P.resource) ~= 'started' then return end
    local st = Rooms.store(store)
    if not st then return end
    at = at or vector3(st.pos.x, st.pos.y, st.pos.z)
    local call = ({
        theft = { code = P.code, title = 'Shoplifting at a 24/7', priority = P.priority },
        held = { code = P.code, title = 'Shoplifter held at a 24/7', priority = 'high' },
        attacked = { code = P.violentCode, title = 'Clerk attacked at a 24/7', priority = 'high' },
        killed = { code = P.violentCode, title = 'Clerk down at a 24/7', priority = 'high' },
    })[kind]
    if not call then return end
    local key, now = store .. ':' .. kind, os.time()
    if lastCall[key] and now - lastCall[key] < (tonumber(P.cooldown) or 60) then return end
    lastCall[key] = now
    CreateThread(function()
        Wait(math.floor(math.max(0, tonumber(delaySeconds) or 0) * 1000))
        local ok, err = pcall(function()
            return exports[P.resource]:SendAlert({
                code = call.code or '10-31', title = call.title, priority = call.priority or 'normal',
                coords = at, info = { info },
            })
        end)
        if not ok then print(('^3[pure-247] police call failed: %s^7'):format(tostring(err))) end
    end)
end
