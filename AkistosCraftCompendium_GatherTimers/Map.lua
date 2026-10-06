-- Map.lua — world map display for gather timers.
-- Every Rich Thorium spawn group of the open zone is circled in dark green with its name in
-- the middle; a running timer is shown in red under the name of the group it belongs to.

local GT = ACC.GatherTimers

local MARKER_SIZE = 10
local ICON_SIZE = 20
-- Above the map's own pins, which Blizzard stacks upward from the canvas level.
local PIN_LEVEL_OFFSET = 3000

local MARKER_COLOR = { 0, 0.4, 0 }
local TIMER_COLOR = { 1, 0.1, 0.1 }

local OUTLINE_THICKNESS = 2
-- Below the pins, so markers and text stay readable on top of the outlines.
local OUTLINE_LEVEL_OFFSET = 2950

local pins = {}
local outlineFrame
local outlineLines = {}
local outlinedMapID

-- Draws the closed outline of every spawn group of the map. The lines are anchored to the
-- canvas in canvas units, so they only need redrawing when another map is opened.
local function drawOutlines(mapID)
    if outlinedMapID == mapID then return end
    outlinedMapID = mapID

    local canvas = WorldMapFrame:GetCanvas()
    if not outlineFrame then
        outlineFrame = CreateFrame("Frame", nil, canvas)
        outlineFrame:SetAllPoints(canvas)
        outlineFrame:SetFrameLevel(math.min(canvas:GetFrameLevel() + OUTLINE_LEVEL_OFFSET, 8900))
    end
    -- Line objects are missing on very old clients; the markers still work without them.
    if not outlineFrame.CreateLine then return end

    local width, height = canvas:GetWidth(), canvas:GetHeight()
    local used = 0
    for _, group in ipairs((GT.GROUPS and GT.GROUPS[mapID]) or {}) do
        local points = group.outline or {}
        for i = 1, #points do
            local from, to = points[i], points[i % #points + 1]
            used = used + 1
            local line = outlineLines[used]
            if not line then
                line = outlineFrame:CreateLine(nil, "ARTWORK")
                line:SetThickness(OUTLINE_THICKNESS)
                line:SetColorTexture(MARKER_COLOR[1], MARKER_COLOR[2], MARKER_COLOR[3])
                outlineLines[used] = line
            end
            line:SetStartPoint("TOPLEFT", canvas, from[1] / 100 * width, -from[2] / 100 * height)
            line:SetEndPoint("TOPLEFT", canvas, to[1] / 100 * width, -to[2] / 100 * height)
            line:Show()
        end
    end
    for i = used + 1, #outlineLines do
        outlineLines[i]:Hide()
    end
end

local function getPin(index)
    local pin = pins[index]
    if pin then return pin end

    local canvas = WorldMapFrame:GetCanvas()
    pin = CreateFrame("Frame", nil, canvas)
    pin:SetFrameLevel(math.min(canvas:GetFrameLevel() + PIN_LEVEL_OFFSET, 9000))

    -- Black edge so the dark green stays visible on dark map art.
    pin.border = pin:CreateTexture(nil, "BACKGROUND")
    pin.border:SetPoint("TOPLEFT", pin, "TOPLEFT", -1, 1)
    pin.border:SetPoint("BOTTOMRIGHT", pin, "BOTTOMRIGHT", 1, -1)
    pin.border:SetColorTexture(0, 0, 0)

    pin.icon = pin:CreateTexture(nil, "ARTWORK")
    pin.icon:SetAllPoints(pin)

    pin.label = pin:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pin.label:SetPoint("TOP", pin, "BOTTOM", 0, -2)

    pin.timer = pin:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pin.timer:SetPoint("TOP", pin.label, "BOTTOM", 0, -1)
    pin.timer:SetTextColor(TIMER_COLOR[1], TIMER_COLOR[2], TIMER_COLOR[3])

    pins[index] = pin
    return pin
end

-- icon is a texture path, MARKER for the dark green square, or nil for text only.
local MARKER = true

local function showPin(index, x, y, icon, label, timerText)
    local canvas = WorldMapFrame:GetCanvas()
    local pin = getPin(index)
    local size = (icon == MARKER and MARKER_SIZE) or (icon and ICON_SIZE) or 1

    pin:SetWidth(size)
    pin:SetHeight(size)
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", canvas, "TOPLEFT", x * canvas:GetWidth(), -y * canvas:GetHeight())

    pin.icon:SetShown(icon ~= nil)
    pin.border:SetShown(icon ~= nil)
    if icon == MARKER then
        pin.icon:SetColorTexture(MARKER_COLOR[1], MARKER_COLOR[2], MARKER_COLOR[3])
        pin.icon:SetTexCoord(0, 1, 0, 1)
    elseif icon then
        pin.icon:SetTexture(icon)
        pin.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    pin.label:SetText(label)
    pin.timer:SetText(timerText or "")
    pin:Show()
end

function GT.refreshMap()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end

    local mapID = WorldMapFrame:GetMapID()
    local now = GetServerTime()
    local used = 0

    drawOutlines(mapID)

    -- Timers of this map; subzone timers are looked up by group name below.
    local groupTimers, otherTimers = {}, {}
    for _, entry in ipairs(GT.getTimers()) do
        if entry.mapID == mapID then
            if GT.KINDS[entry.kind].perSubzone then
                groupTimers[entry.subzone] = entry
            else
                otherTimers[#otherTimers + 1] = entry
            end
        end
    end

    local groupLabel = GT.KINDS.thorium.label
    for _, group in ipairs((GT.GROUPS and GT.GROUPS[mapID]) or {}) do
        local entry = groupTimers[group.name]
        groupTimers[group.name] = nil
        used = used + 1
        showPin(used, group.x / 100, group.y / 100, nil, groupLabel .. " - " .. group.name,
            entry and GT.formatState(entry, now))
    end

    -- Veins mined outside every known group have no outline, so they get a square where they were mined.
    for _, entry in pairs(groupTimers) do
        if entry.x and entry.y then
            used = used + 1
            showPin(used, entry.x, entry.y, MARKER, GT.KINDS[entry.kind].label .. " - " .. entry.subzone,
                GT.formatState(entry, now))
        end
    end

    for _, entry in ipairs(otherTimers) do
        if entry.x and entry.y then
            used = used + 1
            showPin(used, entry.x, entry.y, GT.getIcon(entry.kind), GT.KINDS[entry.kind].label,
                GT.formatState(entry, now))
        end
    end

    for i = used + 1, #pins do
        pins[i]:Hide()
    end
end

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function()
    if not WorldMapFrame then return end

    hooksecurefunc(WorldMapFrame, "OnMapChanged", GT.refreshMap)

    -- Child of the map, so OnUpdate only runs while the map is open.
    local ticker = CreateFrame("Frame", nil, WorldMapFrame)
    local sinceRefresh = 0
    ticker:SetScript("OnShow", function()
        sinceRefresh = 0
        GT.refreshMap()
    end)
    ticker:SetScript("OnUpdate", function(_, elapsed)
        sinceRefresh = sinceRefresh + elapsed
        if sinceRefresh >= 1 then
            sinceRefresh = 0
            GT.refreshMap()
        end
    end)
end)
