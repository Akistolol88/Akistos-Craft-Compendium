-- ── Locals ───────────────────────────────────────────────────────────────────

local mainFrame
local categoryFrame

local recipeList = {}   -- full list for the current profession, excluding header entries
local pageIndex  = 1

local rowsPerPage = 20
local rowButtons  = {}  -- pre-built row buttons reused across pages

local prevButton
local nextButton
local pageLabel

local activeCategory  = nil
local categoryButtons = {}  -- rebuilt each time a profession is selected

-- Maps WoW INVTYPE_* constants to the display category shown in the panel.
-- INVTYPE_ROBE is a chest-slot robe, so it shares the "Chest" category with INVTYPE_CHEST.
local slotCategory = {
    INVTYPE_HEAD           = "Helm",
    INVTYPE_SHOULDER       = "Shoulders",
    INVTYPE_BODY           = "Shirt",
    INVTYPE_CHEST          = "Chest",
    INVTYPE_ROBE           = "Chest",
    INVTYPE_WAIST          = "Belt",
    INVTYPE_LEGS           = "Legs",
    INVTYPE_FEET           = "Boots",
    INVTYPE_WRIST          = "Bracers",
    INVTYPE_HAND           = "Gloves",
    INVTYPE_TRINKET        = "Trinket",
    INVTYPE_BACK           = "Cloak",
    INVTYPE_WEAPON         = "One-Hand",
    INVTYPE_SHIELD         = "Shield",
    INVTYPE_2HWEAPON       = "Two-Hand",
    INVTYPE_WEAPONMAINHAND = "Mainhand",
    INVTYPE_WEAPONOFFHAND  = "Offhand(Weapon)",
    INVTYPE_HOLDABLE       = "Offhand",
    INVTYPE_RANGED         = "Ranged",
    INVTYPE_RANGEDRIGHT    = "Wand",
    INVTYPE_THROWN         = "Thrown",
    INVTYPE_BAG            = "Bags",
    INVTYPE_QUIVER         = "Quiver",
    INVTYPE_TABARD         = "Tabard",
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- Builds a clickable spell hyperlink string for use in tooltips and chat.
function makeSpellLink(recipe)
    return "|cff71d5ff|Hspell:" .. recipe.spellId .. "|h[" .. recipe.name .. "]|h|r"
end

-- ── Frame construction ────────────────────────────────────────────────────────

local function createMainFrame()
    mainFrame = CreateFrame("Frame", "AccMainFrame", UIParent, "BasicFrameTemplate")
    mainFrame:SetWidth(580)
    mainFrame:SetHeight(425)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    -- Close all sub-windows when the browser is hidden (including via the template's close button)
    mainFrame:SetScript("OnHide", function() closeAllBrowserWindows() end)
    mainFrame:Hide()
end

-- Creates the right-side panel that lists filterable categories for the active profession.
local function createCategoryPanel()
    categoryFrame = CreateFrame("Frame", "AccCategoryPanel", mainFrame, "InsetFrameTemplate")
    categoryFrame:SetWidth(160)
    categoryFrame:SetHeight(325)
    categoryFrame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -20, -60)
end

-- Creates the profession selector dropdown in the top-left of the browser.
local function createDropdown()
    local dropDownProffessions = CreateFrame("Frame", "AccProfessionDropdown", mainFrame, "UIDropDownMenuTemplate")
    dropDownProffessions:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -30)
    UIDropDownMenu_Initialize(dropDownProffessions, function()
        for i, group in ipairs(GetProfessionGroups()) do
            UIDropDownMenu_AddButton({ text = group.title, isTitle = true, notCheckable = true })
            for j, profName in ipairs(group.professions) do
                UIDropDownMenu_AddButton({
                    text = profName,
                    func = function()
                        UIDropDownMenu_SetText(dropDownProffessions, profName)
                        selectProfession(profName)
                    end,
                    notCheckable = true
                })
            end
            if i < #GetProfessionGroups() then
                UIDropDownMenu_AddButton({ isSeparator = true, notCheckable = true })
            end
        end
    end)
end

local function createRowButtons()
    for i = 1, rowsPerPage do
        local button = CreateFrame("Button", "AccRecipeRow" .. i, mainFrame)
        rowButtons[i] = button
        button:SetHeight(16)
        button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12,   -65 - (i - 1) * 16)
        button:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -195, -65 - (i - 1) * 16)

        local recipeName = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        recipeName:SetPoint("LEFT", button, "LEFT", 4, 0)
        button.recipeName = recipeName

        local skillText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        skillText:SetPoint("RIGHT", button, "RIGHT", -4, 0)
        button.skillText = skillText

        -- button.recipe is set per-render; closures reference it via the button local, not 'this'
        button:SetScript("OnClick", function() onRecipeClick(button.recipe, button) end)
        button:SetScript("OnEnter", function()
            if button.recipe then
                GameTooltip:SetOwner(button, "ANCHOR_CURSOR")
                GameTooltip:SetHyperlink(makeSpellLink(button.recipe))
                GameTooltip:Show()
            end
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        button:Hide()
    end
end

-- Creates the Prev / Next pagination buttons and the centered page label.
local function createNavButtons()
    prevButton = CreateFrame("Button", "AccPrevButton", mainFrame, "UIPanelButtonTemplate")
    prevButton:SetWidth(80)
    prevButton:SetHeight(22)
    prevButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 12, 8)
    prevButton:SetText("< Prev")
    prevButton:SetScript("OnClick", function()
        pageIndex = pageIndex - 1
        renderPage()
    end)

    nextButton = CreateFrame("Button", "AccNextButton", mainFrame, "UIPanelButtonTemplate")
    nextButton:SetWidth(80)
    nextButton:SetHeight(22)
    nextButton:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -20, 8)
    nextButton:SetText("Next >")
    nextButton:SetScript("OnClick", function()
        pageIndex = pageIndex + 1
        renderPage()
    end)

    pageLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pageLabel:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 13)
    pageLabel:SetText("")
end

-- ── Public API ────────────────────────────────────────────────────────────────

-- Entry point called from Core.lua on addon load; constructs all browser frames.
function browserInit()
    createMainFrame()
    createCategoryPanel()
    createDropdown()
    createRowButtons()
    createNavButtons()
    initRecipeDetail()
end

-- Shows the main browser window.
function showBrowser()
    mainFrame:Show()
end

-- Hides the browser and all child windows (detail panel, etc.).
function hideBrowser()
    mainFrame:Hide()
    closeAllBrowserWindows()
end

-- Loads a profession into the browser: filters recipes, resolves slot categories,
-- builds the ordered category list, and renders the first page.
function selectProfession(profName)
    local recipeData = ACC_Data[profName] or {}
    recipeList = {}
    for _, recipe in ipairs(recipeData) do
        -- skill == 9999 is the sentinel used for the profession's own "learn" entry
        if not (recipe.skill and recipe.skill == 9999) then
            recipeList[#recipeList + 1] = recipe
        end
    end
    pageIndex = 1

    -- Attempt runtime slot detection via GetItemInfo.
    -- Returns nil for uncached items; those fall through to "Misc" for gear professions.
    for _, recipe in ipairs(recipeList) do
        if recipe.creates then
            local equipLoc = select(9, GetItemInfo(recipe.creates.id))
            recipe.resolvedCategory = slotCategory[equipLoc]
        end
        if profName == "Tailoring" or profName == "Leatherworking" or profName == "Blacksmithing" then
            if recipe.resolvedCategory == nil then
                recipe.resolvedCategory = "Misc"
            end
        end
    end

    -- Desired display order for slot-based categories.
    -- "---" entries become visual separators between armor / weapons / containers.
    local slotOrder = {
        "Helm", "Shoulders", "Cloak", "Chest", "Gloves", "Belt", "Legs", "Boots", "Bracers",
        "Neck", "Ring", "Trinket", "Shirt", "Tabard",
        "---",
        "One-Hand", "Mainhand", "Offhand(Weapon)", "Two-Hand", "Shield", "Offhand",
        "Ranged", "Wand", "Thrown", "Ammo", "Quiver",
        "---",
        "Bags", "Misc",
    }

    -- Split into slot-detected categories (ordered by slotOrder) and manual pipeline
    -- tags (recipe.category from manual_categories.json, appended after a separator).
    local seen      = {}
    local slotSet   = {}
    local manualList = {}
    for _, recipe in ipairs(recipeList) do
        if recipe.resolvedCategory and not seen[recipe.resolvedCategory] then
            seen[recipe.resolvedCategory] = true
            slotSet[recipe.resolvedCategory] = true
        end
        if recipe.category and not seen[recipe.category] then
            seen[recipe.category] = true
            manualList[#manualList + 1] = recipe.category
        end
    end

    -- Build slot list in display order, suppressing leading/trailing/duplicate separators.
    local slotList = {}
    for _, cat in ipairs(slotOrder) do
        if cat == "---" then
            if #slotList > 0 and slotList[#slotList] ~= "---" then
                slotList[#slotList + 1] = cat
            end
        elseif slotSet[cat] then
            slotList[#slotList + 1] = cat
        end
    end
    if slotList[#slotList] == "---" then
        slotList[#slotList] = nil
    end

    local categoryList = {}
    for _, cat in ipairs(slotList) do
        categoryList[#categoryList + 1] = cat
    end
    if #manualList > 0 then
        categoryList[#categoryList + 1] = "---"
        for _, cat in ipairs(manualList) do
            categoryList[#categoryList + 1] = cat
        end
    end

    -- Default to "Misc" so gear professions land on the catch-all bucket on first load.
    activeCategory = "Misc"
    renderCategoryPanel(categoryList)
    renderPage()
end

-- Rebuilds the category panel buttons from the given list.
-- "---" entries are rendered as blank spacing rather than buttons.
function renderCategoryPanel(categoryList)
    for _, catButton in ipairs(categoryButtons) do
        catButton:Hide()
    end
    categoryButtons = {}
    local yOffset = 8
    for _, category in ipairs(categoryList) do
        if category == "---" then
            yOffset = yOffset + 6
        else
            local button = CreateFrame("Button", nil, categoryFrame)
            button:SetPoint("TOPLEFT", categoryFrame, "TOPLEFT", 8, -yOffset)
            button:SetHeight(16)
            button:SetWidth(140)
            button:SetScript("OnClick", function()
                activeCategory = category
                pageIndex = 1
                renderPage()
            end)
            local label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            label:SetPoint("LEFT", button, "LEFT", 0, 0)
            label:SetText(category)
            categoryButtons[#categoryButtons + 1] = button
            yOffset = yOffset + 16
        end
    end
end

-- Renders the current page of the active category into the row buttons.
function renderPage()
    local filteredList = getFilteredList()
    local totalPages   = math.max(1, math.ceil(#filteredList / rowsPerPage))

    if totalPages == 1 then
        prevButton:Hide()
        nextButton:Hide()
    else
        prevButton:Show()
        nextButton:Show()
    end
    pageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)

    if pageIndex == 1          then prevButton:Disable() else prevButton:Enable() end
    if pageIndex == totalPages then nextButton:Disable() else nextButton:Enable() end

    local startIndex = (pageIndex - 1) * rowsPerPage + 1
    for i = 1, rowsPerPage do
        local recipe = filteredList[startIndex + i - 1]
        if recipe then
            rowButtons[i].recipeName:SetText(recipe.name)
            rowButtons[i].skillText:SetText(recipe.skill or "")
            rowButtons[i].recipe = recipe  -- stored so OnClick/OnEnter closures can read it
            rowButtons[i]:Show()
        else
            rowButtons[i].recipeName:SetText("")
            rowButtons[i].skillText:SetText("")
            rowButtons[i].recipe = nil
            rowButtons[i]:Hide()
        end
    end
end

-- Returns recipes in recipeList that belong to the active category.
-- A recipe matches if either its pipeline tag (category) or its runtime-resolved
-- slot (resolvedCategory) matches activeCategory.
function getFilteredList()
    local result = {}
    for _, recipe in ipairs(recipeList) do
        if recipe.category == activeCategory or recipe.resolvedCategory == activeCategory then
            result[#result + 1] = recipe
        end
    end
    return result
end

-- Opens the detail panel for the clicked recipe, anchored below the row button.
function onRecipeClick(recipe, btn)
    if not recipe then return end
    showRecipeDetail(recipe, btn)
end
