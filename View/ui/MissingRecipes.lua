-- MissingRecipes.lua — companion panel beside the Blizzard TradeSkill / Craft frame
-- showing known/missing recipe counts and a scrollable list of missing recipes.

local ROW_HEIGHT    = 18
local VISIBLE_ROWS  = 20
local FRAME_W       = 280

local TRADESKILL_NAME_MAP = {
    ["Alchemy"]        = "Alchemy",
    ["Blacksmithing"]  = "Blacksmithing",
    ["Cooking"]        = "Cooking",
    ["Enchanting"]     = "Enchanting",
    ["Engineering"]    = "Engineering",
    ["First Aid"]      = "First Aid",
    ["Leatherworking"] = "Leatherworking",
    ["Tailoring"]      = "Tailoring",
    ["Mining"]         = "Mining",
    ["Smelting"]       = "Mining",
}

local SOURCE_LABELS = {
    trainer    = "|cff1eff00Trainer|r",
    vendor     = "|cff4488ffVendor|r",
    drop       = "|cffff8000Drop|r",
    quest      = "|cffffff00Quest|r",
    object     = "|cffa335eeObject|r",
    world_drop = "|cffff8000World Drop|r",
    decoded    = "|cffa335eeDecoded|r",
    chest      = "|cffff8000Container|r",
    lockbox    = "|cffff8000Container|r",
    holiday    = "|cffffff00Holiday|r",
    unknown    = "|cffaaaaaaUnknown|r",
    other      = "|cffaaaaaaOther|r",
}

local FACTION_COLOR = {
    horde    = "|cffff4040",
    alliance = "|cff4488ff",
}
local NEUTRAL_COLOR = "|cffffffff"

local mainFrame    = nil
local toggleBtn    = nil
local knownLabel   = nil
local missingLabel = nil
local scrollFrame  = nil
local rows         = {}
local missingList  = {}

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function getDataProfName()
    if CraftFrame and CraftFrame:IsShown() then
        return "Enchanting"
    end
    local skillName = GetTradeSkillLine and GetTradeSkillLine() or nil
    if not skillName then return nil end
    return TRADESKILL_NAME_MAP[skillName]
end

local function getParentFrame()
    if CraftFrame and CraftFrame:IsShown() then return CraftFrame end
    if TradeSkillFrame and TradeSkillFrame:IsShown() then return TradeSkillFrame end
    return nil
end

local function getSourceLabel(recipe)
    if not recipe.sources or #recipe.sources == 0 then return "" end
    return SOURCE_LABELS[recipe.sources[1].type] or ""
end

local function buildMissingList(profName)
    missingList = {}
    local recipes = ACC_Data[profName]
    if not recipes then return 0, 0 end
    local total, known = 0, 0
    for _, recipe in ipairs(recipes) do
        if recipe.spellId and recipe.creates ~= nil then
            total = total + 1
            if ACC_Tracker.IsKnown(recipe.spellId) then
                known = known + 1
            else
                missingList[#missingList + 1] = recipe
            end
        end
    end
    table.sort(missingList, function(a, b)
        local sa, sb = a.skill or 0, b.skill or 0
        if sa ~= sb then return sa < sb end
        return (a.name or "") < (b.name or "")
    end)
    return total, known
end

local function formatPct(n, total)
    if total == 0 then return "0" end
    return tostring(math.floor(n / total * 1000 + 0.5) / 10)
end

local function factionColor(faction)
    if not faction then return NEUTRAL_COLOR end
    return FACTION_COLOR[faction] or NEUTRAL_COLOR
end

local function formatCopper(copper)
    if not copper or copper == 0 then return nil end
    local gold   = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local cop    = copper % 100
    local parts  = {}
    if gold   > 0 then parts[#parts + 1] = "|cffffd700" .. gold   .. "g|r" end
    if silver > 0 then parts[#parts + 1] = "|cffc7c7cf" .. silver .. "s|r" end
    if cop    > 0 then parts[#parts + 1] = "|cffeda55f" .. cop    .. "c|r" end
    return table.concat(parts, " ")
end

-- ── Tooltip ──────────────────────────────────────────────────────────────────

local function addNpcLine(name, zone, faction)
    local fc = factionColor(faction)
    local line = "  " .. fc .. (name or "Unknown") .. "|r"
    if zone then line = line .. "  —  " .. zone end
    GameTooltip:AddLine(line, 1, 1, 1)
end

local function showRowTooltip(row)
    local recipe = row.recipe
    if not recipe then return end

    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetText(recipe.name or "", 1, 1, 1)

    if recipe.skill then
        GameTooltip:AddLine("Required Skill: " .. recipe.skill, 1, 0.82, 0)
    end
    if recipe.specialization then
        GameTooltip:AddLine("Specialization: " .. recipe.specialization, 0.64, 0.21, 0.93)
    end

    if recipe.sources then
        for _, src in ipairs(recipe.sources) do
            if src.type == "trainer" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Source: Trainer", 0.12, 1, 0)
                if src.trainers then
                    for _, t in ipairs(src.trainers) do
                        addNpcLine(t.name, t.zone, t.faction)
                    end
                end

            elseif src.type == "vendor" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Source: Vendor", 0.27, 0.53, 1)
                if src.reputation then
                    GameTooltip:AddLine("  Requires: " .. src.reputation.faction
                        .. " — " .. src.reputation.level, 1, 0.82, 0)
                end
                if src.vendors then
                    for _, v in ipairs(src.vendors) do
                        addNpcLine(v.name, v.zone, v.faction)
                        local extras = {}
                        local price = formatCopper(v.cost)
                        if price then extras[#extras + 1] = "Price: " .. price end
                        if v.limited_stock then extras[#extras + 1] = "|cffff4040Limited Supply|r" end
                        if #extras > 0 then
                            GameTooltip:AddLine("    " .. table.concat(extras, "  —  "), 1, 1, 1)
                        end
                    end
                end

            elseif src.type == "drop" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Source: Drop", 1, 0.5, 0)
                if src.note then
                    GameTooltip:AddLine("  " .. src.note, 1, 0.82, 0)
                end
                if src.creatures then
                    local limit = math.min(#src.creatures, 8)
                    for i = 1, limit do
                        local c = src.creatures[i]
                        local line = "  " .. (c.name or "Unknown")
                        if c.zone then
                            local z = type(c.zone) == "table" and table.concat(c.zone, ", ") or c.zone
                            line = line .. "  —  " .. z
                        end
                        if c.rate then
                            line = line .. "  |cffaaaaaa(" .. string.format("%.2f", c.rate) .. "%)|r"
                        end
                        GameTooltip:AddLine(line, 1, 1, 1)
                    end
                    if #src.creatures > 8 then
                        GameTooltip:AddLine("  ... and " .. (#src.creatures - 8) .. " more", 0.67, 0.67, 0.67)
                    end
                end
                if src.containers then
                    for _, c in ipairs(src.containers) do
                        local line = "  " .. (c.name or "Unknown")
                        if c.rate then
                            line = line .. "  |cffaaaaaa(" .. string.format("%.2f", c.rate) .. "%)|r"
                        end
                        GameTooltip:AddLine(line, 1, 1, 1)
                        if c.note then
                            GameTooltip:AddLine("    " .. c.note, 0.67, 0.67, 0.67)
                        end
                    end
                end

            elseif src.type == "world_drop" then
                GameTooltip:AddLine(" ")
                local line = "Source: World Drop"
                if src.level_range then
                    line = line .. "  |cffaaaaaa(level " .. src.level_range[1] .. "–" .. src.level_range[2] .. ")|r"
                end
                GameTooltip:AddLine(line, 1, 0.5, 0)

            elseif src.type == "quest" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Source: Quest", 1, 1, 0)
                if src.questName then
                    GameTooltip:AddLine("  " .. src.questName, 1, 1, 1)
                end

            elseif src.type == "object" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Source: " .. (src.name or "Object"), 0.64, 0.21, 0.93)
                if src.zone then
                    local zoneLine = "  " .. src.zone
                    if src.subzone then zoneLine = zoneLine .. " — " .. src.subzone end
                    GameTooltip:AddLine(zoneLine, 1, 1, 1)
                end

            elseif src.type == "holiday" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Source: Holiday — " .. (src.event or ""), 1, 1, 0)

            elseif src.type == "decoded" or src.type == "chest"
                    or src.type == "lockbox" or src.type == "other" then
                GameTooltip:AddLine(" ")
                local headers = {
                    decoded = "Source: Decoded",
                    chest   = "Source: Container",
                    lockbox = "Source: Lockbox",
                    other   = "Source: Found in",
                }
                GameTooltip:AddLine(headers[src.type] or "Source", 1, 0.5, 0)
                if src.containers then
                    for _, c in ipairs(src.containers) do
                        local line = "  " .. (c.name or "Unknown")
                        if c.rate then
                            line = line .. "  |cffaaaaaa(" .. string.format("%.2f", c.rate) .. "%)|r"
                        end
                        GameTooltip:AddLine(line, 1, 1, 1)
                    end
                end
            end

            if src.specialization then
                GameTooltip:AddLine("  Specialization: " .. src.specialization, 0.64, 0.21, 0.93)
            end
        end
    end

    GameTooltip:Show()
end

-- ── Row creation ─────────────────────────────────────────────────────────────

local function createRow(index)
    local row = CreateFrame("Button", nil, mainFrame)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 8, -60 - (index - 1) * ROW_HEIGHT)
    row:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -28, -60 - (index - 1) * ROW_HEIGHT)

    local skillText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    skillText:SetPoint("LEFT", row, "LEFT", 4, 0)
    skillText:SetWidth(28)
    skillText:SetJustifyH("RIGHT")
    row.skillText = skillText

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nameText:SetPoint("LEFT", row, "LEFT", 36, 0)
    nameText:SetPoint("RIGHT", row, "RIGHT", -60, 0)
    nameText:SetJustifyH("LEFT")
    row.nameText = nameText

    local sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    sourceText:SetJustifyH("RIGHT")
    row.sourceText = sourceText

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(row)
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.4)

    row:SetScript("OnEnter", function() showRowTooltip(row) end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return row
end

-- ── Scroll / update ──────────────────────────────────────────────────────────

local function updateRows()
    local offset = FauxScrollFrame_GetOffset(scrollFrame) or 0
    for i = 1, VISIBLE_ROWS do
        local row = rows[i]
        local recipe = missingList[offset + i]
        if recipe then
            row.recipe = recipe
            row.skillText:SetText("|cffffd700" .. (recipe.skill or "") .. "|r")
            row.nameText:SetText(recipe.name or "")
            row.sourceText:SetText(getSourceLabel(recipe))
            row:Show()
        else
            row.recipe = nil
            row:Hide()
        end
    end
    FauxScrollFrame_Update(scrollFrame, #missingList, VISIBLE_ROWS, ROW_HEIGHT)
end

-- ── Frame creation ───────────────────────────────────────────────────────────

local function updateToggleText()
    if mainFrame and mainFrame:IsShown() then
        toggleBtn:SetText("Hide Missing Recipes")
    else
        toggleBtn:SetText("Show Missing Recipes")
    end
end

local function createMainFrame()
    mainFrame = CreateFrame("Frame", "AccMissingRecipesFrame", UIParent, "BasicFrameTemplate")
    mainFrame:SetWidth(FRAME_W)
    mainFrame:SetToplevel(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetScript("OnHide", function()
        if toggleBtn then updateToggleText() end
    end)

    mainFrame.TitleText:SetText("Missing Recipes")

    knownLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    knownLabel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -28)
    knownLabel:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -12, -28)
    knownLabel:SetJustifyH("CENTER")

    missingLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    missingLabel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -42)
    missingLabel:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -12, -42)
    missingLabel:SetJustifyH("CENTER")

    scrollFrame = CreateFrame("ScrollFrame", "AccMissingScrollFrame", mainFrame, "FauxScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 8, -60)
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -28, 8)
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, updateRows)
    end)

    for i = 1, VISIBLE_ROWS do
        rows[i] = createRow(i)
    end

    mainFrame:Hide()
end

local function createToggleButton()
    toggleBtn = CreateFrame("Button", "AccMissingToggle", UIParent, "UIPanelButtonTemplate")
    toggleBtn:SetWidth(150)
    toggleBtn:SetHeight(22)
    toggleBtn:SetText("Show Missing Recipes")
    toggleBtn:SetScript("OnClick", function()
        if mainFrame:IsShown() then
            mainFrame:Hide()
        else
            mainFrame:Show()
        end
        updateToggleText()
    end)
    toggleBtn:Hide()
end

-- ── Anchoring ────────────────────────────────────────────────────────────────

local function anchorToParent(parent)
    local visibleCount = math.min(#missingList, VISIBLE_ROWS)
    local contentH = 60 + visibleCount * ROW_HEIGHT + 16
    mainFrame:SetHeight(math.max(contentH, 120))
    mainFrame:ClearAllPoints()
    mainFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", -36, 0)

    toggleBtn:SetParent(parent)
    toggleBtn:ClearAllPoints()
    toggleBtn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -40, 2)
end

-- ── Refresh ──────────────────────────────────────────────────────────────────

local function refresh()
    local profName = getDataProfName()
    local parent = getParentFrame()
    if not profName or not parent then
        if toggleBtn then toggleBtn:Hide() end
        if mainFrame and mainFrame:IsShown() then mainFrame:Hide() end
        return
    end

    if not mainFrame then createMainFrame() end
    if not toggleBtn then createToggleButton() end

    local total, known = buildMissingList(profName)
    if total == 0 then
        toggleBtn:Hide()
        mainFrame:Hide()
        return
    end

    local missing = total - known

    anchorToParent(parent)
    toggleBtn:Show()
    updateToggleText()

    knownLabel:SetText("|cff1eff00Known: " .. known .. "/" .. total .. " (" .. formatPct(known, total) .. "%)|r")
    missingLabel:SetText("|cffff4040Missing: " .. missing .. "/" .. total .. " (" .. formatPct(missing, total) .. "%)|r")
    mainFrame.TitleText:SetText("Missing — " .. profName)

    FauxScrollFrame_SetOffset(scrollFrame, 0)
    updateRows()
end

-- ── Events ───────────────────────────────────────────────────────────────────

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:RegisterEvent("TRADE_SKILL_UPDATE")
eventFrame:RegisterEvent("CRAFT_SHOW")
eventFrame:RegisterEvent("CRAFT_UPDATE")
eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")
eventFrame:RegisterEvent("CRAFT_CLOSE")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "TRADE_SKILL_CLOSE" or event == "CRAFT_CLOSE" then
        if mainFrame then mainFrame:Hide() end
        if toggleBtn then toggleBtn:Hide() end
    else
        refresh()
    end
end)
