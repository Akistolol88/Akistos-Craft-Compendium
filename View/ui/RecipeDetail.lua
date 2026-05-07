-- ── Locals ───────────────────────────────────────────────────────────────────

local recipeDetailFrame
local recipeDetailSpellButton
local recipeDetailRecipeItemButton
local recipeDetailCreatesButton
local recipeDetailMaterialsHeader
local recipeDetailReagentButtons = {}  -- up to 8 rows; vanilla recipes never exceed this


local PADDING    = 8
local TITLE_BAR  = 22  -- BasicFrameTemplate title bar height; content starts below this
local ROW_HEIGHT = 16
local ROW_GAP    = 4

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

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- Inserts a hyperlink into the open chat edit box.
-- LeftButtonDown fires on press before WoW removes focus from the edit box.
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

-- Returns a proper WoW item hyperlink for inserting into chat.
-- GetItemInfo always produces the correct server-side format (includes player level etc.).
-- Our custom makeItemLink is only a display fallback for uncached items.
local function resolveItemLink(id, pipelineName, pipelineQuality)
    local _, link = GetItemInfo(id)
    if link then return link end
    if pipelineName then return makeItemLink(id, pipelineName, pipelineQuality) end
    return "|cffffff00[" .. id .. "]|r"
end

-- Returns an icon texture path: pipeline icon first, GetItemInfo fallback, then question mark.
local function resolveItemIcon(id, pipelineIcon)
    if pipelineIcon then return "Interface\\Icons\\" .. pipelineIcon end
    local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(id)
    return tex or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- ── Frame construction ────────────────────────────────────────────────────────

local function createDetailFrame()
    -- BasicFrameTemplate provides the standard WoW window chrome (background, border, close button)
    recipeDetailFrame = CreateFrame("Frame", "AccRecipeDetailFrame", UIParent, "BasicFrameTemplate")
    recipeDetailFrame:SetWidth(280)
    recipeDetailFrame:SetHeight(100)  -- resized dynamically in showRecipeDetail
    recipeDetailFrame:SetPoint("CENTER", UIParent, "CENTER", 320, 0)
    recipeDetailFrame:SetFrameStrata("DIALOG")
    recipeDetailFrame:EnableMouse(true)
    recipeDetailFrame:Hide()

    local function addIcon(parent)
        local icon = parent:CreateTexture(nil, "OVERLAY")
        icon:SetWidth(ROW_HEIGHT)
        icon:SetHeight(ROW_HEIGHT)
        icon:SetPoint("LEFT", parent, "LEFT", 0, 0)
        return icon
    end

    -- Spell row: hover shows spell tooltip, click inserts link
    recipeDetailSpellButton = CreateFrame("Button", "AccRecipeDetailSpellBtn", recipeDetailFrame)
    recipeDetailSpellButton:SetHeight(ROW_HEIGHT)
    recipeDetailSpellButton:EnableMouse(true)
    recipeDetailSpellButton:RegisterForClicks("LeftButtonDown")
    recipeDetailSpellButton.icon = addIcon(recipeDetailSpellButton)
    local spellText = recipeDetailSpellButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    spellText:SetPoint("LEFT", recipeDetailSpellButton, "LEFT", ROW_HEIGHT + 2, 0)
    spellText:SetJustifyH("LEFT")
    recipeDetailSpellButton.text = spellText

    -- Recipe item row: shows the physical Pattern/Plans/etc. if one exists
    recipeDetailRecipeItemButton = CreateFrame("Button", nil, recipeDetailFrame)
    recipeDetailRecipeItemButton:SetHeight(ROW_HEIGHT)
    recipeDetailRecipeItemButton:EnableMouse(true)
    recipeDetailRecipeItemButton:RegisterForClicks("LeftButtonDown")
    recipeDetailRecipeItemButton.icon = addIcon(recipeDetailRecipeItemButton)
    local recipeItemText = recipeDetailRecipeItemButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    recipeItemText:SetPoint("LEFT", recipeDetailRecipeItemButton, "LEFT", ROW_HEIGHT + 2, 0)
    recipeItemText:SetJustifyH("LEFT")
    recipeDetailRecipeItemButton.text = recipeItemText

    -- Creates row: hidden for spells that produce no item (e.g. some enchants)
    recipeDetailCreatesButton = CreateFrame("Button", nil, recipeDetailFrame)
    recipeDetailCreatesButton:SetHeight(ROW_HEIGHT)
    recipeDetailCreatesButton:EnableMouse(true)
    recipeDetailCreatesButton:RegisterForClicks("LeftButtonDown")
    recipeDetailCreatesButton.icon = addIcon(recipeDetailCreatesButton)
    local createsText = recipeDetailCreatesButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    createsText:SetPoint("LEFT", recipeDetailCreatesButton, "LEFT", ROW_HEIGHT + 2, 0)
    createsText:SetJustifyH("LEFT")
    recipeDetailCreatesButton.text = createsText

    -- Static "Materials:" section header
    recipeDetailMaterialsHeader = recipeDetailFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    recipeDetailMaterialsHeader:SetText("|cffffff99Materials:|r")

    -- Pre-build all reagent rows; unused rows are hidden per recipe
    for i = 1, 8 do
        local btn = CreateFrame("Button", nil, recipeDetailFrame)
        btn:SetHeight(ROW_HEIGHT)
        btn:EnableMouse(true)
        btn:RegisterForClicks("LeftButtonDown")
        btn.icon = addIcon(btn)
        local itemText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        itemText:SetPoint("LEFT", btn, "LEFT", ROW_HEIGHT + 2, 0)
        itemText:SetJustifyH("LEFT")
        btn.text = itemText
        btn:Hide()
        recipeDetailReagentButtons[i] = btn
    end
end

-- ── Public API ────────────────────────────────────────────────────────────────

-- Entry point called from browserInit; builds all detail frame widgets once at load time.
function initRecipeDetail()
    createDetailFrame()
end

-- Called when the browser closes; hides all sub-windows.
function closeAllBrowserWindows()
    if recipeDetailFrame then recipeDetailFrame:Hide() end
end

-- Populates and shows the detail panel for the given recipe.
-- Repositions all rows dynamically so the frame fits its content exactly.
function showRecipeDetail(recipe, btn)
    if not recipe then return end

    -- Anchor below the clicked row button; clear any previous position first
    recipeDetailFrame:ClearAllPoints()
    if btn then
        recipeDetailFrame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    else
        recipeDetailFrame:SetPoint("CENTER", UIParent, "CENTER", 320, 0)
    end

    local y = -(TITLE_BAR + PADDING)  -- start below the BasicFrameTemplate title bar

    -- Recipe link row: pattern/plans item if available, spell link as fallback
    local spellLink = makeSpellLink(recipe)
    if recipe.recipeItemId then
        local pipelineLink = recipe.recipeItemName and makeItemLink(recipe.recipeItemId, recipe.recipeItemName, recipe.recipeItemQuality)
        local _, cachedLink = GetItemInfo(recipe.recipeItemId)
        recipeDetailSpellButton.text:SetText(cachedLink or pipelineLink or spellLink)
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
            -- GetItemInfo returns the correct server-side link format (hover loads it into cache).
            local _, freshLink = GetItemInfo(recipe.recipeItemId)
            insertLink(freshLink or spellLink)
        end)
    else
        recipeDetailSpellButton.text:SetText(spellLink)
        recipeDetailSpellButton.icon:SetTexture(
            recipe.creates and recipe.creates.icon and ("Interface\\Icons\\" .. recipe.creates.icon)
            or nil)
        recipeDetailSpellButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(recipeDetailSpellButton, "ANCHOR_NONE")
            GameTooltip:SetPoint("BOTTOMLEFT", recipeDetailSpellButton, "TOPLEFT", 0, 2)
            GameTooltip:SetHyperlink(spellLink)
            GameTooltip:Show()
        end)
        recipeDetailSpellButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        recipeDetailSpellButton:SetScript("OnClick", function() insertLink(spellLink) end)
    end
    recipeDetailSpellButton:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING,      y)
    recipeDetailSpellButton:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -(PADDING + 20), y)
    y = y - ROW_HEIGHT - ROW_GAP

    recipeDetailRecipeItemButton:SetScript("OnEnter", nil)
    recipeDetailRecipeItemButton:SetScript("OnLeave", nil)
    recipeDetailRecipeItemButton:SetScript("OnClick", nil)
    recipeDetailRecipeItemButton:Hide()

    -- Creates row (shown only when the recipe produces an item)
    if recipe.creates then
        local itemLink = resolveItemLink(recipe.creates.id, recipe.creates.name, recipe.creates.quality)
        local displayText = "Creates: " .. itemLink
        if recipe.creates.count and recipe.creates.count > 1 then
            displayText = displayText .. " x" .. recipe.creates.count
        end
        recipeDetailCreatesButton.icon:SetTexture(resolveItemIcon(recipe.creates.id, recipe.creates.icon))
        recipeDetailCreatesButton.text:SetText(displayText)
        recipeDetailCreatesButton:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING,      y)
        recipeDetailCreatesButton:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -(PADDING + 20), y)
        recipeDetailCreatesButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(recipeDetailCreatesButton, "ANCHOR_NONE")
            GameTooltip:SetPoint("BOTTOMLEFT", recipeDetailCreatesButton, "TOPLEFT", 0, 2)
            GameTooltip:SetHyperlink("item:" .. recipe.creates.id)
            GameTooltip:Show()
        end)
        recipeDetailCreatesButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        recipeDetailCreatesButton:SetScript("OnClick", function() insertLink(itemLink) end)
        recipeDetailCreatesButton:Show()
        y = y - ROW_HEIGHT - ROW_GAP
    else
        recipeDetailCreatesButton:Hide()
    end

    -- Materials header
    y = y - 4
    recipeDetailMaterialsHeader:SetPoint("TOPLEFT", recipeDetailFrame, "TOPLEFT", PADDING, y)
    y = y - ROW_HEIGHT - 2

    -- Reagent rows
    local reagents = recipe.reagents or {}
    for i = 1, 8 do
        local btn     = recipeDetailReagentButtons[i]
        local reagent = reagents[i]
        if reagent then
            local link = resolveItemLink(reagent.id, reagent.name, reagent.quality)
            btn.icon:SetTexture(resolveItemIcon(reagent.id, reagent.icon))
            btn.text:SetText(link .. " x" .. reagent.count)
            btn:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING, y)
            btn:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -PADDING, y)
            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_NONE")
                GameTooltip:SetPoint("BOTTOMLEFT", btn, "TOPLEFT", 0, 2)
                GameTooltip:SetHyperlink("item:" .. reagent.id)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btn:SetScript("OnClick", function() insertLink(link) end)
            btn:Show()
            y = y - ROW_HEIGHT
        else
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn:SetScript("OnClick", nil)
            btn.icon:SetTexture(nil)
            btn:Hide()
        end
    end

    recipeDetailFrame:SetHeight(math.abs(y) + PADDING + TITLE_BAR)

    -- Auto-size width to fit the longest line so nothing gets clipped.
    -- GetStringWidth() returns the natural rendered width of the text.
    local maxTextW = 0
    local function measureText(fs)
        local w = fs:GetStringWidth()
        if w > maxTextW then maxTextW = w end
    end
    measureText(recipeDetailSpellButton.text)
    if recipe.creates then measureText(recipeDetailCreatesButton.text) end
    for i = 1, #(recipe.reagents or {}) do
        measureText(recipeDetailReagentButtons[i].text)
    end
    -- icon (ROW_HEIGHT) + gap (2) + text + padding both sides + close button margin (20)
    local neededW = ROW_HEIGHT + 2 + maxTextW + PADDING * 2 + 20
    recipeDetailFrame:SetWidth(math.max(200, neededW))

    recipeDetailFrame:Show()
end
