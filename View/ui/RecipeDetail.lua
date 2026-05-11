local recipeDetailFrame
local recipeDetailSpellButton
local recipeDetailKnownLabel
local recipeDetailCharLabels  = {}
local recipeDetailCreatesButton
local recipeDetailMaterialsHeader
local recipeDetailReagentButtons = {}

local ROW_HEIGHT = 16
local ROW_GAP    = 4
local PADDING    = 8
local INDENT     = 20
local MAX_CHARS  = 10

local QUALITY_COLOR = {
    [0] = "ff9d9d9d",
    [1] = "ffffffff",
    [2] = "ff1eff00",
    [3] = "ff0070dd",
    [4] = "ffa335ee",
    [5] = "ffff8000",
}

local function makeItemLink(id, name, quality)
    local color = QUALITY_COLOR[quality] or QUALITY_COLOR[1]
    return "|c" .. color .. "|Hitem:" .. id .. ":0:0:0:0:0:0:0|h[" .. name .. "]|h|r"
end

local function resolveItemLink(id, pipelineName, pipelineQuality)
    local _, link = GetItemInfo(id)
    if link then return link end
    if pipelineName then return makeItemLink(id, pipelineName, pipelineQuality) end
    return "|cffffff00[" .. id .. "]|r"
end

local function resolveItemIcon(id, pipelineIcon)
    if pipelineIcon then return "Interface\\Icons\\" .. pipelineIcon end
    local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(id)
    return tex or "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function insertLink(link)
    for i = 1, NUM_CHAT_WINDOWS do
        local box = _G["ChatFrame" .. i .. "EditBox"]
        if box and box:IsVisible() then
            box:Insert(link)
            return
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage(link)
end

local function addIcon(parent)
    local icon = parent:CreateTexture(nil, "OVERLAY")
    icon:SetWidth(ROW_HEIGHT)
    icon:SetHeight(ROW_HEIGHT)
    icon:SetPoint("LEFT", parent, "LEFT", 0, 0)
    return icon
end

local function createDetailFrame()
    recipeDetailFrame = CreateFrame("Frame", "AccRecipeDetailFrame", UIParent, "BasicFrameTemplate")
    recipeDetailFrame:SetWidth(260)
    recipeDetailFrame:SetHeight(100)
    recipeDetailFrame:SetPoint("CENTER", UIParent, "CENTER", 320, 0)
    recipeDetailFrame:SetFrameStrata("DIALOG")
    recipeDetailFrame:EnableMouse(true)
    recipeDetailFrame:Hide()

    -- Spell / recipe item row — always the first row, fixed position
    recipeDetailSpellButton = CreateFrame("Button", "AccRecipeButton", recipeDetailFrame)
    recipeDetailSpellButton:SetHeight(ROW_HEIGHT)
    recipeDetailSpellButton:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING, -40)
    recipeDetailSpellButton:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -(PADDING + 20), -40)
    recipeDetailSpellButton:EnableMouse(true)
    recipeDetailSpellButton:RegisterForClicks("LeftButtonUp")
    recipeDetailSpellButton.icon = addIcon(recipeDetailSpellButton)
    local spellText = recipeDetailSpellButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    spellText:SetPoint("LEFT", recipeDetailSpellButton, "LEFT", ROW_HEIGHT + 2, 0)
    spellText:SetJustifyH("LEFT")
    recipeDetailSpellButton.text = spellText

    -- Known / Not Known label — position set dynamically
    recipeDetailKnownLabel = recipeDetailFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")

    -- Character name labels — position set dynamically, hidden by default
    for i = 1, MAX_CHARS do
        local lbl = recipeDetailFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:Hide()
        recipeDetailCharLabels[i] = lbl
    end

    -- Creates row — position set dynamically
    recipeDetailCreatesButton = CreateFrame("Button", nil, recipeDetailFrame)
    recipeDetailCreatesButton:SetHeight(ROW_HEIGHT)
    recipeDetailCreatesButton:EnableMouse(true)
    recipeDetailCreatesButton:RegisterForClicks("LeftButtonUp")
    recipeDetailCreatesButton.icon = addIcon(recipeDetailCreatesButton)
    local createsText = recipeDetailCreatesButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    createsText:SetPoint("LEFT", recipeDetailCreatesButton, "LEFT", ROW_HEIGHT + 2, 0)
    createsText:SetJustifyH("LEFT")
    recipeDetailCreatesButton.text = createsText

    -- Materials header — position set dynamically
    recipeDetailMaterialsHeader = recipeDetailFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    recipeDetailMaterialsHeader:SetText("Materials:")

    -- Reagent rows — position set dynamically, hidden by default
    for i = 1, 8 do
        local btn = CreateFrame("Button", nil, recipeDetailFrame)
        btn:SetHeight(ROW_HEIGHT)
        btn:EnableMouse(true)
        btn:RegisterForClicks("LeftButtonUp")
        btn.icon = addIcon(btn)
        local itemText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        itemText:SetPoint("LEFT", btn, "LEFT", ROW_HEIGHT + 2, 0)
        itemText:SetJustifyH("LEFT")
        btn.text = itemText
        btn:Hide()
        recipeDetailReagentButtons[i] = btn
    end
end

function showRecipeDetail(recipe, btn)
    recipeDetailFrame:ClearAllPoints()
    if btn then
        recipeDetailFrame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    else
        recipeDetailFrame:SetPoint("CENTER", UIParent, "CENTER", 320, 0)
    end

    local spellLink = makeSpellLink(recipe)

    -- Row 1: recipe item if available, else spell link (fixed at y = -40)
    if recipe.recipeItemId then
        local link = resolveItemLink(recipe.recipeItemId, recipe.recipeItemName, recipe.recipeItemQuality)
        recipeDetailSpellButton.text:SetText(link)
        recipeDetailSpellButton.icon:SetTexture(resolveItemIcon(recipe.recipeItemId, recipe.recipeItemIcon))
        recipeDetailSpellButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(recipeDetailSpellButton, "ANCHOR_NONE")
            GameTooltip:SetPoint("BOTTOMLEFT", recipeDetailSpellButton, "TOPLEFT", 0, 2)
            GameTooltip:SetHyperlink("item:" .. recipe.recipeItemId)
            GameTooltip:Show()
            local _, freshLink, _, _, _, _, _, _, _, freshTex = GetItemInfo(recipe.recipeItemId)
            if freshLink then recipeDetailSpellButton.text:SetText(freshLink) end
            if freshTex  then recipeDetailSpellButton.icon:SetTexture(freshTex) end
        end)
        recipeDetailSpellButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        recipeDetailSpellButton:SetScript("OnClick", function()
            local _, freshLink = GetItemInfo(recipe.recipeItemId)
            insertLink(freshLink or spellLink)
        end)
    else
        recipeDetailSpellButton.text:SetText(spellLink)
        recipeDetailSpellButton.icon:SetTexture(
            recipe.creates and recipe.creates.icon and ("Interface\\Icons\\" .. recipe.creates.icon) or nil)
        recipeDetailSpellButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(recipeDetailSpellButton, "ANCHOR_NONE")
            GameTooltip:SetPoint("BOTTOMLEFT", recipeDetailSpellButton, "TOPLEFT", 0, 2)
            GameTooltip:SetHyperlink(spellLink)
            GameTooltip:Show()
        end)
        recipeDetailSpellButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        recipeDetailSpellButton:SetScript("OnClick", function() insertLink(spellLink) end)
    end

    -- Dynamic layout — y tracks the top of the next row
    local y = -40 - ROW_HEIGHT - ROW_GAP

    -- Known / Not Known + character list
    if recipe.spellId then
        local known    = ACC_Tracker.IsKnown(recipe.spellId)
        local whoKnows = ACC_Tracker.WhoKnows(recipe.spellId)

        recipeDetailKnownLabel:ClearAllPoints()
        recipeDetailKnownLabel:SetPoint("TOPLEFT", recipeDetailFrame, "TOPLEFT", PADDING, y)
        recipeDetailKnownLabel:SetText(known and "|cff00ff00Known|r" or "|cffaaaaaa Not Known|r")
        recipeDetailKnownLabel:Show()
        y = y - ROW_HEIGHT - 2

        for i = 1, MAX_CHARS do
            local name = whoKnows[i]
            if name then
                recipeDetailCharLabels[i]:ClearAllPoints()
                recipeDetailCharLabels[i]:SetPoint("TOPLEFT", recipeDetailFrame, "TOPLEFT", INDENT, y)
                recipeDetailCharLabels[i]:SetText("|cff00ff00Known on:|r |cffffff00" .. name .. "|r")
                recipeDetailCharLabels[i]:Show()
                y = y - ROW_HEIGHT
            else
                recipeDetailCharLabels[i]:Hide()
            end
        end
        y = y - ROW_GAP
    else
        recipeDetailKnownLabel:Hide()
        for i = 1, MAX_CHARS do recipeDetailCharLabels[i]:Hide() end
    end

    -- Creates row
    if recipe.creates then
        local link = resolveItemLink(recipe.creates.id, recipe.creates.name, recipe.creates.quality)
        local displayText = "Creates: " .. link
        if recipe.creates.count and recipe.creates.count > 1 then
            displayText = displayText .. " x" .. recipe.creates.count
        end
        recipeDetailCreatesButton:ClearAllPoints()
        recipeDetailCreatesButton:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING, y)
        recipeDetailCreatesButton:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -(PADDING + 20), y)
        recipeDetailCreatesButton.icon:SetTexture(resolveItemIcon(recipe.creates.id, recipe.creates.icon))
        recipeDetailCreatesButton.text:SetText(displayText)
        recipeDetailCreatesButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(recipeDetailCreatesButton, "ANCHOR_NONE")
            GameTooltip:SetPoint("BOTTOMLEFT", recipeDetailCreatesButton, "TOPLEFT", 0, 2)
            GameTooltip:SetHyperlink("item:" .. recipe.creates.id)
            GameTooltip:Show()
        end)
        recipeDetailCreatesButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        recipeDetailCreatesButton:SetScript("OnClick", function()
            local _, freshLink = GetItemInfo(recipe.creates.id)
            insertLink(freshLink or spellLink)
        end)
        recipeDetailCreatesButton:Show()
        y = y - ROW_HEIGHT - ROW_GAP
    else
        recipeDetailCreatesButton:Hide()
    end

    -- Materials header + reagent rows
    local reagents = recipe.reagents or {}
    if #reagents > 0 then
        recipeDetailMaterialsHeader:ClearAllPoints()
        recipeDetailMaterialsHeader:SetPoint("TOPLEFT", recipeDetailFrame, "TOPLEFT", PADDING, y)
        recipeDetailMaterialsHeader:Show()
        y = y - ROW_HEIGHT - 2

        for i = 1, 8 do
            local reagent = reagents[i]
            local rbtn    = recipeDetailReagentButtons[i]
            if reagent then
                local link = resolveItemLink(reagent.id, reagent.name, reagent.quality)
                rbtn:ClearAllPoints()
                rbtn:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING + 4, y)
                rbtn:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -(PADDING + 20), y)
                rbtn.icon:SetTexture(resolveItemIcon(reagent.id, reagent.icon))
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
                    if freshLink then insertLink(freshLink) end
                end)
                rbtn:Show()
                y = y - ROW_HEIGHT
            else
                rbtn:SetScript("OnEnter", nil)
                rbtn:SetScript("OnLeave", nil)
                rbtn:SetScript("OnClick", nil)
                rbtn.icon:SetTexture(nil)
                rbtn:Hide()
            end
        end
    else
        recipeDetailMaterialsHeader:Hide()
        for i = 1, 8 do
            recipeDetailReagentButtons[i]:SetScript("OnEnter", nil)
            recipeDetailReagentButtons[i]:SetScript("OnLeave", nil)
            recipeDetailReagentButtons[i]:SetScript("OnClick", nil)
            recipeDetailReagentButtons[i].icon:SetTexture(nil)
            recipeDetailReagentButtons[i]:Hide()
        end
    end

    -- Auto-size height and width
    recipeDetailFrame:SetHeight(math.abs(y) + PADDING)

    local maxTextW = 0
    local function measureText(fs)
        local w = fs:GetStringWidth()
        if w > maxTextW then maxTextW = w end
    end
    measureText(recipeDetailSpellButton.text)
    if recipe.spellId then measureText(recipeDetailKnownLabel) end
    for i = 1, MAX_CHARS do
        if recipeDetailCharLabels[i]:IsShown() then measureText(recipeDetailCharLabels[i]) end
    end
    if recipe.creates then measureText(recipeDetailCreatesButton.text) end
    for i = 1, #reagents do measureText(recipeDetailReagentButtons[i].text) end
    recipeDetailFrame:SetWidth(math.max(200, ROW_HEIGHT + 2 + maxTextW + PADDING * 2 + 20))

    recipeDetailFrame:Show()
end

function initRecipeDetail()
    createDetailFrame()
end

function closeAllBrowserWindows()
    if recipeDetailFrame then
        recipeDetailFrame:Hide()
    end
end
