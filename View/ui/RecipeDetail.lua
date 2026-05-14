-- RecipeDetail.lua — floating detail popup shown when a recipe row is clicked.
-- Displays: recipe/item link, Known status + alt list, Creates row, and reagent list.
-- Layout is calculated dynamically in showRecipeDetail(); the frame height and width
-- auto-size to fit however many rows the selected recipe requires.

local recipeDetailFrame
local recipeDetailSpellButton
local recipeDetailKnownLabel
local recipeDetailSpecLabel
local recipeDetailCharLabels  = {}
local recipeDetailCreatesButton
local recipeDetailMaterialsHeader
local recipeDetailReagentButtons = {}

local ROW_HEIGHT = 16
local ROW_GAP    = 4
local PADDING    = 8
local INDENT     = 20
local MAX_CHARS  = 10

-- Maps item quality (0–5) to WoW's standard color hex codes (AARRGGBB).
-- 0=Poor(grey), 1=Common(white), 2=Uncommon(green), 3=Rare(blue), 4=Epic(purple), 5=Legendary(orange)
local QUALITY_COLOR = {
    [0] = "ff9d9d9d",
    [1] = "ffffffff",
    [2] = "ff1eff00",
    [3] = "ff0070dd",
    [4] = "ffa335ee",
    [5] = "ffff8000",
}

-- Constructs a clickable item hyperlink from pipeline data when the client cache lacks the item.
local function makeItemLink(id, name, quality)
    local color = QUALITY_COLOR[quality] or QUALITY_COLOR[1]
    return "|c" .. color .. "|Hitem:" .. id .. ":0:0:0:0:0:0:0|h[" .. name .. "]|h|r"
end

-- Priority: live GetItemInfo link (always correct) → pipeline name fallback → bare item ID.
-- Pipeline data is used when the item is not yet in the client cache at detail-open time.
local function resolveItemLink(id, pipelineName, pipelineQuality)
    local _, link = GetItemInfo(id)
    if link then return link end
    if pipelineName then return makeItemLink(id, pipelineName, pipelineQuality) end
    return "|cffffff00[" .. id .. "]|r"
end

-- Priority: pipeline icon (already fetched by the data pipeline) → live GetItemInfo texture → question mark.
local function resolveItemIcon(id, pipelineIcon)
    if pipelineIcon then return "Interface\\Icons\\" .. pipelineIcon end
    local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(id)
    return tex or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Inserts a link into whichever chat edit box is currently open.
-- Falls back to printing to the default chat frame when no edit box is visible,
-- so the link is never silently dropped.
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

-- Builds all child widgets once at load time.  Positions are set to placeholder values
-- here; showRecipeDetail() repositions everything dynamically each time it's called.
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

    -- Specialization label (Gnomish / Goblin) — position set dynamically, hidden by default
    recipeDetailSpecLabel = recipeDetailFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    recipeDetailSpecLabel:Hide()

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

-- Populates and shows the detail frame for the given recipe.
-- Layout flows top-to-bottom using a 'y' cursor (negative = downward in WoW anchor space).
-- Rows shown depend on the recipe: spell/item link is always first, then Known status,
-- then Creates, then reagents.  Frame height and width auto-fit at the end.
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

    -- Specialization badge — shown only for spec-exclusive recipes.
    -- 4dc8ed = gnomish cyan-blue; ff6600 = goblin orange.
    if recipe.specialization == "gnomish" then
        recipeDetailSpecLabel:ClearAllPoints()
        recipeDetailSpecLabel:SetPoint("TOPLEFT", recipeDetailFrame, "TOPLEFT", PADDING, y)
        recipeDetailSpecLabel:SetText("|cff4dc8ed[Gnomish Engineering]|r")
        recipeDetailSpecLabel:Show()
        y = y - ROW_HEIGHT - 2
    elseif recipe.specialization == "goblin" then
        recipeDetailSpecLabel:ClearAllPoints()
        recipeDetailSpecLabel:SetPoint("TOPLEFT", recipeDetailFrame, "TOPLEFT", PADDING, y)
        recipeDetailSpecLabel:SetText("|cffff6600[Goblin Engineering]|r")
        recipeDetailSpecLabel:Show()
        y = y - ROW_HEIGHT - 2
    else
        recipeDetailSpecLabel:Hide()
    end

    -- Known / Not Known + character list
    if recipe.spellId then
        local known    = ACC_Tracker.IsKnown(recipe.spellId)
        local whoKnows = ACC_Tracker.WhoKnows(recipe.spellId)

        recipeDetailKnownLabel:ClearAllPoints()
        recipeDetailKnownLabel:SetPoint("TOPLEFT", recipeDetailFrame, "TOPLEFT", PADDING, y)
        recipeDetailKnownLabel:SetText(known and "|cff00ff00Known|r" or "|cffff0000Not Known|r")
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
    if recipeDetailSpecLabel:IsShown() then measureText(recipeDetailSpecLabel) end  -- badge can be the widest row
    if recipe.spellId then measureText(recipeDetailKnownLabel) end
    for i = 1, MAX_CHARS do
        if recipeDetailCharLabels[i]:IsShown() then measureText(recipeDetailCharLabels[i]) end
    end
    if recipe.creates then measureText(recipeDetailCreatesButton.text) end
    for i = 1, #reagents do measureText(recipeDetailReagentButtons[i].text) end
    recipeDetailFrame:SetWidth(math.max(200, ROW_HEIGHT + 2 + maxTextW + PADDING * 2 + 20))

    recipeDetailFrame:Show()
end

-- Called from browserInit() so the detail frame is created alongside the main browser.
function initRecipeDetail()
    createDetailFrame()
end

-- Called by Browser.lua whenever the user switches category or profession,
-- so the stale detail panel doesn't stay open showing a different recipe's info.
function closeAllBrowserWindows()
    if recipeDetailFrame then
        recipeDetailFrame:Hide()
    end
end
