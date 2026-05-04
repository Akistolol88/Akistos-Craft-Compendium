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

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- Inserts a hyperlink into the open chat edit box, or prints it to chat if none is open.
local function insertLink(link)
    if ChatFrameEditBox and ChatFrameEditBox:IsVisible() then
        ChatFrameEditBox:Insert(link)
    else
        DEFAULT_CHAT_FRAME:AddMessage(link)
    end
end

-- ── Frame construction ────────────────────────────────────────────────────────

local function createDetailFrame()
    -- BasicFrameTemplate provides the standard WoW window chrome (background, border, close button)
    recipeDetailFrame = CreateFrame("Frame", "AccRecipeDetailFrame", UIParent, "BasicFrameTemplate")
    recipeDetailFrame:SetWidth(240)
    recipeDetailFrame:SetHeight(100)  -- resized dynamically in showRecipeDetail
    recipeDetailFrame:SetPoint("CENTER", UIParent, "CENTER", 320, 0)
    recipeDetailFrame:SetFrameStrata("DIALOG")
    recipeDetailFrame:EnableMouse(true)
    recipeDetailFrame:Hide()

    -- Spell row: hover shows spell tooltip, click inserts link
    recipeDetailSpellButton = CreateFrame("Button", "AccRecipeDetailSpellBtn", recipeDetailFrame)
    recipeDetailSpellButton:SetHeight(ROW_HEIGHT)
    recipeDetailSpellButton:EnableMouse(true)
    recipeDetailSpellButton:RegisterForClicks("LeftButtonUp")
    local spellText = recipeDetailSpellButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    spellText:SetPoint("LEFT", recipeDetailSpellButton, "LEFT", 0, 0)
    recipeDetailSpellButton.text = spellText

    -- Recipe item row: shows the physical Pattern/Plans/etc. if one exists
    recipeDetailRecipeItemButton = CreateFrame("Button", nil, recipeDetailFrame)
    recipeDetailRecipeItemButton:SetHeight(ROW_HEIGHT)
    recipeDetailRecipeItemButton:EnableMouse(true)
    recipeDetailRecipeItemButton:RegisterForClicks("LeftButtonUp")
    local recipeItemText = recipeDetailRecipeItemButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    recipeItemText:SetPoint("LEFT", recipeDetailRecipeItemButton, "LEFT", 0, 0)
    recipeDetailRecipeItemButton.text = recipeItemText

    -- Creates row: hidden for spells that produce no item (e.g. some enchants)
    recipeDetailCreatesButton = CreateFrame("Button", nil, recipeDetailFrame)
    recipeDetailCreatesButton:SetHeight(ROW_HEIGHT)
    recipeDetailCreatesButton:EnableMouse(true)
    recipeDetailCreatesButton:RegisterForClicks("LeftButtonUp")
    local createsText = recipeDetailCreatesButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    createsText:SetPoint("LEFT", recipeDetailCreatesButton, "LEFT", 0, 0)
    recipeDetailCreatesButton.text = createsText

    -- Static "Materials:" section header
    recipeDetailMaterialsHeader = recipeDetailFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    recipeDetailMaterialsHeader:SetText("|cffffff99Materials:|r")

    -- Pre-build all reagent rows; unused rows are hidden per recipe
    for i = 1, 8 do
        local btn = CreateFrame("Button", nil, recipeDetailFrame)
        btn:SetHeight(ROW_HEIGHT)
        btn:EnableMouse(true)
        btn:RegisterForClicks("LeftButtonUp")
        local itemText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        itemText:SetPoint("LEFT", btn, "LEFT", 0, 0)
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

    -- Spell row
    local spellLink = makeSpellLink(recipe)
    recipeDetailSpellButton.text:SetText(spellLink)
    recipeDetailSpellButton:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING,      y)
    recipeDetailSpellButton:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -(PADDING + 20), y)
    recipeDetailSpellButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(recipeDetailSpellButton, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(spellLink)
        GameTooltip:Show()
    end)
    recipeDetailSpellButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    recipeDetailSpellButton:SetScript("OnClick", function() insertLink(spellLink) end)
    y = y - ROW_HEIGHT - ROW_GAP

    -- Recipe item row (Pattern/Plans/Schematic/etc.) — only shown when recipeItemId is set
    if recipe.recipeItemId then
        -- Use stored name as fallback; GetItemInfo may return nil for uncached items
        local recipeItemLink = select(2, GetItemInfo(recipe.recipeItemId))
        local fallbackName   = recipe.recipeItemName and ("|cffffff00" .. recipe.recipeItemName .. "|r")
                               or ("|cffffff00[" .. recipe.recipeItemId .. "]|r")
        recipeDetailRecipeItemButton.text:SetText(recipeItemLink or fallbackName)
        recipeDetailRecipeItemButton:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING,         y)
        recipeDetailRecipeItemButton:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -(PADDING + 20), y)
        -- SetHyperlink works even when item is not in client cache
        recipeDetailRecipeItemButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(recipeDetailRecipeItemButton, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. recipe.recipeItemId)
            GameTooltip:Show()
        end)
        recipeDetailRecipeItemButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        -- Re-check GetItemInfo at click time so hovering (which caches it) makes it immediately linkable
        recipeDetailRecipeItemButton:SetScript("OnClick", function()
            local link = select(2, GetItemInfo(recipe.recipeItemId))
            if link then insertLink(link) end
        end)
        recipeDetailRecipeItemButton:Show()
        y = y - ROW_HEIGHT - ROW_GAP
    else
        recipeDetailRecipeItemButton:SetScript("OnEnter", nil)
        recipeDetailRecipeItemButton:SetScript("OnLeave", nil)
        recipeDetailRecipeItemButton:SetScript("OnClick", nil)
        recipeDetailRecipeItemButton:Hide()
    end

    -- Creates row (shown only when the recipe produces an item)
    if recipe.creates then
        -- GetItemInfo may return nil if the item isn't in the client cache yet
        local itemLink    = select(2, GetItemInfo(recipe.creates.id))
        local displayText = "Creates: " .. (itemLink or ("|cffffff00[" .. recipe.creates.id .. "]|r"))
        if recipe.creates.count and recipe.creates.count > 1 then
            displayText = displayText .. " x" .. recipe.creates.count
        end
        recipeDetailCreatesButton.text:SetText(displayText)
        recipeDetailCreatesButton:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING,      y)
        recipeDetailCreatesButton:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -(PADDING + 20), y)
        recipeDetailCreatesButton:SetScript("OnEnter", function()
            if itemLink then
                GameTooltip:SetOwner(recipeDetailCreatesButton, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(itemLink)
                GameTooltip:Show()
            end
        end)
        recipeDetailCreatesButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        recipeDetailCreatesButton:SetScript("OnClick", function()
            if itemLink then insertLink(itemLink) end
        end)
        recipeDetailCreatesButton:Show()
        y = y - ROW_HEIGHT - ROW_GAP
    else
        recipeDetailCreatesButton:Hide()
    end

    -- Materials header
    y = y - 4  -- extra breathing room before the section label
    recipeDetailMaterialsHeader:SetPoint("TOPLEFT", recipeDetailFrame, "TOPLEFT", PADDING, y)
    y = y - ROW_HEIGHT - 2

    -- Reagent rows
    local reagents = recipe.reagents or {}
    for i = 1, 8 do
        local btn     = recipeDetailReagentButtons[i]
        local reagent = reagents[i]
        if reagent then
            -- Capture link in a local so the closure holds the correct value for this reagent
            local link = select(2, GetItemInfo(reagent.id))
            btn.text:SetText("  " .. (link or ("|cffffff00[" .. reagent.id .. "]|r")) .. " x" .. reagent.count)
            btn:SetPoint("TOPLEFT",  recipeDetailFrame, "TOPLEFT",  PADDING, y)
            btn:SetPoint("TOPRIGHT", recipeDetailFrame, "TOPRIGHT", -PADDING, y)
            btn:SetScript("OnEnter", function()
                if link then
                    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(link)
                    GameTooltip:Show()
                end
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btn:SetScript("OnClick", function()
                if link then insertLink(link) end
            end)
            btn:Show()
            y = y - ROW_HEIGHT
        else
            -- Clear stale scripts so a previous recipe's closure can't fire on an empty row
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn:SetScript("OnClick", nil)
            btn:Hide()
        end
    end

    -- Shrink or grow the frame to fit exactly what's visible
    recipeDetailFrame:SetHeight(math.abs(y) + PADDING + TITLE_BAR)
    recipeDetailFrame:Show()
end
