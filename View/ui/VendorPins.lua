-- VendorPins.lua — recipe vendors as pins on the world map.
-- Only vendors referenced by the recipe data are shown; positions come from ACC_VendorCoords.
-- Toggle with the checkbox on the map or /acc vendors; the choice persists in ACC_AccountData.

local PIN_SIZE = 16
-- Above the map's own pins, which Blizzard stacks upward from the canvas level.
local PIN_LEVEL_OFFSET = 2900
local PIN_ICON = "Interface\\GossipFrame\\VendorGossipIcon"
-- Pins closer together than this are pushed apart so each one stays visible and hoverable...
local MIN_SEPARATION = PIN_SIZE + 2
-- ...but never further than this from where the vendor really stands.
local MAX_SHIFT = PIN_SIZE * 2.5
local SPREAD_PASSES = 12
-- Longest recipe list shown in one tooltip before it is cut off with "... and N more".
local TOOLTIP_LIMIT = 25

-- vendorsByMap[uiMapID] = { { name, faction, x, y, recipes = { { recipe, profession, cost, limited, reputation } } } }
local vendorsByMap = {}
local pins = {}
local toggle

-- ── Vendor index ──────────────────────────────────────────────────────────────

local function buildVendorIndex()
    local byKey = {}
    for profession, recipes in pairs(ACC_Data) do
        for _, recipe in ipairs(recipes) do
            for _, src in ipairs(recipe.sources or {}) do
                if src.type == "vendor" and src.vendors then
                    for _, v in ipairs(src.vendors) do
                        local key = v.name .. "|" .. (v.zone or "")
                        local coords = ACC_VendorCoords[key]
                        if coords then
                            local vendor = byKey[key]
                            if not vendor then
                                vendor = {
                                    name    = v.name,
                                    zone    = v.zone,
                                    faction = v.faction,
                                    x       = coords[2] / 100,
                                    y       = coords[3] / 100,
                                    recipes = {},
                                    seen    = {},
                                }
                                byKey[key] = vendor
                                local mapID = coords[1]
                                vendorsByMap[mapID] = vendorsByMap[mapID] or {}
                                table.insert(vendorsByMap[mapID], vendor)
                            end
                            -- The data lists some vendors twice under one recipe.
                            if not vendor.seen[recipe] then
                                vendor.seen[recipe] = true
                                vendor.recipes[#vendor.recipes + 1] = {
                                    recipe     = recipe,
                                    profession = profession,
                                    cost       = v.cost,
                                    limited    = v.limited_stock,
                                    reputation = src.reputation,
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    for _, vendor in pairs(byKey) do
        vendor.seen = nil
        table.sort(vendor.recipes, function(a, b)
            if a.profession ~= b.profession then return a.profession < b.profession end
            return (a.recipe.skill or 0) < (b.recipe.skill or 0)
        end)
    end
end

local function isUsableByPlayer(vendor)
    if not vendor.faction then return true end
    local faction = UnitFactionGroup("player")
    return (faction == "Alliance" and vendor.faction == "alliance")
        or (faction == "Horde" and vendor.faction == "horde")
end

-- ── Tooltip ───────────────────────────────────────────────────────────────────

local function showVendorTooltip(pin)
    local vendor = pin.vendor
    if not vendor then return end

    GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
    GameTooltip:SetText(vendor.name, 1, 1, 1)

    local lastProfession
    for i, entry in ipairs(vendor.recipes) do
        if i > TOOLTIP_LIMIT then
            GameTooltip:AddLine("... and " .. (#vendor.recipes - TOOLTIP_LIMIT) .. " more", 0.7, 0.7, 0.7)
            break
        end
        if entry.profession ~= lastProfession then
            lastProfession = entry.profession
            GameTooltip:AddLine(entry.profession, 1, 0.82, 0)
        end

        local recipe = entry.recipe
        local left = recipe.recipeItemName or recipe.name or "?"
        if entry.limited then left = left .. " |cffff4040(Limited)|r" end
        if entry.reputation then
            left = left .. " |cffffff00(" .. entry.reputation.faction .. " - " .. entry.reputation.level .. ")|r"
        end
        local known = recipe.spellId and ACC_Tracker.IsKnown(recipe.spellId)
        local shade = known and 0.5 or 1
        GameTooltip:AddDoubleLine(left, ACC.formatCopper(entry.cost) or "", shade, shade, shade, 1, 1, 1)
    end

    GameTooltip:AddLine("Greyed out recipes are already known by this character.", 0.5, 0.5, 0.5, true)
    GameTooltip:AddLine("Click to mark this vendor.", 0.5, 0.5, 0.5, true)
    GameTooltip:Show()
end

-- ── Pins ──────────────────────────────────────────────────────────────────────

local function getPin(index)
    local pin = pins[index]
    if pin then return pin end

    local canvas = WorldMapFrame:GetCanvas()
    pin = CreateFrame("Frame", nil, canvas)
    pin:SetWidth(PIN_SIZE)
    pin:SetHeight(PIN_SIZE)
    pin:SetFrameLevel(math.min(canvas:GetFrameLevel() + PIN_LEVEL_OFFSET, 9000))

    pin.icon = pin:CreateTexture(nil, "ARTWORK")
    pin.icon:SetAllPoints(pin)
    pin.icon:SetTexture(PIN_ICON)

    pin:EnableMouse(true)
    -- Left-click marks the vendor; right-click still reaches the map underneath (zoom out).
    if pin.SetPassThroughButtons then pin:SetPassThroughButtons("RightButton") end
    pin:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.vendor then
            ACC.setVendorWaypoint(self.vendor)
        end
    end)
    pin:SetScript("OnEnter", showVendorTooltip)
    pin:SetScript("OnLeave", function() GameTooltip:Hide() end)

    pins[index] = pin
    return pin
end

local function pinsEnabled()
    return not (ACC_AccountData and ACC_AccountData.vendorPinsHidden)
end

-- Nudges overlapping spots ({ x, y, homeX, homeY } in canvas units) apart. Vendors standing
-- next to each other (a city's trade district) would otherwise stack into one unreadable pile.
local function spreadSpots(spots)
    for _ = 1, SPREAD_PASSES do
        local moved = false
        for i = 1, #spots do
            for j = i + 1, #spots do
                local a, b = spots[i], spots[j]
                local dx, dy = b.x - a.x, b.y - a.y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < MIN_SEPARATION then
                    if dist < 0.01 then
                        -- Same spot: pick a direction from the pair's indices so the result is stable.
                        local angle = (i * 7 + j * 13) % 12 * math.pi / 6
                        dx, dy, dist = math.cos(angle), math.sin(angle), 1
                    end
                    local push = (MIN_SEPARATION - dist) / 2
                    a.x, a.y = a.x - dx / dist * push, a.y - dy / dist * push
                    b.x, b.y = b.x + dx / dist * push, b.y + dy / dist * push
                    moved = true
                end
            end
        end
        for _, spot in ipairs(spots) do
            local dx, dy = spot.x - spot.homeX, spot.y - spot.homeY
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist > MAX_SHIFT then
                spot.x = spot.homeX + dx / dist * MAX_SHIFT
                spot.y = spot.homeY + dy / dist * MAX_SHIFT
            end
        end
        if not moved then break end
    end
end

local function refreshPins()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end

    local used = 0
    if pinsEnabled() then
        local canvas = WorldMapFrame:GetCanvas()
        local width, height = canvas:GetWidth(), canvas:GetHeight()
        local spots = {}
        for _, vendor in ipairs(vendorsByMap[WorldMapFrame:GetMapID()] or {}) do
            if isUsableByPlayer(vendor) then
                local x, y = vendor.x * width, vendor.y * height
                spots[#spots + 1] = { vendor = vendor, x = x, y = y, homeX = x, homeY = y }
            end
        end
        spreadSpots(spots)
        for _, spot in ipairs(spots) do
            used = used + 1
            local pin = getPin(used)
            pin.vendor = spot.vendor
            pin:ClearAllPoints()
            pin:SetPoint("CENTER", canvas, "TOPLEFT", spot.x, -spot.y)
            pin:Show()
        end
    end

    for i = used + 1, #pins do
        pins[i]:Hide()
    end
end

-- ── Toggle ────────────────────────────────────────────────────────────────────

-- Called by /acc vendors and by the checkbox on the world map.
function ACC.toggleVendorPins()
    ACC_AccountData = ACC_AccountData or {}
    ACC_AccountData.vendorPinsHidden = not ACC_AccountData.vendorPinsHidden
    if toggle then toggle:SetChecked(pinsEnabled()) end
    refreshPins()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffACC:|r Recipe vendor map pins "
        .. (pinsEnabled() and "shown" or "hidden") .. ". Type |cffffffff/acc vendors|r to toggle.")
end

local function createToggle()
    local container = WorldMapFrame.ScrollContainer or WorldMapFrame
    toggle = CreateFrame("CheckButton", "ACCVendorPinsToggle", WorldMapFrame, "UICheckButtonTemplate")
    toggle:SetWidth(24)
    toggle:SetHeight(24)
    toggle:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 6, 6)
    toggle:SetFrameLevel(math.min(container:GetFrameLevel() + PIN_LEVEL_OFFSET + 100, 9500))
    toggle:SetChecked(pinsEnabled())

    local label = toggle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", toggle, "RIGHT", 0, 1)
    label:SetText("Recipe vendors")

    toggle:SetScript("OnClick", ACC.toggleVendorPins)
    toggle:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Recipe Vendors", 1, 1, 1)
        GameTooltip:AddLine("Show vendors that sell recipes on this map.", 1, 0.82, 0, true)
        GameTooltip:Show()
    end)
    toggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- ── Events ────────────────────────────────────────────────────────────────────

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function()
    if not WorldMapFrame or not ACC_VendorCoords then return end

    buildVendorIndex()
    createToggle()

    hooksecurefunc(WorldMapFrame, "OnMapChanged", refreshPins)
    WorldMapFrame:HookScript("OnShow", refreshPins)
end)
