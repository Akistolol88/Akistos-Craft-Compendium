-- BrowserRender.lua — category panel, page rendering, list filtering, and click handling.
-- All functions read/write shared state via ACC_BrowserState (defined in BrowserConfig.lua).

local S = ACC_BrowserState

local rowsPerPage             = 40
local professionCategoryOrder = ACC_BrowserConfig.professionCategoryOrder
local subCategoryOrder        = ACC_BrowserConfig.subCategoryOrder
local profFallbackIcon        = ACC_BrowserConfig.profFallbackIcon

local function getSkinningSkill()
    for i = 1, GetNumSkillLines() do
        local name, _, _, rank = GetSkillLineInfo(i)
        if name == "Skinning" then return rank end
    end
    return 0
end

-- Returns mob level ranges for each skinning difficulty colour given current skill.
-- Thresholds (your skill − required skill): orange 0–9, yellow 10–24, green 25–49, grey 50+.
local function getSkinningRanges(skill)
    local maxLevel = skill <= 100 and (math.floor(skill / 10) + 10) or math.floor(skill / 5)
    local function maxLvlForReq(req)
        if req < 0    then return 0 end
        if req <= 100 then return math.floor(req / 10) + 10 end
        return math.floor(req / 5)
    end
    local greyMax   = maxLvlForReq(skill - 50)
    local greenMax  = maxLvlForReq(skill - 25)
    local yellowMax = maxLvlForReq(skill - 10)
    return {
        maxLevel = maxLevel,
        grey     = { max = greyMax },
        green    = { min = greyMax   + 1, max = greenMax  },
        yellow   = { min = greenMax  + 1, max = yellowMax },
        orange   = { min = yellowMax + 1, max = maxLevel  },
    }
end

function ACC.saveNavState()
    if not ACC_CharacterData then ACC_CharacterData = {} end
    if not ACC_CharacterData.lastState then ACC_CharacterData.lastState = {} end
    ACC_CharacterData.lastState[S.currentProfName] = { category = S.activeCategory, page = S.pageIndex }
end

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
                ACC.renderPage()
            end)
            local label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", button, "LEFT", 0, 0)
            label:SetText(category)
            S.categoryButtons[#S.categoryButtons + 1] = button
            yOffset = yOffset + 20
        end
    end
end

-- Renders the current page of the active category into the row buttons.
function ACC.renderPage()
    local filteredList = ACC.getFilteredList()
    local totalPages   = math.max(1, math.ceil(#filteredList / rowsPerPage))

    if totalPages == 1 then
        S.prevButton:Hide()
        S.nextButton:Hide()
    else
        S.prevButton:Show()
        S.nextButton:Show()
    end
    S.pageLabel:SetText("Page " .. S.pageIndex .. " / " .. totalPages)

    if S.pageIndex == 1          then S.prevButton:Disable() else S.prevButton:Enable() end
    if S.pageIndex == totalPages then S.nextButton:Disable() else S.nextButton:Enable() end

    local startIndex = (S.pageIndex - 1) * rowsPerPage + 1

    for i = 1, rowsPerPage do
        local recipe = filteredList[startIndex + i - 1]
        if recipe then
            if recipe._separator then
                S.rowButtons[i].icon:SetTexture(nil)
                S.rowButtons[i].recipeName:SetText("")
                S.rowButtons[i].skillText:SetText("")
                S.rowButtons[i].recipe = nil
                S.rowButtons[i]:Show()
            elseif recipe._formula then
                -- Plain text row — no icon, no skill number, no spell link.
                S.rowButtons[i].icon:SetTexture(nil)
                S.rowButtons[i].recipeName:SetText("|cffffffff" .. (recipe.name or "") .. "|r")
                S.rowButtons[i].skillText:SetText("")
                S.rowButtons[i].recipe = recipe
                S.rowButtons[i]:Show()
            elseif recipe._skill_calc then
                -- Live calculation: read current Skinning skill and compute max skinnable mob level.
                local skill = getSkinningSkill()
                local maxLevel
                if skill <= 100 then
                    maxLevel = math.floor(skill / 10) + 10
                else
                    maxLevel = math.floor(skill / 5)
                end
                local text = skill > 0
                    and ("|cffffff00Your skill: " .. skill .. "  →  Max mob level: " .. maxLevel .. "|r")
                    or  "|cffaaaaaa(You don't have Skinning)|r"
                S.rowButtons[i].icon:SetTexture(nil)
                S.rowButtons[i].recipeName:SetText(text)
                S.rowButtons[i].skillText:SetText("")
                S.rowButtons[i].recipe = recipe
                S.rowButtons[i]:Show()
            elseif recipe._skill_band then
                -- Live colour-band row: shows which mob level range maps to this difficulty colour.
                local skill  = getSkinningSkill()
                local ranges = skill > 0 and getSkinningRanges(skill) or nil
                local band   = recipe._skill_band
                local text
                if not ranges then
                    local labels = {
                        red    = "|cffff4040Red (can't skin)|r",
                        orange = "|cffff8000Orange (guaranteed)|r",
                        yellow = "|cffffff00Yellow (likely)|r",
                        green  = "|cff40ff40Green (unlikely)|r",
                        grey   = "|cff808080Grey (no skillup)|r",
                    }
                    text = (labels[band] or "") .. "   —"
                elseif band == "red" then
                    text = "|cffff4040Red (can't skin)|r   Lv " .. (ranges.maxLevel + 1) .. "+"
                elseif band == "orange" then
                    local r = ranges.orange
                    text = "|cffff8000Orange (guaranteed)|r   " .. (r.min <= r.max and "Lv " .. r.min .. "–" .. r.max or "—")
                elseif band == "yellow" then
                    local r = ranges.yellow
                    text = "|cffffff00Yellow (likely)|r   " .. (r.min <= r.max and "Lv " .. r.min .. "–" .. r.max or "—")
                elseif band == "green" then
                    local r = ranges.green
                    text = "|cff40ff40Green (unlikely)|r   " .. (r.min <= r.max and "Lv " .. r.min .. "–" .. r.max or "—")
                elseif band == "grey" then
                    local r = ranges.grey
                    text = "|cff808080Grey (no skillup)|r   " .. (r.max >= 1 and "Lv " .. r.max .. " and below" or "—")
                end
                S.rowButtons[i].icon:SetTexture(nil)
                S.rowButtons[i].recipeName:SetText(text or "")
                S.rowButtons[i].skillText:SetText("")
                S.rowButtons[i].recipe = recipe
                S.rowButtons[i]:Show()
            else
                local iconName = (recipe.creates and recipe.creates.icon) or recipe.recipeItemIcon
                local iconTex  = iconName and ("Interface\\Icons\\" .. iconName)
                if not iconTex then
                    local id = (recipe.creates and recipe.creates.id) or recipe.recipeItemId
                    iconTex = id and select(10, GetItemInfo(id))
                        or profFallbackIcon[S.currentProfName]
                        or "Interface\\Icons\\INV_Misc_QuestionMark"
                end
                S.rowButtons[i].icon:SetTexture(iconTex)
                S.rowButtons[i].recipeName:SetText(ACC.makeSpellLink(recipe))
                local skillDisplay = recipe.skillLabel
                if skillDisplay == nil then
                    local s = recipe.skill
                    skillDisplay = (s and s ~= 0) and s or ""
                end
                S.rowButtons[i].skillText:SetText(skillDisplay)
                S.rowButtons[i].recipe = recipe
                S.rowButtons[i]:Show()
            end
        else
            S.rowButtons[i].icon:SetTexture(nil)
            S.rowButtons[i].recipeName:SetText("")
            S.rowButtons[i].skillText:SetText("")
            S.rowButtons[i].recipe = nil
            S.rowButtons[i]:Hide()
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
            withSeps[#withSeps + 1] = { _separator = true }
        end
        withSeps[#withSeps + 1] = recipe
        lastGroup = g
        lastSub   = s
    end
    return withSeps
end

-- Opens the detail panel for the clicked recipe, anchored below the row button.
function ACC.onRecipeClick(recipe, btn)
    if not recipe then return end
    if recipe._formula    then return end
    if recipe._skill_calc then return end
    if recipe._skill_band then return end
    if recipe._vein       then return end
    if recipe._herb then
        if IsShiftKeyDown() and recipe._herb.item then
            local link = select(2, GetItemInfo(recipe._herb.item))
            if link then ChatEdit_InsertLink(link) end
        end
        return
    end
    if recipe._book then
        if IsShiftKeyDown() and recipe.bookItemId then
            local _, link = GetItemInfo(recipe.bookItemId)
            if link then ChatEdit_InsertLink(link) end
        end
        return
    end
    if recipe._quest then
        if IsShiftKeyDown() then
            local faction = UnitFactionGroup("player")
            local questId = recipe.questId
            for _, q in ipairs(recipe.questGivers) do
                if q.questId then
                    if not q.faction
                       or (faction == "Alliance" and q.faction == "alliance")
                       or (faction == "Horde"    and q.faction == "horde") then
                        questId = q.questId
                        break
                    end
                end
            end
            if questId then
                local level = recipe.questLevel or 60
                -- Classic ERA requires lowercase quest link color; uppercase renders but won't send.
                local questLink = "|cffffff00|Hquest:" .. questId .. ":" .. level .. "|h[" .. (recipe.questName or recipe.name) .. "]|h|r"
                if not ChatEdit_InsertLink(questLink) then
                    DEFAULT_CHAT_FRAME:AddMessage(questLink)
                end
            end
        end
        return
    end
    if recipe._zone then return end
    if recipe._fishingItem then
        if IsShiftKeyDown() and recipe.recipeItemId then
            local _, link = GetItemInfo(recipe.recipeItemId)
            if link then ChatEdit_InsertLink(link) end
        else
            ACC.showRecipeDetail(recipe, btn)
        end
        return
    end
    if recipe._smelt or recipe._train then
        if IsShiftKeyDown() then
            if recipe.spellId then ChatEdit_InsertLink(ACC.makeSpellLink(recipe)) end
        elseif recipe._smelt then
            ACC.showRecipeDetail(recipe, btn)
        end
        return
    end
    if IsShiftKeyDown() then
        ChatEdit_InsertLink(ACC.makeSpellLink(recipe))
        return
    end
    ACC.showRecipeDetail(recipe, btn)
end
