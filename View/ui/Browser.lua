local mainFrame
local categoryFrame

local recipeList = {}
local pageIndex = 1

local rowsPerPage = 20
local rowButtons = {}

local prevButton
local nextButton
local pageLabel

local activeCategory = nil
local categoryButtons = {}

local slotCategory = {                                               
      INVTYPE_HEAD          = "Helm",                               
      INVTYPE_SHOULDER      = "Shoulders",
      INVTYPE_BODY          = "Shirt",
      INVTYPE_CHEST         = "Chest",
      INVTYPE_ROBE          = "Chest",
      INVTYPE_WAIST         = "Belt",
      INVTYPE_LEGS          = "Legs",
      INVTYPE_FEET          = "Boots",
      INVTYPE_WRIST         = "Bracers",
      INVTYPE_HAND          = "Gloves",
      INVTYPE_TRINKET       = "Trinket",
      INVTYPE_BACK          = "Cloak",
      INVTYPE_WEAPON        = "One-Hand",
      INVTYPE_SHIELD        = "Shield",
      INVTYPE_2HWEAPON      = "Two-Hand",
      INVTYPE_WEAPONMAINHAND = "Mainhand",
      INVTYPE_WEAPONOFFHAND  = "Offhand(Weapon)",
      INVTYPE_HOLDABLE      = "Offhand",
      INVTYPE_RANGED        = "Ranged",
      INVTYPE_RANGEDRIGHT   = "Wand",
      INVTYPE_THROWN        = "Thrown",
      INVTYPE_BAG           = "Bags",
      INVTYPE_QUIVER        = "Quiver",
      INVTYPE_TABARD        = "Tabard",
  }

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
    mainFrame:Hide()
end

local function createCategoryPanel()
    categoryFrame = CreateFrame("Frame", "AccCategoryPanel", mainFrame, "InsetFrameTemplate")
    categoryFrame:SetWidth(160)
    categoryFrame:SetHeight(325)
    categoryFrame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -20, -60)
end
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
        button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -65 - (i - 1) * 16)
        button:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -195, -65 - (i - 1) * 16)

        local recipeName = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        recipeName:SetPoint("LEFT", button, "LEFT", 4, 0)
        button.recipeName = recipeName

        local skillText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        skillText:SetPoint("RIGHT", button, "RIGHT", -4, 0)
        button.skillText = skillText

        button:Hide()
    end
end

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

function browserInit()
    createMainFrame()
    createCategoryPanel()
    createDropdown()
    createRowButtons()
    createNavButtons()

end

function showBrowser()
    mainFrame:Show()
end

function selectProfession(profName)
    local recipeData = ACC_Data[profName] or {}
    recipeList = {}
    for _, recipe in ipairs(recipeData) do
        if not (recipe.skill and recipe.skill == 9999) then
            recipeList[#recipeList + 1] = recipe
        end
    end
    pageIndex = 1

    for _, recipe in ipairs(recipeList) do
        if recipe.creates then
            local equipLoc = select(9, GetItemInfo(recipe.creates.id))
            recipe.resolvedCategory = slotCategory[equipLoc]
        end
        if profName == "Tailoring" or profName == "Leatherworking" or profName== "Blacksmithing" then
            if recipe.resolvedCategory == nil then
                recipe.resolvedCategory = "Misc"
            end
        end
    end
    local slotOrder = {
        "Helm", "Shoulders", "Chest", "Gloves", "Belt", "Legs", "Boots", "Bracers",
        "Cloak", "Neck", "Ring", "Trinket", "Shirt", "Tabard",
        "---",
        "One-Hand", "Mainhand", "Offhand(Weapon)", "Two-Hand", "Shield", "Offhand",
        "Ranged", "Wand", "Thrown", "Ammo", "Quiver",
        "---",
        "Bags", "Misc",
    }
    local seen = {}
    local slotSet = {}
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
    activeCategory = "Misc"
    renderCategoryPanel(categoryList)
    renderPage()
end

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

function renderPage()
    local filteredList = getFilteredList()
    local totalPages = math.max(1, math.ceil(#filteredList / rowsPerPage))
    if totalPages == 1 then
        prevButton:Hide()
        nextButton:Hide()
    else
        prevButton:Show()
        nextButton:Show()
    end
    pageLabel:SetText("Page " .. pageIndex .. " / " .. totalPages)

    if pageIndex == 1 then prevButton:Disable() else prevButton:Enable() end
    if pageIndex == totalPages then nextButton:Disable() else nextButton:Enable() end

    
    local startIndex = (pageIndex - 1) * rowsPerPage + 1

    for i = 1, rowsPerPage do
        local recipe = filteredList[startIndex + i - 1]
        if recipe then
            rowButtons[i].recipeName:SetText(recipe.name)
            rowButtons[i].skillText:SetText(recipe.skill or "")
            rowButtons[i]:Show()
        else
            rowButtons[i].recipeName:SetText("")
            rowButtons[i].skillText:SetText("")
            rowButtons[i]:Hide()
        end
    end
end

function getFilteredList()
    local filteredresult = {}
    for _, filteredList in ipairs(recipeList) do
        if filteredList.category == activeCategory or filteredList.resolvedCategory == activeCategory then
            filteredresult[#filteredresult + 1] = filteredList
        end
    end
    return filteredresult
end