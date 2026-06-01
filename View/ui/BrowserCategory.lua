-- BrowserCategory.lua — category list building, panel rendering, and list filtering.
-- Extracted from BrowserRender.lua to keep each file focused.

local S                       = ACC_BrowserState
local professionCategoryOrder = ACC_BrowserConfig.professionCategoryOrder
local subCategoryOrder        = ACC_BrowserConfig.subCategoryOrder

-- Derives the ordered category list from S.recipeList + S.currentProfName.
-- Called by selectProfession and by the GET_ITEM_INFO_RECEIVED handler.
function ACC.buildCategoryList()
    local fixedOrder = professionCategoryOrder[S.currentProfName]
    if fixedOrder then
        local present = {}
        for _, recipe in ipairs(S.recipeList) do
            if recipe.resolvedCategory then present[recipe.resolvedCategory] = true end
            if recipe.category        then present[recipe.category]         = true end
        end
        local result = {}
        for _, cat in ipairs(fixedOrder) do
            if cat == "---" then
                if #result > 0 and result[#result] ~= "---" then
                    result[#result + 1] = "---"
                end
            elseif present[cat] then
                result[#result + 1] = cat
            end
        end
        if result[#result] == "---" then result[#result] = nil end
        return result
    end

    local slotOrder = {
        "Helm", "Shoulders", "Cloak", "Chest", "Gloves", "Belt", "Legs", "Boots", "Bracers",
        "Neck", "Ring", "Trinket", "Shirt", "Tabard",
        "---",
        "One-Hand", "Mainhand", "Offhand(Weapon)", "Two-Hand", "Shield", "Offhand",
        "Ranged", "Wand", "Thrown", "Ammo", "Quiver",
        "---",
        "Bags", "Misc",
    }

    local slotOrderSet = {}
    for _, cat in ipairs(slotOrder) do slotOrderSet[cat] = true end

    local seen, slotSet, manualList = {}, {}, {}
    for _, recipe in ipairs(S.recipeList) do
        if recipe.resolvedCategory and not seen[recipe.resolvedCategory] then
            seen[recipe.resolvedCategory] = true
            slotSet[recipe.resolvedCategory] = true
        end
        if recipe.category and not seen[recipe.category] then
            seen[recipe.category] = true
            if slotOrderSet[recipe.category] then
                slotSet[recipe.category] = true
            else
                manualList[#manualList + 1] = recipe.category
            end
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
    if slotList[#slotList] == "---" then slotList[#slotList] = nil end

    local categoryList = {}
    for _, cat in ipairs(slotList) do categoryList[#categoryList + 1] = cat end
    if #manualList > 0 then
        categoryList[#categoryList + 1] = "---"
        for _, cat in ipairs(manualList) do categoryList[#categoryList + 1] = cat end
    end
    return categoryList
end

-- Rebuilds the category panel buttons from the given list.
-- "---" entries are rendered as blank spacing rather than buttons.
function ACC.renderCategoryPanel(categoryList)
    for _, catButton in ipairs(S.categoryButtons) do
        catButton:Hide()
    end
    S.categoryButtons = {}
    local yOffset = 8
    for _, category in ipairs(categoryList) do
        if category == "---" then
            yOffset = yOffset + 25
        else
            local button = CreateFrame("Button", nil, S.categoryFrame)
            button:SetPoint("TOPLEFT", S.categoryFrame, "TOPLEFT", 8, -yOffset)
            button:SetHeight(20)
            button:SetWidth(148)
            button:SetScript("OnClick", function()
                ACC.closeAllBrowserWindows()
                S.activeCategory = category
                S.pageIndex = 1
                ACC.saveNavState()
                ACC.updateCategoryHighlight()
                ACC.renderPage()
            end)
            local bg = button:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(button)
            bg:SetTexture("Interface\\Buttons\\WHITE8X8")
            bg:SetVertexColor(0.1, 0.6, 0.1, 0.35)
            bg:Hide()
            button.selectedBg = bg

            local label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", button, "LEFT", 0, 0)
            label:SetText(category)
            button.categoryName = category
            button.label = label
            S.categoryButtons[#S.categoryButtons + 1] = button
            yOffset = yOffset + 20
        end
    end
    ACC.updateCategoryHighlight()
end

function ACC.updateCategoryHighlight()
    for _, btn in ipairs(S.categoryButtons) do
        if btn.categoryName == S.activeCategory then
            btn.selectedBg:Show()
            btn.label:SetText("|cff1eff00" .. btn.categoryName .. "|r")
        else
            btn.selectedBg:Hide()
            btn.label:SetText(btn.categoryName)
        end
    end
end

-- Returns recipes in S.recipeList that belong to the active category, sorted and
-- with blank separator entries inserted between display groups.
function ACC.getFilteredList()
    local result = {}
    for _, recipe in ipairs(S.recipeList) do
        if recipe.category == S.activeCategory or recipe.resolvedCategory == S.activeCategory then
            result[#result + 1] = recipe
        end
    end
    table.sort(result, function(a, b)
        local oa = subCategoryOrder[a.subCategory] or 99
        local ob = subCategoryOrder[b.subCategory] or 99
        if oa ~= ob then return oa < ob end
        local ga = a.displayGroup or 99
        local gb = b.displayGroup or 99
        if ga ~= gb then return ga < gb end
        local sa, sb = a.skill or 0, b.skill or 0
        if sa ~= sb then return sa < sb end
        return (a.name or "") < (b.name or "")
    end)
    local withSeps = {}
    local lastGroup = nil
    local lastSub   = nil
    for _, recipe in ipairs(result) do
        local g = recipe.displayGroup or 99
        local s = recipe.subCategory  or ""
        if lastGroup ~= nil and (g ~= lastGroup or s ~= lastSub) then
            if recipe.startsNewPage then
                -- Pad the current page with blank rows so this group starts on a fresh page.
                local rem = #withSeps % 40
                if rem ~= 0 then
                    for _ = 1, 40 - rem do
                        withSeps[#withSeps + 1] = { _separator = true }
                    end
                end
            end
            withSeps[#withSeps + 1] = { _separator = true, label = recipe.zoneGroup }
        elseif lastGroup == nil and recipe.zoneGroup then
            -- First group with a continent label: insert a header row before it.
            withSeps[#withSeps + 1] = { _separator = true, label = recipe.zoneGroup }
        end
        withSeps[#withSeps + 1] = recipe
        lastGroup = g
        lastSub   = s
    end
    return withSeps
end
