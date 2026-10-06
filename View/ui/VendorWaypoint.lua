-- VendorWaypoint.lua — one marked recipe vendor at a time.
-- Clicking a vendor in the recipe detail panel (or a vendor pin on the world map) marks it:
-- a highlighted marker appears on the world map and on the minimap, a "Target" button appears
-- on screen and, within ARROW_RANGE yards, an arrow points the way. Targeting the vendor puts the Square
-- raid marker on them. The mark persists per character in ACC_CharacterData.vendorWaypoint
-- and is removed when the vendor's shop window opens.

local ARROW_RANGE = 100      -- yards; the arrow only shows this close to the vendor
local RAID_MARKER = 6        -- Square
local RAID_MARKER_ICON = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6"
local UPDATE_INTERVAL = 0.05
local ARROW_TEXTURE = "Interface\\AddOns\\AkistosCraftCompendium\\Media\\Arrow"
local MARKER_ICON = "Interface\\GossipFrame\\VendorGossipIcon"
local MARKER_SIZE = 22
local MINIMAP_PIN_SIZE = 14
-- Width of the area the minimap shows, in yards, per zoom level (0 = zoomed out).
local MINIMAP_YARDS = {
    outdoor = { [0] = 466.67, 400, 333.33, 266.67, 200, 133.33 },
    indoor  = { [0] = 300, 240, 180, 120, 80, 50 },
}
-- Above the plain vendor pins (see VendorPins.lua).
local MARKER_LEVEL_OFFSET = 3100
local PREFIX = "|cff00ccffACC:|r "

local arrow, marker, targetButton, minimapPin
local clickButtons = {}

local function getWaypoint()
    return ACC_CharacterData and ACC_CharacterData.vendorWaypoint
end

-- ── World map marker ──────────────────────────────────────────────────────────

local function refreshMarker()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end

    local waypoint = getWaypoint()
    if not waypoint or waypoint.mapID ~= WorldMapFrame:GetMapID() then
        if marker then marker:Hide() end
        return
    end

    local canvas = WorldMapFrame:GetCanvas()
    if not marker then
        marker = CreateFrame("Button", nil, canvas)
        marker:SetWidth(MARKER_SIZE)
        marker:SetHeight(MARKER_SIZE)
        marker:SetFrameLevel(math.min(canvas:GetFrameLevel() + MARKER_LEVEL_OFFSET, 9100))

        -- Gold edge sets the marked vendor apart from the plain pins.
        local border = marker:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", marker, "TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", marker, "BOTTOMRIGHT", 2, -2)
        border:SetColorTexture(1, 0.82, 0)

        local icon = marker:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(marker)
        icon:SetTexture(MARKER_ICON)

        marker.label = marker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        marker.label:SetPoint("TOP", marker, "BOTTOM", 0, -3)

        marker:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        marker:SetScript("OnClick", function() ACC.clearVendorWaypoint() end)
        marker:SetScript("OnEnter", function(self)
            local current = getWaypoint()
            if not current then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(current.name, 1, 1, 1)
            if current.label then GameTooltip:AddLine(current.label, 1, 0.82, 0, true) end
            GameTooltip:AddLine("Click to remove this mark.", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end)
        marker:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    marker:ClearAllPoints()
    marker:SetPoint("CENTER", canvas, "TOPLEFT", waypoint.x * canvas:GetWidth(), -waypoint.y * canvas:GetHeight())
    marker.label:SetText(waypoint.name)
    marker:Show()
end

-- ── Arrow ─────────────────────────────────────────────────────────────────────

-- World position (yards) of a point on a zone map: continent, north, west.
local function worldPosition(mapID, x, y)
    local continent, pos = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x, y))
    if not pos then return nil end
    local north, west = pos:GetXY()
    return continent, north, west
end

-- How far north and west of the player the marked vendor is, in yards.
-- Nil when either position is unavailable (instances) or they are on different continents.
local function getOffset(waypoint)
    local playerMap = C_Map.GetBestMapForUnit("player")
    local playerPos = playerMap and C_Map.GetPlayerMapPosition(playerMap, "player")
    if not playerPos then return nil end

    local px, py = playerPos:GetXY()
    local playerContinent, playerNorth, playerWest = worldPosition(playerMap, px, py)
    local continent, north, west = worldPosition(waypoint.mapID, waypoint.x, waypoint.y)
    if not playerContinent or playerContinent ~= continent then return nil end

    return north - playerNorth, west - playerWest
end

-- ── Minimap pin ───────────────────────────────────────────────────────────────

local function createMinimapPin()
    minimapPin = CreateFrame("Frame", "ACCVendorMinimapPin", Minimap)
    minimapPin:SetWidth(MINIMAP_PIN_SIZE)
    minimapPin:SetHeight(MINIMAP_PIN_SIZE)
    minimapPin:SetFrameStrata("MEDIUM")
    minimapPin:SetFrameLevel(Minimap:GetFrameLevel() + 10)
    minimapPin:Hide()

    local border = minimapPin:CreateTexture(nil, "BACKGROUND")
    border:SetPoint("TOPLEFT", minimapPin, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", minimapPin, "BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(1, 0.82, 0)
    local icon = minimapPin:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(minimapPin)
    icon:SetTexture(MARKER_ICON)

    minimapPin:EnableMouse(true)
    minimapPin:SetScript("OnEnter", function(self)
        local waypoint = getWaypoint()
        if not waypoint then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(waypoint.name, 1, 1, 1)
        if self.distance then
            GameTooltip:AddLine(string.format("%d yards", self.distance), 1, 0.82, 0)
        end
        GameTooltip:Show()
    end)
    minimapPin:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Places the pin where the vendor is on the minimap, or on its edge in the vendor's
-- direction while they are further away than the minimap shows.
local function updateMinimapPin(dNorth, dWest, distance)
    if not dNorth then
        minimapPin:Hide()
        return
    end

    local yards = MINIMAP_YARDS[IsIndoors() and "indoor" or "outdoor"][Minimap:GetZoom()] or 466.67
    local radius = Minimap:GetWidth() / 2
    local scale = radius / (yards / 2)
    local x, y = -dWest * scale, dNorth * scale

    -- With a rotating minimap "up" is where the player faces, not north.
    local facing = GetPlayerFacing()
    if facing and GetCVar("rotateMinimap") == "1" then
        local sin, cos = math.sin(facing), math.cos(facing)
        x, y = x * cos + y * sin, -x * sin + y * cos
    end

    local edge = radius - MINIMAP_PIN_SIZE / 2
    local length = math.sqrt(x * x + y * y)
    if length > edge then
        x, y = x / length * edge, y / length * edge
    end

    minimapPin.distance = distance
    minimapPin:ClearAllPoints()
    minimapPin:SetPoint("CENTER", Minimap, "CENTER", x, y)
    minimapPin:Show()
end

local function updateArrow(self, elapsed)
    self.sinceUpdate = (self.sinceUpdate or 0) + elapsed
    if self.sinceUpdate < UPDATE_INTERVAL then return end
    self.sinceUpdate = 0

    local waypoint = getWaypoint()
    if not waypoint then
        arrow:Hide()
        return
    end

    local dNorth, dWest = getOffset(waypoint)
    local distance = dNorth and math.sqrt(dNorth * dNorth + dWest * dWest)
    updateMinimapPin(dNorth, dWest, distance)

    local facing = GetPlayerFacing()
    if not distance or not facing or distance > ARROW_RANGE then
        arrow.body:Hide()
        return
    end

    -- GetPlayerFacing is 0 facing north and grows counter-clockwise, same as atan2(west, north).
    arrow.texture:SetRotation(math.atan2(dWest, dNorth) - facing)
    arrow.name:SetText(waypoint.name)
    arrow.distance:SetText(string.format("%d yd", distance))
    arrow.body:Show()
end

local function createArrow()
    -- The outer frame only runs the update; the visible, clickable part is "body",
    -- so hiding the arrow out of range does not stop the range check.
    arrow = CreateFrame("Frame", "ACCVendorArrow", UIParent)
    arrow:SetWidth(1)
    arrow:SetHeight(1)
    arrow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    arrow:Hide()
    arrow:SetScript("OnUpdate", updateArrow)

    local body = CreateFrame("Button", nil, arrow)
    body:SetWidth(48)
    body:SetHeight(48)
    body:SetMovable(true)
    body:SetClampedToScreen(true)
    body:RegisterForDrag("LeftButton")
    body:RegisterForClicks("RightButtonUp")
    local saved = ACC_CharacterData and ACC_CharacterData.vendorArrowPos
    if saved then
        body:SetPoint("CENTER", UIParent, "BOTTOMLEFT", saved[1], saved[2])
    else
        body:SetPoint("TOP", UIParent, "TOP", 0, -180)
    end
    body:Hide()
    arrow.body = body

    arrow.texture = body:CreateTexture(nil, "ARTWORK")
    arrow.texture:SetAllPoints(body)
    arrow.texture:SetTexture(ARROW_TEXTURE)
    arrow.texture:SetVertexColor(0.2, 1, 0.2)

    arrow.name = body:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    arrow.name:SetPoint("TOP", body, "BOTTOM", 0, -2)
    arrow.distance = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    arrow.distance:SetPoint("TOP", arrow.name, "BOTTOM", 0, -1)

    body:SetScript("OnDragStart", body.StartMoving)
    body:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        ACC_CharacterData = ACC_CharacterData or {}
        ACC_CharacterData.vendorArrowPos = { x, y }
    end)
    body:SetScript("OnClick", function() ACC.clearVendorWaypoint() end)
    body:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Recipe vendor", 1, 1, 1)
        GameTooltip:AddLine("Drag to move. Right-click to remove the mark.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    body:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- ── Target button and raid marker ─────────────────────────────────────────────

-- Addons cannot target for the player, so targeting goes through a secure button the player
-- clicks: it runs "/targetexact <vendor>" and puts the Square marker on them.
-- Secure frames cannot be changed in combat; changes wait until combat ends.
local targetButtonDirty = false

local function refreshTargetButton()
    if not targetButton then return end
    if InCombatLockdown() then
        targetButtonDirty = true
        return
    end
    targetButtonDirty = false

    local waypoint = getWaypoint()
    if not waypoint then
        targetButton:Hide()
        return
    end
    -- %q quotes the name safely for the Lua part (names like Kor'geld contain an apostrophe).
    targetButton:SetAttribute("macrotext", "/targetexact " .. waypoint.name .. "\n"
        .. string.format("/run if UnitName('target')==%q and GetRaidTargetIndex('target')~=%d then "
            .. "SetRaidTarget('target',%d) end", waypoint.name, RAID_MARKER, RAID_MARKER))
    targetButton.text:SetText("Target " .. waypoint.name)
    targetButton:SetWidth(math.max(120, targetButton.text:GetStringWidth() + 40))
    targetButton:Show()
end

local function createTargetButton()
    targetButton = CreateFrame("Button", "ACCVendorTargetButton", UIParent, "SecureActionButtonTemplate")
    targetButton:SetHeight(24)
    targetButton:SetWidth(120)
    targetButton:SetMovable(true)
    targetButton:SetClampedToScreen(true)
    targetButton:RegisterForClicks("AnyUp", "AnyDown")
    targetButton:RegisterForDrag("LeftButton")
    targetButton:SetAttribute("type", "macro")
    local saved = ACC_CharacterData and ACC_CharacterData.vendorTargetPos
    if saved then
        targetButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", saved[1], saved[2])
    else
        targetButton:SetPoint("TOP", UIParent, "TOP", 0, -270)
    end
    targetButton:Hide()

    local background = targetButton:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(targetButton)
    background:SetColorTexture(0, 0, 0, 0.7)
    local highlight = targetButton:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(targetButton)
    highlight:SetColorTexture(1, 1, 1, 0.15)

    local icon = targetButton:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16)
    icon:SetHeight(16)
    icon:SetPoint("LEFT", targetButton, "LEFT", 6, 0)
    icon:SetTexture(RAID_MARKER_ICON)

    targetButton.text = targetButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    targetButton.text:SetPoint("LEFT", icon, "RIGHT", 6, 0)

    targetButton:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() and not InCombatLockdown() then self:StartMoving() end
    end)
    targetButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        ACC_CharacterData = ACC_CharacterData or {}
        ACC_CharacterData.vendorTargetPos = { x, y }
    end)
    targetButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Target recipe vendor", 1, 1, 1)
        GameTooltip:AddLine("Click to target the vendor and mark them with Square.", 1, 0.82, 0, true)
        GameTooltip:AddLine("Only works when the vendor is nearby. Shift-drag to move.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    targetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Also marks the vendor when the player targets them by hand.
local function markTargetIfVendor()
    local waypoint = getWaypoint()
    if waypoint and UnitName("target") == waypoint.name and GetRaidTargetIndex("target") ~= RAID_MARKER then
        SetRaidTarget("target", RAID_MARKER)
    end
end

-- ── Setting and clearing ──────────────────────────────────────────────────────

-- vendor is a recipe-source vendor entry ({ name, zone, ... }); true when it has a known position.
function ACC.hasVendorCoords(vendor)
    return ACC_VendorCoords ~= nil and ACC_VendorCoords[vendor.name .. "|" .. (vendor.zone or "")] ~= nil
end

-- label is shown with the mark, e.g. the recipe the player was looking at.
function ACC.setVendorWaypoint(vendor, label)
    local coords = ACC_VendorCoords and ACC_VendorCoords[vendor.name .. "|" .. (vendor.zone or "")]
    if not coords then return end

    ACC_CharacterData = ACC_CharacterData or {}
    ACC_CharacterData.vendorWaypoint = {
        name  = vendor.name,
        zone  = vendor.zone,
        label = label,
        mapID = coords[1],
        x     = coords[2] / 100,
        y     = coords[3] / 100,
    }
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "Marked |cffffffff" .. vendor.name .. "|r in " .. (vendor.zone or "?")
        .. string.format(" (%.1f, %.1f)", coords[2], coords[3])
        .. ". An arrow appears within " .. ARROW_RANGE .. " yards.")
    if arrow then arrow:Show() end
    refreshMarker()
    refreshTargetButton()
end

function ACC.clearVendorWaypoint(silent)
    if not getWaypoint() then return end
    ACC_CharacterData.vendorWaypoint = nil
    if arrow then
        arrow.body:Hide()
        arrow:Hide()
    end
    if marker then marker:Hide() end
    if minimapPin then minimapPin:Hide() end
    refreshTargetButton()
    if not silent then
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "Vendor mark removed.")
    end
end

-- ── Clickable vendor lines in the recipe detail panel ─────────────────────────

-- Lays an invisible button over a "Sold by" line so clicking it marks that vendor.
function ACC.showVendorClick(index, label, vendor, recipe)
    local button = clickButtons[index]
    if not button then
        button = CreateFrame("Button", nil, ACC_RecipeDetailState.frame)
        local highlight = button:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(button)
        highlight:SetColorTexture(1, 1, 1, 0.12)
        button:SetScript("OnClick", function(self)
            local recipeName = self.recipe and (self.recipe.recipeItemName or self.recipe.name)
            ACC.setVendorWaypoint(self.vendor, recipeName)
        end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.vendor.name, 1, 1, 1)
            GameTooltip:AddLine("Click to mark this vendor on the world map.", 1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        clickButtons[index] = button
    end

    button.vendor, button.recipe = vendor, recipe
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", label, "TOPLEFT", -2, 1)
    button:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", 2, -1)
    button:Show()
end

-- Hides the click buttons from index onward (all of them when index is 1).
function ACC.hideVendorClicks(index)
    for i = index, #clickButtons do
        clickButtons[i]:Hide()
    end
end

-- ── Events ────────────────────────────────────────────────────────────────────

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
loginFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
loginFrame:RegisterEvent("MERCHANT_SHOW")
loginFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_TARGET_CHANGED" then
        markTargetIfVendor()
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        if targetButtonDirty then refreshTargetButton() end
        return
    elseif event == "MERCHANT_SHOW" then
        -- Shop window of the marked vendor opened: the player has arrived.
        local waypoint = getWaypoint()
        if waypoint and UnitName("npc") == waypoint.name then ACC.clearVendorWaypoint(true) end
        return
    end

    createArrow()
    createMinimapPin()
    createTargetButton()
    if getWaypoint() then
        arrow:Show()
        refreshTargetButton()
    end

    if WorldMapFrame then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", refreshMarker)
        WorldMapFrame:HookScript("OnShow", refreshMarker)
    end
end)
