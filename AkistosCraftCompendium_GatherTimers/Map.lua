-- Map.lua — world map display for gather timers.
-- Every Rich Thorium spawn group of the open zone is circled in dark green with its name in
-- the middle; a running timer is shown in red under the name of the group it belongs to.
-- Zone-wide timers (Black Lotus) of every zone are listed next to the map's "Zoom Out"
-- button, clear of the group names, whichever map is open.

local GT = ACC.GatherTimers

local MARKER_SIZE = 10
local ICON_SIZE = 20
-- Above the map's own pins, which Blizzard stacks upward from the canvas level.
local PIN_LEVEL_OFFSET = 3000

local MARKER_COLOR = { 0, 0.4, 0 }
-- Yellow, for the subzone names.
local LABEL_COLOR = { 1, 1, 0 }
local TIMER_COLOR = "ffff1a1a"
-- Epic item purple, for a node that should be up.
local UP_COLOR = "ffa335ee"
-- Uncommon item green, for a node that may already be up and for the node name in the banner.
local WINDOW_COLOR = "ff1eff00"
local BANNER_LABEL_COLOR = WINDOW_COLOR

local LABEL_ICON_SIZE = 14
local BANNER_ICON_SIZE = 16
local BANNER_OFFSET = 12
local BANNER_BUTTON_GAP = 10
local BANNER_ROW_GAP = 4
-- Points added to the font of a countdown.
local TIMER_FONT_BUMP = 2

-- Rich Thorium node icon shipped with the main addon (from GatherMate2's artwork).
local THORIUM_ICON = "Interface\\AddOns\\AkistosCraftCompendium\\Media\\RichThorium"

local OUTLINE_THICKNESS = 2
-- Below the pins, so markers and text stay readable on top of the outlines.
local OUTLINE_LEVEL_OFFSET = 2950

local pins = {}
local outlineFrame
local outlineLines = {}
local outlinedMapID
local banner

-- Inline texture escape for an item icon, trimmed like the pin icons.
local function iconText(icon, size)
    return "|T" .. icon .. ":" .. size .. ":" .. size .. ":0:0:64:64:5:59:5:59|t"
end

-- Countdown text of a timer: the time left is red, "may be up" in front of it is green and
-- "up" is purple.
local function stateText(entry, now)
    local phase, _, untilMax = GT.getState(entry, now)
    if phase == "window" then
        return "|c" .. WINDOW_COLOR .. "may be up,|r |c" .. TIMER_COLOR
            .. GT.formatTime(untilMax) .. " at most|r"
    end
    local color = phase == "up" and UP_COLOR or TIMER_COLOR
    return "|c" .. color .. GT.formatState(entry, now) .. "|r"
end

-- Icon in front of a Rich Thorium group name. A whole node icon, so none of the trimming an
-- item icon gets.
local function thoriumLabelIcon()
    return "|T" .. THORIUM_ICON .. ":" .. LABEL_ICON_SIZE .. "|t"
end

-- The "Zoom Out" button above the map. Looked up by name first, then by its caption in case
-- the client names it differently.
local function findZoomOutButton()
    if WorldMapZoomOutButton then return WorldMapZoomOutButton end
    for _, child in ipairs({ WorldMapFrame:GetChildren() }) do
        if child.GetText and child:GetText() == ZOOM_OUT then return child end
    end
    return nil
end

-- Makes the countdown of a timer stand out from the name it belongs to.
local function enlarge(fontString)
    local font, size, flags = fontString:GetFont()
    if font then fontString:SetFont(font, size + TIMER_FONT_BUMP, flags) end
end

-- Zone timers to the right of the map's "Zoom Out" button, one per row going down. Without
-- that button they go in the top left corner of the map instead, hung off the scroll
-- container so they stay put while the map is zoomed or dragged.
-- entries is a list of { label = ..., timer = ... } texts.
local function showBanner(entries)
    if not banner then
        if #entries == 0 then return end
        local button = findZoomOutButton()
        local parent = button and WorldMapFrame or WorldMapFrame.ScrollContainer or WorldMapFrame:GetCanvas()
        banner = CreateFrame("Frame", nil, parent)
        banner:SetAllPoints(parent)
        banner:SetFrameLevel(math.min(parent:GetFrameLevel() + PIN_LEVEL_OFFSET, 9000))
        banner.button = button
        banner.rows = {}
    end

    for i, entry in ipairs(entries) do
        local row = banner.rows[i]
        if not row then
            local previous = banner.rows[i - 1]
            row = {}
            -- The name and its countdown are separate strings so the countdown can be larger.
            row.label = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            if previous then
                row.label:SetPoint("TOPLEFT", previous.label, "BOTTOMLEFT", 0, -BANNER_ROW_GAP)
            elseif banner.button then
                row.label:SetPoint("LEFT", banner.button, "RIGHT", BANNER_BUTTON_GAP, 0)
            else
                row.label:SetPoint("TOPLEFT", banner, "TOPLEFT", BANNER_OFFSET, -BANNER_OFFSET)
            end
            row.timer = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.timer:SetPoint("LEFT", row.label, "RIGHT", 4, 0)
            enlarge(row.timer)
            banner.rows[i] = row
        end
        row.label:SetText(entry.label)
        row.timer:SetText(entry.timer)
    end
    for i = #entries + 1, #banner.rows do
        banner.rows[i].label:SetText("")
        banner.rows[i].timer:SetText("")
    end
end

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
    pin.label:SetTextColor(LABEL_COLOR[1], LABEL_COLOR[2], LABEL_COLOR[3])

    pin.timer = pin:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pin.timer:SetPoint("TOP", pin.label, "BOTTOM", 0, -1)
    enlarge(pin.timer)

    pins[index] = pin
    return pin
end

-- icon is a texture path, MARKER for the dark green square, or nil for text only.
-- label and timerText may be nil for an icon without text.
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

    pin.label:SetText(label or "")
    pin.timer:SetText(timerText or "")
    pin:Show()
end

function GT.refreshMap()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end

    local mapID = WorldMapFrame:GetMapID()
    local now = GetServerTime()
    local used = 0

    drawOutlines(mapID)

    -- Subzone timers of this map are looked up by group name below; zone timers are listed
    -- for every zone, as several can be running at once.
    local groupTimers, zoneTimers = {}, {}
    for _, entry in ipairs(GT.getTimers()) do
        if not GT.KINDS[entry.kind].perSubzone then
            zoneTimers[#zoneTimers + 1] = entry
        elseif entry.mapID == mapID then
            groupTimers[entry.subzone] = entry
        end
    end

    local groupIcon = thoriumLabelIcon()
    for _, group in ipairs((GT.GROUPS and GT.GROUPS[mapID]) or {}) do
        local entry = groupTimers[group.name]
        groupTimers[group.name] = nil
        used = used + 1
        showPin(used, group.x / 100, group.y / 100, nil, groupIcon .. " " .. group.name,
            entry and stateText(entry, now))
    end

    -- Veins mined outside every known group have no outline, so they get a square where they were mined.
    for _, entry in pairs(groupTimers) do
        if entry.x and entry.y then
            used = used + 1
            showPin(used, entry.x, entry.y, MARKER,
                groupIcon .. " " .. entry.subzone,
                stateText(entry, now))
        end
    end

    -- Zone timers keep their icon where the node was picked, on the map of their own zone;
    -- the text goes next to the "Zoom Out" button, where it cannot cover a group name.
    local bannerEntries = {}
    for _, entry in ipairs(zoneTimers) do
        local icon = GT.getIcon(entry.kind)
        if entry.mapID == mapID and entry.x and entry.y then
            used = used + 1
            showPin(used, entry.x, entry.y, icon)
        end
        bannerEntries[#bannerEntries + 1] = {
            label = iconText(icon, BANNER_ICON_SIZE) .. " |c" .. BANNER_LABEL_COLOR
                .. GT.KINDS[entry.kind].label .. " - " .. GT.describePlace(entry) .. ":|r",
            timer = stateText(entry, now),
        }
    end
    showBanner(bannerEntries)

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
