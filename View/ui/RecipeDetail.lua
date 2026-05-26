-- RecipeDetail.lua — layout engine for the RecipeDetail panel.
-- Frame construction and widget pool live in RecipeDetailFrame.lua (ACC_RecipeDetailState).
-- Utilities: RecipeDetailHelpers.lua  |  Sources: RecipeDetailSources.lua  |  Zone: RecipeDetailZone.lua
-- showRecipeDetail() flows top-to-bottom using a y cursor; each section is a local function.

local RDS = ACC_RecipeDetailState

-- Row 1: recipe item link if available, else spell link. Position is fixed at y = -40.
local function layoutSpellRow(recipe, spellLink)
    if recipe.recipeItemId then
        local link = ACC.resolveItemLink(recipe.recipeItemId, recipe.recipeItemName, recipe.recipeItemQuality)
        RDS.spellButton.text:SetText(link)
        RDS.spellButton.icon:SetTexture(ACC.resolveItemIcon(recipe.recipeItemId, recipe.recipeItemIcon))
        RDS.spellButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(RDS.spellButton, "ANCHOR_NONE")
            GameTooltip:SetPoint("BOTTOMLEFT", RDS.spellButton, "TOPLEFT", 0, 2)
            GameTooltip:SetHyperlink("item:" .. recipe.recipeItemId)
            GameTooltip:Show()
            local _, freshLink, _, _, _, _, _, _, _, freshTex = GetItemInfo(recipe.recipeItemId)
            if freshLink then RDS.spellButton.text:SetText(freshLink) end
            if freshTex  then RDS.spellButton.icon:SetTexture(freshTex) end
        end)
        RDS.spellButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        RDS.spellButton:SetScript("OnClick", function()
            local _, freshLink = GetItemInfo(recipe.recipeItemId)
            ACC.insertLink(freshLink or spellLink)
        end)
    else
        RDS.spellButton.text:SetText(spellLink)
        RDS.spellButton.icon:SetTexture(
            recipe.creates and recipe.creates.icon and ("Interface\\Icons\\" .. recipe.creates.icon) or nil)
        RDS.spellButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(RDS.spellButton, "ANCHOR_NONE")
            GameTooltip:SetPoint("BOTTOMLEFT", RDS.spellButton, "TOPLEFT", 0, 2)
            GameTooltip:SetHyperlink(spellLink)
            GameTooltip:Show()
        end)
        RDS.spellButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        RDS.spellButton:SetScript("OnClick", function() ACC.insertLink(spellLink) end)
    end
end

-- Specialization badge (Gnomish / Goblin Engineering). Returns updated y.
-- 4dc8ed = gnomish cyan-blue; ff6600 = goblin orange.
local function layoutSpecialization(recipe, y)
    if recipe.specialization == "gnomish" then
        RDS.specLabel:ClearAllPoints()
        RDS.specLabel:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.PADDING, y)
        RDS.specLabel:SetText("|cff4dc8ed[Gnomish Engineering]|r")
        RDS.specLabel:Show()
        return y - RDS.ROW_HEIGHT - 2
    elseif recipe.specialization == "goblin" then
        RDS.specLabel:ClearAllPoints()
        RDS.specLabel:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.PADDING, y)
        RDS.specLabel:SetText("|cffff6600[Goblin Engineering]|r")
        RDS.specLabel:Show()
        return y - RDS.ROW_HEIGHT - 2
    end
    RDS.specLabel:Hide()
    return y
end

-- Known / Not Known label + per-character list. Returns updated y.
local function layoutKnownStatus(recipe, y)
    if not recipe.spellId then
        RDS.knownLabel:Hide()
        for i = 1, RDS.MAX_CHARS do RDS.charLabels[i]:Hide() end
        return y
    end
    local known    = ACC_Tracker.IsKnown(recipe.spellId)
    local whoKnows = ACC_Tracker.WhoKnows(recipe.spellId)
    RDS.knownLabel:ClearAllPoints()
    RDS.knownLabel:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.PADDING, y)
    RDS.knownLabel:SetText(known and "|cff00ff00Known|r" or "|cffff0000Not Known|r")
    RDS.knownLabel:Show()
    y = y - RDS.ROW_HEIGHT - 2
    for i = 1, RDS.MAX_CHARS do
        local name = whoKnows[i]
        if name then
            RDS.charLabels[i]:ClearAllPoints()
            RDS.charLabels[i]:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.INDENT, y)
            RDS.charLabels[i]:SetText("|cff00ff00Known on:|r |cffffff00" .. name .. "|r")
            RDS.charLabels[i]:Show()
            y = y - RDS.ROW_HEIGHT
        else
            RDS.charLabels[i]:Hide()
        end
    end
    return y - RDS.ROW_GAP
end

-- Creates row (what the recipe produces). Returns updated y.
local function layoutCreates(recipe, spellLink, y)
    if not recipe.creates then
        RDS.createsButton:Hide()
        return y
    end
    local link = ACC.resolveItemLink(recipe.creates.id, recipe.creates.name, recipe.creates.quality)
    local displayText = "Creates: " .. link
    if recipe.creates.count and recipe.creates.count > 1 then
        displayText = displayText .. " x" .. recipe.creates.count
    end
    RDS.createsButton:ClearAllPoints()
    RDS.createsButton:SetPoint("TOPLEFT",  RDS.frame, "TOPLEFT",  RDS.PADDING, y)
    RDS.createsButton:SetPoint("TOPRIGHT", RDS.frame, "TOPRIGHT", -(RDS.PADDING + 20), y)
    RDS.createsButton.icon:SetTexture(ACC.resolveItemIcon(recipe.creates.id, recipe.creates.icon))
    RDS.createsButton.text:SetText(displayText)
    RDS.createsButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(RDS.createsButton, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOMLEFT", RDS.createsButton, "TOPLEFT", 0, 2)
        GameTooltip:SetHyperlink("item:" .. recipe.creates.id)
        GameTooltip:Show()
    end)
    RDS.createsButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    RDS.createsButton:SetScript("OnClick", function()
        local _, freshLink = GetItemInfo(recipe.creates.id)
        ACC.insertLink(freshLink or spellLink)
    end)
    RDS.createsButton:Show()
    return y - RDS.ROW_HEIGHT - RDS.ROW_GAP
end

-- Materials header + reagent rows. Returns updated y.
local function layoutMaterials(recipe, y)
    local reagents = recipe.reagents or {}
    if #reagents == 0 then
        RDS.materialsHeader:Hide()
        for i = 1, 16 do
            RDS.reagentButtons[i]:SetScript("OnEnter", nil)
            RDS.reagentButtons[i]:SetScript("OnLeave", nil)
            RDS.reagentButtons[i]:SetScript("OnClick", nil)
            RDS.reagentButtons[i].icon:SetTexture(nil)
            RDS.reagentButtons[i]:Hide()
        end
        return y
    end
    RDS.materialsHeader:ClearAllPoints()
    RDS.materialsHeader:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.PADDING, y)
    RDS.materialsHeader:Show()
    y = y - RDS.ROW_HEIGHT - 2
    for i = 1, 16 do
        local reagent = reagents[i]
        local rbtn    = RDS.reagentButtons[i]
        if reagent then
            local link = ACC.resolveItemLink(reagent.id, reagent.name, reagent.quality)
            rbtn:ClearAllPoints()
            rbtn:SetPoint("TOPLEFT",  RDS.frame, "TOPLEFT",  RDS.PADDING + 4, y)
            rbtn:SetPoint("TOPRIGHT", RDS.frame, "TOPRIGHT", -(RDS.PADDING + 20), y)
            rbtn.icon:SetTexture(ACC.resolveItemIcon(reagent.id, reagent.icon))
            rbtn.text:SetText(link .. " x" .. reagent.count)
            local r = reagent
            rbtn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(rbtn, "ANCHOR_NONE")
                GameTooltip:SetPoint("BOTTOMLEFT", rbtn, "TOPLEFT", 0, 2)
                GameTooltip:SetHyperlink("item:" .. r.id)
                GameTooltip:Show()
            end)
            rbtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            rbtn:SetScript("OnClick", function()
                local _, freshLink = GetItemInfo(r.id)
                if freshLink then ACC.insertLink(freshLink) end
            end)
            rbtn:Show()
            y = y - RDS.ROW_HEIGHT
        else
            rbtn:SetScript("OnEnter", nil)
            rbtn:SetScript("OnLeave", nil)
            rbtn:SetScript("OnClick", nil)
            rbtn.icon:SetTexture(nil)
            rbtn:Hide()
        end
    end
    return y
end

-- Quest buttons (smelt quest + recipe quest sources). Returns updated y.
local function layoutQuests(recipe, y)
    local quests = {}
    local smelt  = recipe._smelt
    if smelt and smelt.questId and smelt.quest then
        quests[#quests + 1] = { id = smelt.questId, name = smelt.quest, level = smelt.questLevel or 60 }
    end
    for _, src in ipairs(recipe.sources or {}) do
        if src.type == "quest" and src.quests then
            for _, q in ipairs(src.quests) do
                quests[#quests + 1] = { id = q.id, name = q.name, level = q.level or 60, faction = q.faction, wowheadUrl = q.wowheadUrl }
            end
        end
    end
    for i = 1, 4 do
        local qbtn = RDS.questButtons[i]
        local q    = quests[i]
        if q then
            -- Display text uses only colour codes — |H...|h hyperlink markup is invisible on regular
            -- FontStrings and causes raw pipe chars to appear.
            local displayText = "|cffffff00Quest: [" .. q.name .. "]|r"
            if q.faction then displayText = displayText .. "  |cffaaaaaa(" .. q.faction .. ")|r" end
            -- Full hyperlink used only inside the click handler for chat insertion.
            local questLink = q.id
                and ("|cffffff00|Hquest:" .. q.id .. ":" .. q.level .. "|h[" .. q.name .. "]|h|r")
                or  ("|cffffff00[" .. q.name .. "]|r")
            qbtn:ClearAllPoints()
            qbtn:SetPoint("TOPLEFT",  RDS.frame, "TOPLEFT",  RDS.PADDING, y)
            qbtn:SetPoint("TOPRIGHT", RDS.frame, "TOPRIGHT", -(RDS.PADDING + 20), y)
            qbtn.text:SetText(displayText)
            qbtn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(qbtn, "ANCHOR_NONE")
                GameTooltip:SetPoint("BOTTOMLEFT", qbtn, "TOPLEFT", 0, 2)
                GameTooltip:SetText(q.name, 1, 1, 0)
                GameTooltip:AddLine(q.wowheadUrl and "Click to open Wowhead URL" or "Click to link in chat", 0, 1, 0)
                GameTooltip:Show()
            end)
            qbtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            qbtn:SetScript("OnClick", function()
                if q.wowheadUrl then
                    RDS.urlPromptUrl = q.wowheadUrl
                    StaticPopup_Show("ACC_URL")
                elseif not ChatEdit_InsertLink(questLink) then
                    DEFAULT_CHAT_FRAME:AddMessage(questLink)
                end
            end)
            qbtn:Show()
            y = y - RDS.ROW_HEIGHT
        else
            qbtn:SetScript("OnEnter", nil)
            qbtn:SetScript("OnLeave", nil)
            qbtn:SetScript("OnClick", nil)
            qbtn:Hide()
        end
    end
    if #quests > 0 then y = y - RDS.ROW_GAP end
    return y
end

-- Measures the widest visible text element and resizes the frame to fit.
local function autoSize(recipe)
    local maxTextW = 0
    local function measure(fs)
        local w = fs:GetStringWidth()
        if w > maxTextW then maxTextW = w end
    end
    measure(RDS.spellButton.text)
    if RDS.specLabel:IsShown()  then measure(RDS.specLabel)  end
    if recipe.spellId           then measure(RDS.knownLabel) end
    for i = 1, RDS.MAX_CHARS do
        if RDS.charLabels[i]:IsShown() then measure(RDS.charLabels[i]) end
    end
    if recipe.creates then measure(RDS.createsButton.text) end
    -- Check IsShown() rather than iterating by reagent count: layoutZone reuses
    -- reagentButtons for fish rows which have no recipe.reagents entry.
    for i = 1, 16 do
        if RDS.reagentButtons[i]:IsShown() then measure(RDS.reagentButtons[i].text) end
    end
    for i = 1, RDS.MAX_SOURCE_HEADERS do
        if RDS.sourceHeaders[i]:IsShown() then measure(RDS.sourceHeaders[i]) end
    end
    for i = 1, RDS.MAX_SOURCE_LINES do
        if RDS.sourceLabels[i]:IsShown() then measure(RDS.sourceLabels[i]) end
    end
    for i = 1, 4 do
        if RDS.questButtons[i]:IsShown() then measure(RDS.questButtons[i].text) end
    end
    RDS.frame:SetWidth(math.max(200, RDS.ROW_HEIGHT + 2 + maxTextW + RDS.PADDING * 2 + 20))
end

-- Positions the frame, populates every section in order, then auto-sizes.
function ACC.showRecipeDetail(recipe, btn)
    RDS.frame:ClearAllPoints()
    if btn then
        RDS.frame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    else
        RDS.frame:SetPoint("CENTER", UIParent, "CENTER", 320, 0)
    end

    if recipe._zone then
        local y = ACC.layoutZone(recipe)
        RDS.frame:SetHeight(math.abs(y) + RDS.PADDING)
        autoSize(recipe)
        RDS.frame:Show()
        return
    end

    local spellLink = ACC.makeSpellLink(recipe)
    layoutSpellRow(recipe, spellLink)

    local y = -40 - RDS.ROW_HEIGHT - RDS.ROW_GAP
    y = layoutSpecialization(recipe, y)
    y = layoutKnownStatus(recipe, y)
    y = layoutCreates(recipe, spellLink, y)
    y = layoutMaterials(recipe, y)
    y = ACC.layoutSources(recipe, y)
    y = layoutQuests(recipe, y)

    RDS.frame:SetHeight(math.abs(y) + RDS.PADDING)
    autoSize(recipe)
    RDS.frame:Show()
end
