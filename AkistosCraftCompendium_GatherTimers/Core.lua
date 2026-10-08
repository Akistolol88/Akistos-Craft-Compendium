-- Core.lua — gather detection and respawn timer storage.
-- Timers live in the account-wide ACCGT_DB as server-time timestamps, so they keep
-- counting while logged out and are visible to every character on the same realm.

ACC.GatherTimers = {}
local GT = ACC.GatherTimers

local PREFIX = "|cff00ccffACC:|r "

-- How long a finished timer stays listed (and pinned on the map) before it is dropped.
local LINGER = 30 * 60

-- minRespawn = earliest possible respawn (nil when unknown), maxRespawn = latest.
-- perSubzone = one timer per subzone (see Groups.lua) instead of one per zone.
GT.KINDS = {
    lotus = {
        label      = "Black Lotus",
        dataTable  = "Herbalism",
        dataName   = "Black Lotus",
        minRespawn = 5 * 60,
        maxRespawn = 45 * 60,
        perSubzone = false,
    },
    thorium = {
        label      = "RTV",
        dataTable  = "Mining",
        dataName   = "Rich Thorium Vein",
        minRespawn = 5 * 60,
        maxRespawn = 25 * 60,
        perSubzone = true,
    },
}

-- Node name as reported by UNIT_SPELLCAST_SENT -> timer kind.
-- These are the enUS names; add the localized names here for other clients.
local NODE_KIND = {
    ["Black Lotus"]                     = "lotus",
    ["Rich Thorium Vein"]               = "thorium",
    ["Ooze Covered Rich Thorium Vein"]  = "thorium",
    ["Truesilver Deposit"]              = "thorium",
    ["Ooze Covered Truesilver Deposit"] = "thorium",
}

-- Truesilver rarely takes the place of a Rich Thorium Vein, but it also has spawns of its
-- own, so these nodes only start a timer when mined on a known Rich Thorium spawn point.
local SPAWN_ONLY = {
    ["Truesilver Deposit"]              = true,
    ["Ooze Covered Truesilver Deposit"] = true,
}

local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function say(msg)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "|cffffff00" .. msg .. "|r")
end

-- Icon comes from the main addon's node data, so the pin matches the browser.
function GT.getIcon(kind)
    local def = GT.KINDS[kind]
    if not def then return FALLBACK_ICON end
    if not def.icon then
        def.icon = FALLBACK_ICON
        for _, node in ipairs((ACC_Data and ACC_Data[def.dataTable]) or {}) do
            if node.name == def.dataName and node.icon then
                def.icon = "Interface\\Icons\\" .. node.icon
                break
            end
        end
    end
    return def.icon
end

function GT.formatTime(seconds)
    if seconds < 0 then seconds = 0 end
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function realmTimers()
    local realm = GetRealmName() or "Unknown"
    ACCGT_DB.realms[realm] = ACCGT_DB.realms[realm] or {}
    return ACCGT_DB.realms[realm]
end

local function timerKey(kind, mapID, subzone)
    if GT.KINDS[kind].perSubzone then
        return kind .. ":" .. mapID .. ":" .. subzone
    end
    return kind .. ":" .. mapID
end

-- "Lake Kel'Theril, Winterspring" for subzone timers, "Winterspring" for zone timers.
function GT.describePlace(entry)
    if GT.KINDS[entry.kind].perSubzone and entry.subzone ~= entry.zone then
        return entry.subzone .. ", " .. entry.zone
    end
    return entry.zone
end

-- ── Timer state ───────────────────────────────────────────────────────────────

-- Returns phase, untilMin, untilMax (seconds, may be negative once passed):
--   "waiting" — cannot have respawned yet
--   "window"  — past the earliest respawn, not yet at the latest
--   "up"      — past the latest respawn
function GT.getState(entry, now)
    local def = GT.KINDS[entry.kind]
    local elapsed = (now or GetServerTime()) - entry.at
    local untilMin = (def.minRespawn or def.maxRespawn) - elapsed
    local untilMax = def.maxRespawn - elapsed
    if untilMax <= 0 then
        return "up", untilMin, untilMax
    elseif untilMin <= 0 then
        return "window", untilMin, untilMax
    end
    return "waiting", untilMin, untilMax
end

-- Short countdown text shared by the map pins and /accgt.
function GT.formatState(entry, now)
    local phase, untilMin, untilMax = GT.getState(entry, now)
    if phase == "up" then
        return "up"
    elseif phase == "window" then
        return "may be up, " .. GT.formatTime(untilMax) .. " at most"
    elseif GT.KINDS[entry.kind].minRespawn then
        return GT.formatTime(untilMin) .. " - " .. GT.formatTime(untilMax)
    end
    return GT.formatTime(untilMax)
end

-- Drops expired timers and returns the rest for this realm, soonest first.
function GT.getTimers()
    local now = GetServerTime()
    local timers = realmTimers()
    local list = {}
    for key, entry in pairs(timers) do
        local def = GT.KINDS[entry.kind]
        if not def or now - entry.at > def.maxRespawn + LINGER then
            timers[key] = nil
        else
            list[#list + 1] = entry
        end
    end
    table.sort(list, function(a, b)
        local _, _, aMax = GT.getState(a, now)
        local _, _, bMax = GT.getState(b, now)
        return aMax < bMax
    end)
    return list
end

-- A vein mined further than this from every known spawn point is not matched by position (% of map height).
local GROUP_RANGE = 5
-- Tighter range for nodes that only count when standing on a known spawn point.
local SPAWN_RANGE = 1.5

-- The group owning the known spawn point nearest to x, y (0-1), if one lies within range.
local function nearestGroup(groups, x, y, range)
    local best, bestDist = nil, range
    if x and y then
        for _, group in ipairs(groups) do
            for _, spawn in ipairs(group.spawns) do
                -- Zone maps are 3:2, so one x percent is 1.5 times as long as one y percent.
                local dx, dy = (x * 100 - spawn[1]) * 1.5, y * 100 - spawn[2]
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < bestDist then
                    best, bestDist = group, dist
                end
            end
        end
    end
    return best
end

-- Finds the spawn group ("subzone") a gather at x, y (0-1) belongs to: the group owning the
-- nearest known spawn point, else the group named like the subzone the player stands in.
-- Position comes first because a group can reach into a neighbouring subzone or a side area.
-- spawnOnly skips the subzone name, so only a gather on a known spawn point finds a group.
function GT.findGroup(mapID, subzone, x, y, spawnOnly)
    local groups = GT.GROUPS and GT.GROUPS[mapID]
    if not groups then return nil end

    local best = nearestGroup(groups, x, y, spawnOnly and SPAWN_RANGE or GROUP_RANGE)
    if best or spawnOnly then return best end

    for _, group in ipairs(groups) do
        if group.name == subzone then return group end
    end
    return nil
end

local function notifyChanged()
    if GT.refreshMap then GT.refreshMap() end
end

-- spawnOnly: do nothing unless the player stands on a known spawn point of the kind.
function GT.startTimer(kind, spawnOnly)
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return end

    local zone = GetRealZoneText() or ""
    local subzone = GetSubZoneText() or ""
    if subzone == "" then subzone = zone end

    local x, y
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if pos then x, y = pos:GetXY() end

    -- Subzone timers are filed under their spawn group and pinned on its map marker.
    if GT.KINDS[kind].perSubzone then
        local group = GT.findGroup(mapID, subzone, x, y, spawnOnly)
        if group then
            subzone, x, y = group.name, group.x / 100, group.y / 100
        elseif spawnOnly then
            return
        end
    end

    local key = timerKey(kind, mapID, subzone)
    local timers = realmTimers()
    local isNew = timers[key] == nil
    timers[key] = {
        kind    = kind,
        mapID   = mapID,
        zone    = zone,
        subzone = subzone,
        x       = x,
        y       = y,
        at      = GetServerTime(),
        by      = UnitName("player"),
    }

    -- A vein takes several hits and each one restarts the timer; only announce the first.
    if isNew then
        say(GT.KINDS[kind].label .. " timer started for " .. GT.describePlace(timers[key])
            .. " (" .. GT.formatState(timers[key]) .. ").")
    end
    notifyChanged()
end

function GT.clearTimers()
    local realm = GetRealmName() or "Unknown"
    ACCGT_DB.realms[realm] = {}
    notifyChanged()
end

-- ── Alerts ────────────────────────────────────────────────────────────────────

-- entry.alerted is saved with the timer so an alert fires once, whichever
-- character happens to be online when the phase changes.
local function checkAlerts()
    local now = GetServerTime()
    for _, entry in ipairs(GT.getTimers()) do
        local def = GT.KINDS[entry.kind]
        local phase = GT.getState(entry, now)
        local place = GT.describePlace(entry)
        if phase == "up" and entry.alerted ~= "up" then
            entry.alerted = "up"
            say(def.label .. " in " .. place .. " should be up.")
        elseif phase == "window" and not entry.alerted then
            entry.alerted = "window"
            say(def.label .. " in " .. place .. " can respawn from now.")
        end
    end
end

-- ── Gather detection ──────────────────────────────────────────────────────────

-- UNIT_SPELLCAST_SENT is the only event that carries the node's name, so remember
-- the cast there and start the timer once the same cast succeeds.
local pendingCast, pendingKind, pendingSpawnOnly

local function onSpellcastSent(unit, target, castGUID)
    if unit ~= "player" then return end
    local kind = target and NODE_KIND[target]
    if kind then
        pendingCast, pendingKind, pendingSpawnOnly = castGUID, kind, SPAWN_ONLY[target]
    else
        pendingCast, pendingKind, pendingSpawnOnly = nil, nil, nil
    end
end

local function onSpellcastSucceeded(unit, castGUID)
    if unit ~= "player" or not pendingCast or castGUID ~= pendingCast then return end
    local kind, spawnOnly = pendingKind, pendingSpawnOnly
    pendingCast, pendingKind, pendingSpawnOnly = nil, nil, nil
    GT.startTimer(kind, spawnOnly)
end

local function onSpellcastFailed(unit, castGUID)
    if unit == "player" and castGUID == pendingCast then
        pendingCast, pendingKind, pendingSpawnOnly = nil, nil, nil
    end
end

-- ── Slash command ─────────────────────────────────────────────────────────────

local function listTimers()
    local list = GT.getTimers()
    if #list == 0 then
        say("No gather timers running.")
        return
    end
    say("Gather timers:")
    for _, entry in ipairs(list) do
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffffff" .. GT.KINDS[entry.kind].label .. "|r - "
            .. GT.describePlace(entry) .. ": " .. GT.formatState(entry)
            .. " |cff888888(" .. (entry.by or "?") .. ")|r")
    end
end

SLASH_ACCGT1 = "/accgt"
SlashCmdList["ACCGT"] = function(msg)
    msg = (msg or ""):lower()
    local testKind = msg:match("^test%s+(%a+)$")
    if msg == "clear" then
        GT.clearTimers()
        say("Gather timers cleared.")
    elseif testKind and GT.KINDS[testKind] then
        -- Starts a timer where you stand without needing the real node.
        GT.startTimer(testKind)
    elseif msg == "" then
        listTimers()
    else
        say("Gather timer commands:")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000/accgt|r |cffffff00— list running timers|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000/accgt clear|r |cffffff00— remove all timers on this realm|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000/accgt test lotus|r |cffffff00or|r |cffff0000/accgt test thorium|r"
            .. " |cffffff00— start a test timer where you stand|r")
    end
end

-- ── Events ────────────────────────────────────────────────────────────────────

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if ... ~= "AkistosCraftCompendium_GatherTimers" then return end
        ACCGT_DB = ACCGT_DB or {}
        ACCGT_DB.realms = ACCGT_DB.realms or {}

    elseif event == "PLAYER_LOGIN" then
        if #GT.getTimers() > 0 then listTimers() end
        C_Timer.NewTicker(1, checkAlerts)

    elseif event == "UNIT_SPELLCAST_SENT" then
        onSpellcastSent(...)

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        onSpellcastSucceeded(...)

    else
        onSpellcastFailed(...)
    end
end)
