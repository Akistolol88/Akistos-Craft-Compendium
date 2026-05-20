-- Browser.lua — main recipe browser panel.
-- Owns the primary window, profession dropdown, two-column recipe list,
-- category side-panel, and Prev/Next pagination controls.
-- Public API: ACC.browserInit(), ACC.showBrowser(), ACC.hideBrowser(), ACC.selectProfession(),
--             ACC.renderCategoryPanel(), ACC.renderPage(), ACC.getFilteredList(), ACC.onRecipeClick()

-- ── Locals ───────────────────────────────────────────────────────────────────

local mainFrame
local categoryFrame

local recipeList = {}   -- full list for the current profession, excluding header entries
local pageIndex  = 1

local rowsPerPage   = 40
local rowsPerColumn = 20  -- buttons 1–20 are column 1; 21–40 are column 2
local rowButtons    = {}  -- pre-built row buttons reused across pages

local prevButton
local nextButton
local pageLabel

local activeCategory  = nil
local categoryButtons = {}  -- rebuilt each time a profession is selected
local currentProfName    = nil
local pendingByItemId    = {}  -- itemId → recipe; populated when GetItemInfo returns nil on first load
local buildCategoryList      -- forward-declared; defined before selectProfession below


-- ── Config aliases ────────────────────────────────────────────────────────────
-- Tables live in BrowserConfig.lua; local aliases keep all call sites unchanged.
local professionCategoryOrder   = ACC_BrowserConfig.professionCategoryOrder
local subCategoryOrder          = ACC_BrowserConfig.subCategoryOrder
local professionDefaultCategory = ACC_BrowserConfig.professionDefaultCategory
local profFallbackIcon          = ACC_BrowserConfig.profFallbackIcon
local slotCategory              = ACC_BrowserConfig.slotCategory

-- ── Frame construction ────────────────────────────────────────────────────────

local function createMainFrame()
    mainFrame = CreateFrame("Frame", "AccMainFrame", UIParent, "BasicFrameTemplate")
    mainFrame:SetWidth(800)
    mainFrame:SetHeight(540)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    -- Close all sub-windows when the browser is hidden (including via the template's close button)
    mainFrame:SetScript("OnHide", function() ACC.closeAllBrowserWindows() end)
    mainFrame:SetScript("OnEvent", function(_, event, arg1)
        if event == "PLAYER_LOGIN" then
            -- SavedVariables are guaranteed populated by PLAYER_LOGIN; auto-select last profession.
            mainFrame:UnregisterEvent("PLAYER_LOGIN")
            local last = ACC_CharacterData and ACC_CharacterData.lastProfession
            ACC.selectProfession(last or "Alchemy")
        elseif event == "GET_ITEM_INFO_RECEIVED" then
            -- Resolves slot categories for items that weren't in the cache when the profession was selected.
            local recipe = pendingByItemId[arg1]
            if recipe then
                local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(arg1)
                recipe.resolvedCategory = slotCategory[equipLoc]
                    or professionDefaultCategory[currentProfName]
                    or "Misc"
                pendingByItemId[arg1] = nil
                ACC.renderCategoryPanel(buildCategoryList())
                ACC.renderPage()
            end
            if not next(pendingByItemId) then
                mainFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
            end
        end
    end)
    -- On login, auto-select the last-used profession (or Alchemy for first-time characters).
    mainFrame:RegisterEvent("PLAYER_LOGIN")
    mainFrame:Hide()
end

-- Creates the right-side panel that lists filterable categories for the active profession.
local function createCategoryPanel()
    categoryFrame = CreateFrame("Frame", "AccCategoryPanel", mainFrame, "InsetFrameTemplate")
    categoryFrame:SetWidth(160)
    categoryFrame:SetHeight(425)
    categoryFrame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -20, -60)
end

-- Creates the profession selector dropdown in the top-left of the browser.
local function createDropdown()
    local dropDownProfessions = CreateFrame("Frame", "AccProfessionDropdown", mainFrame, "UIDropDownMenuTemplate")
    dropDownProfessions:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -30)
    UIDropDownMenu_Initialize(dropDownProfessions, function()
        for i, group in ipairs(ACC.GetProfessionGroups()) do
            UIDropDownMenu_AddButton({ text = group.title, isTitle = true, notCheckable = true })
            for _, profName in ipairs(group.professions) do
                UIDropDownMenu_AddButton({
                    text = profName,
                    func = function()
                        UIDropDownMenu_SetText(dropDownProfessions, profName)
                        ACC.selectProfession(profName)
                    end,
                    notCheckable = true
                })
            end
            if i < #ACC.GetProfessionGroups() then
                UIDropDownMenu_AddButton({ isSeparator = true, notCheckable = true })
            end
        end
    end)
end

-- Two columns of rowsPerColumn rows each, side by side within the recipe area.
-- Col 1: buttons 1–rowsPerColumn | Col 2: buttons rowsPerColumn+1–rowsPerPage
local COL_W  = 280   -- pixel width of each column
local COL1_X = 12    -- left edge of column 1
local COL2_X = 300   -- left edge of column 2  (COL1_X + COL_W + 8 px gap)

local function createRowButtons()
    for i = 1, rowsPerPage do
        local col  = i <= rowsPerColumn and 1 or 2
        local row  = (i - 1) % rowsPerColumn
        local xOff = col == 1 and COL1_X or COL2_X

        local button = CreateFrame("Button", "AccRecipeRow" .. i, mainFrame)
        rowButtons[i] = button
        button:SetHeight(22)
        button:SetWidth(COL_W)
        button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", xOff, -65 - row * 22)

        -- Layout: [skill req] [6px gap] [icon 16px] [6px gap] [name …]
        -- Skill at x=0, icon at x=28, name at x=50. Fixed positions avoid all overlap.
        local skillText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        skillText:SetPoint("LEFT", button, "LEFT", 0, 0)
        button.skillText = skillText

        local icon = button:CreateTexture(nil, "OVERLAY")
        icon:SetWidth(16)
        icon:SetHeight(16)
        icon:SetPoint("LEFT", button, "LEFT", 28, 0)
        button.icon = icon

        local recipeName = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        recipeName:SetPoint("LEFT",  button, "LEFT",  50, 0)
        recipeName:SetPoint("RIGHT", button, "RIGHT",  0, 0)
        recipeName:SetJustifyH("LEFT")
        button.recipeName = recipeName

        -- button.recipe is set per-render; closures reference it via the button local, not 'this'
        button:SetScript("OnClick", function() ACC.onRecipeClick(button.recipe, button) end)
        button:SetScript("OnEnter", function()
            if button.recipe then
                GameTooltip:SetOwner(button, "ANCHOR_NONE")
                GameTooltip:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, 2)
                if button.recipe._vein or button.recipe._herb then
                    ACC.showGatheringTooltip(button.recipe)
                elseif button.recipe._smelt then
                    GameTooltip:SetHyperlink(ACC.makeSpellLink(button.recipe))
                    local c = button.recipe.colors
                    if c then
                        GameTooltip:AddLine(
                            "|cffff8000" .. (c[1] or "?") .. "|r  " ..
                            "|cffffff00" .. (c[2] or "?") .. "|r  " ..
                            "|cff40ff40" .. (c[3] or "?") .. "|r  " ..
                            "|cff808080" .. (c[4] or "?") .. "|r",
                            1, 1, 1
                        )
                    end
                    local smelt = button.recipe._smelt
                    if smelt.creates then
                        GameTooltip:AddLine("Creates: " .. smelt.creates.name .. " x" .. smelt.creates.count, 0.9, 0.9, 0.9)
                    end
                    if smelt.reagents and #smelt.reagents > 0 then
                        GameTooltip:AddLine("Requires:", 1, 1, 0)
                        for _, r in ipairs(smelt.reagents) do
                            GameTooltip:AddLine("  " .. r.name .. " x" .. r.count, 1, 1, 1)
                        end
                    end
                    if smelt.tribute and #smelt.tribute > 0 then
                        GameTooltip:AddLine("Tribute:", 1, 1, 0)
                        for _, t in ipairs(smelt.tribute) do
                            GameTooltip:AddLine("  " .. t.name .. " x" .. t.count, 1, 1, 1)
                        end
                    end
                    if smelt.quest and smelt.questId then
                        local level = smelt.questLevel or 60
                        -- Classic ERA requires lowercase quest link color; uppercase renders but won't send.
                        local questLink = "|cffffff00|Hquest:" .. smelt.questId .. ":" .. level .. "|h[" .. smelt.quest .. "]|h|r"
                        GameTooltip:AddLine("Quest: " .. questLink, 1, 1, 1)
                    end
                    if smelt.note then
                        GameTooltip:AddLine(" ", 1, 1, 1)
                        GameTooltip:AddLine(smelt.note, 0.8, 0.8, 0.8, true)
                    end
                    GameTooltip:Show()
                elseif button.recipe._book then
                    local r = button.recipe
                    local bookLabel = r.bookName
                    if r.bookItemId then
                        local _, link = GetItemInfo(r.bookItemId)
                        if link then bookLabel = link end
                    end
                    GameTooltip:SetText(r.name, 1, 0.82, 0)
                    GameTooltip:AddLine("Requires: " .. bookLabel, 1, 1, 1)
                    if #r.vendors > 0 then
                        GameTooltip:AddLine("Sold by:", 1, 1, 0)
                        for _, v in ipairs(r.vendors) do
                            local vr, vg, vb = 1, 1, 1
                            if     v.faction == "alliance" then vr, vg, vb = 0.41, 0.80, 0.94
                            elseif v.faction == "horde"    then vr, vg, vb = 0.94, 0.41, 0.41 end
                            GameTooltip:AddLine("  " .. v.name .. "  —  " .. (v.zone or ""), vr, vg, vb)
                        end
                    end
                    GameTooltip:AddLine("Shift-click to link in chat", 0, 1, 0)
                    GameTooltip:Show()
                elseif button.recipe._quest then
                    local r = button.recipe
                    GameTooltip:SetText(r.name, 1, 0.82, 0)
                    if #r.questGivers > 0 then
                        GameTooltip:AddLine("Quest giver:", 1, 1, 0)
                        for _, q in ipairs(r.questGivers) do
                            local qr, qg, qb = 1, 1, 1
                            if     q.faction == "alliance" then qr, qg, qb = 0.41, 0.80, 0.94
                            elseif q.faction == "horde"    then qr, qg, qb = 0.94, 0.41, 0.41 end
                            local qId = q.questId or r.questId
                            local level = r.questLevel or 60
                            local suffix = qId and ("  |cffffff00|Hquest:" .. qId .. ":" .. level .. "|h[" .. (r.questName or "Quest") .. "]|h|r") or ""
                            GameTooltip:AddLine("  " .. q.name .. "  —  " .. (q.zone or "") .. suffix, qr, qg, qb)
                        end
                    else
                        local qLabel = r.questName or "Quest"
                        if r.questId then
                            local level = r.questLevel or 60
                            qLabel = "|cffffff00|Hquest:" .. r.questId .. ":" .. level .. "|h[" .. qLabel .. "]|h|r"
                        end
                        GameTooltip:AddLine("Learned from: " .. qLabel, 1, 1, 1)
                    end
                    GameTooltip:AddLine("Shift-click to show quest link in chat", 0, 1, 0)
                    GameTooltip:Show()
                else
                    GameTooltip:SetHyperlink(ACC.makeSpellLink(button.recipe))
                    local reagents = button.recipe.reagents or {}
                    if #reagents > 0 then
                        GameTooltip:AddLine("Materials:", 1, 1, 0)
                        for _, r in ipairs(reagents) do
                            local name = GetItemInfo(r.id) or ("|cffffff00[" .. r.id .. "]|r")
                            GameTooltip:AddLine("  " .. name .. " x" .. r.count, 1, 1, 1)
                        end
                    end
                    local trainers = button.recipe._train and button.recipe.trainers
                    if trainers and #trainers > 0 then
                        GameTooltip:AddLine("Trainers:", 1, 1, 0)
                        for _, t in ipairs(trainers) do
                            local r, g, b = 1, 1, 1
                            if     t.faction == "alliance" then r, g, b = 0.41, 0.80, 0.94
                            elseif t.faction == "horde"    then r, g, b = 0.94, 0.41, 0.41 end
                            GameTooltip:AddLine("  " .. t.name .. "  —  " .. (t.zone or ""), r, g, b)
                        end
                    end
                    -- Loop all sources and display each type.
                    local dropCreatures  = {}
                    local containerItems = {}
                    local miscLines      = {}
                    for _, src in ipairs(button.recipe.sources or {}) do
                        if src.type == "vendor" and src.vendors then
                            GameTooltip:AddLine("Sold by:", 1, 1, 0)
                            if src.reputation then
                                GameTooltip:AddLine("  |cffffff00" .. src.reputation.faction .. " — " .. src.reputation.level .. " required|r", 1, 1, 1)
                            end
                            for _, v in ipairs(src.vendors) do
                                local vr, vg, vb = 1, 1, 1
                                if     v.faction == "alliance" then vr, vg, vb = 0.41, 0.80, 0.94
                                elseif v.faction == "horde"    then vr, vg, vb = 0.94, 0.41, 0.41 end
                                GameTooltip:AddLine("  " .. v.name .. "  —  " .. (v.zone or ""), vr, vg, vb)
                            end
                        elseif src.type == "trainer" and src.trainers then
                            GameTooltip:AddLine("Taught by trainer:", 1, 1, 0)
                            for _, t in ipairs(src.trainers) do
                                local vr, vg, vb = 1, 1, 1
                                if     t.faction == "alliance" then vr, vg, vb = 0.41, 0.80, 0.94
                                elseif t.faction == "horde"    then vr, vg, vb = 0.94, 0.41, 0.41 end
                                GameTooltip:AddLine("  " .. t.name .. "  —  " .. (t.zone or ""), vr, vg, vb)
                            end
                        elseif src.type == "npc" and src.npcs then
                            GameTooltip:AddLine("Taught by:", 1, 1, 0)
                            for _, n in ipairs(src.npcs) do
                                GameTooltip:AddLine("  " .. n.name .. "  —  " .. (n.zone or ""), 1, 1, 1)
                            end
                        elseif src.type == "drop" and src.creatures then
                            for _, c in ipairs(src.creatures) do dropCreatures[#dropCreatures + 1] = c end
                        elseif (src.type == "chest" or src.type == "lockbox" or src.type == "other" or src.type == "decoded") and src.containers then
                            for _, c in ipairs(src.containers) do containerItems[#containerItems + 1] = c end
                        elseif src.type == "world_drop" then
                            local line = "World drop"
                            if src.level_range then
                                line = line .. "  (level " .. src.level_range[1] .. "–" .. src.level_range[2] .. ")"
                            end
                            miscLines[#miscLines + 1] = line
                        elseif src.type == "holiday" then
                            miscLines[#miscLines + 1] = "Holiday: " .. (src.event or "")
                        elseif src.type == "object" then
                            miscLines[#miscLines + 1] = "Clickable object" .. (src.zone and ("  —  " .. src.zone) or "")
                        elseif src.type == "quest" and src.quests then
                            for _, q in ipairs(src.quests) do
                                local line = "Quest reward: " .. q.name
                                if q.faction then line = line .. "  |cffaaaaaa(" .. q.faction .. ")|r" end
                                miscLines[#miscLines + 1] = line
                            end
                        end
                    end
                    -- Creature drops sorted by rate, capped at 8
                    table.sort(dropCreatures, function(a, b) return (a.rate or 0) > (b.rate or 0) end)
                    if #dropCreatures > 0 then
                        GameTooltip:AddLine("Drops from:", 1, 1, 0)
                        for _, c in ipairs(dropCreatures) do
                            if i > 8 then break end
                            local line = "  " .. c.name
                            if c.zone then
                                -- World boss creatures carry multiple spawn zones as an array rather than a string.
                                local z = type(c.zone) == "table" and table.concat(c.zone, ", ") or c.zone
                                line = line .. "  —  " .. z
                            end
                            if c.rate then line = line .. " (" .. string.format("%.2f", c.rate) .. "%)" end
                            GameTooltip:AddLine(line, 1, 1, 1)
                        end
                    end
                    -- Container sources (chests, lockboxes, bags, decoded items) sorted by rate, capped at 8
                    table.sort(containerItems, function(a, b) return (a.rate or 0) > (b.rate or 0) end)
                    if #containerItems > 0 then
                        GameTooltip:AddLine("Found in:", 1, 1, 0)
                        for _, c in ipairs(containerItems) do
                            if i > 8 then break end
                            local line = "  " .. c.name
                            if c.rate then line = line .. " (" .. string.format("%.2f", c.rate) .. "%)" end
                            GameTooltip:AddLine(line, 1, 1, 1)
                        end
                    end
                    -- Misc: world drop, holiday, clickable object, quest reward
                    for _, line in ipairs(miscLines) do
                        GameTooltip:AddLine(line, 1, 0.82, 0)
                    end
                    GameTooltip:Show()
                end
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
        ACC.renderPage()
    end)

    nextButton = CreateFrame("Button", "AccNextButton", mainFrame, "UIPanelButtonTemplate")
    nextButton:SetWidth(80)
    nextButton:SetHeight(22)
    nextButton:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -20, 8)
    nextButton:SetText("Next >")
    nextButton:SetScript("OnClick", function()
        pageIndex = pageIndex + 1
        ACC.renderPage()
    end)

    pageLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pageLabel:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 13)
    pageLabel:SetText("")
end

-- Derives the ordered category list from the current recipeList + currentProfName.
-- Extracted so both selectProfession and the GET_ITEM_INFO_RECEIVED handler can call it.
buildCategoryList = function()
    -- If this profession has a fixed display order, use it filtered to present categories only.
    local fixedOrder = professionCategoryOrder[currentProfName]
    if fixedOrder then
        local present = {}
        for _, recipe in ipairs(recipeList) do
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
    for _, recipe in ipairs(recipeList) do
        if recipe.resolvedCategory and not seen[recipe.resolvedCategory] then
            seen[recipe.resolvedCategory] = true
            slotSet[recipe.resolvedCategory] = true
        end
        if recipe.category and not seen[recipe.category] then
            seen[recipe.category] = true
            -- Manual categories that match a known slot name join the slot-ordered section
            -- so e.g. category = "Cloak" appears with other armor slots, not at the bottom.
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

-- ── Public API ────────────────────────────────────────────────────────────────

-- Entry point called from Core.lua on addon load; constructs all browser frames.
function ACC.browserInit()
    createMainFrame()
    createCategoryPanel()
    createDropdown()
    createRowButtons()
    createNavButtons()
    ACC.initRecipeDetail()
end

-- Shows the main browser window.
function ACC.showBrowser()
    mainFrame:Show()
end

-- Hides the browser and all child windows (detail panel, etc.).
function ACC.hideBrowser()
    mainFrame:Hide()
    ACC.closeAllBrowserWindows()
end

-- Loads a profession into the browser: filters recipes, resolves slot categories,
-- builds the ordered category list, and renders the first page.
function ACC.selectProfession(profName)
    -- Cancel any pending resolution from a previous profession selection.
    mainFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
    pendingByItemId = {}
    currentProfName = profName

    -- Persist the choice so the next login auto-selects this profession.
    if not ACC_CharacterData then ACC_CharacterData = {} end
    ACC_CharacterData.lastProfession = profName
    -- Keep the dropdown label in sync when the profession is set programmatically (e.g. on login).
    local dropdown = _G["AccProfessionDropdown"]
    if dropdown then UIDropDownMenu_SetText(dropdown, profName) end

    recipeList = {}
    pageIndex  = 1

    if profName == "Mining" then
        for _, vein in ipairs(ACC_Data.Mining or {}) do
            recipeList[#recipeList + 1] = {
                name          = vein.name,
                skill         = vein.colors[1],
                colors        = vein.colors,
                category      = "Veins",
                recipeItemIcon = vein.icon,
                _vein         = vein,
            }
        end
        for _, smelt in ipairs(ACC_Data.MiningSmelt or {}) do
            recipeList[#recipeList + 1] = {
                name           = smelt.name,
                spellId        = smelt.spellId,
                skill          = smelt.skill,
                colors         = smelt.colors,
                category       = "Smelting",
                creates        = smelt.creates,
                recipeItemIcon = smelt.creates and smelt.creates.icon,
                _smelt         = smelt,
            }
        end
        for _, train in ipairs(ACC_Data.MiningTraining or {}) do
            recipeList[#recipeList + 1] = {
                name         = train.name,
                spellId      = train.spellId,
                skill        = train.skill,
                category     = "Misc",
                displayGroup = 100,
                _train       = true,
                trainers     = train.trainers or {},
            }
        end
    elseif profName == "Herbalism" then
        for _, herb in ipairs(ACC_Data.Herbalism or {}) do
            recipeList[#recipeList + 1] = {
                name           = herb.name,
                skill          = herb.colors[1],
                colors         = herb.colors,
                category       = "Herbs",
                recipeItemId   = herb.item,
                recipeItemIcon = herb.icon,
                _herb          = herb,
            }
        end
        for _, train in ipairs(ACC_Data.HerbalismTraining or {}) do
            recipeList[#recipeList + 1] = {
                name         = train.name,
                spellId      = train.spellId,
                skill        = train.skill,
                category     = "Misc",
                displayGroup = 100,
                _train       = true,
                trainers     = train.trainers or {},
            }
        end
    else
        local recipeData = ACC_Data[profName] or {}
        for _, recipe in ipairs(recipeData) do
            if recipe.skill ~= 9999 then
                if recipe._book then
                    recipeList[#recipeList + 1] = {
                        name         = recipe.name,
                        skill        = recipe.skill,
                        category     = "Misc",
                        displayGroup = 100,
                        _book        = true,
                        bookName     = recipe.bookName,
                        bookItemId   = recipe.bookItemId,
                        vendors      = recipe.vendors or {},
                    }
                elseif recipe._quest then
                    recipeList[#recipeList + 1] = {
                        name        = recipe.name,
                        skill       = recipe.skill,
                        category    = "Misc",
                        displayGroup = 100,
                        _quest      = true,
                        questName   = recipe.questName,
                        questId     = recipe.questId,
                        questLevel  = recipe.questLevel,
                        questGivers = recipe.questGivers or {},
                    }
                elseif recipe.creates == nil and (not recipe.reagents or #recipe.reagents == 0) then
                    -- rank-up training entry (Journeyman/Expert/Artisan) — wrap with Misc category
                    local src = recipe.sources and recipe.sources[1]
                    recipeList[#recipeList + 1] = {
                        name         = recipe.name,
                        spellId      = recipe.spellId,
                        skill        = recipe.skill,
                        category     = "Misc",
                        displayGroup = 100,
                        _train       = true,
                        trainers     = (src and src.trainers) or {},
                    }
                else
                    recipeList[#recipeList + 1] = recipe
                end
            end
        end

        local isGear = profName == "Tailoring" or profName == "Leatherworking"
                   or profName == "Blacksmithing" or profName == "Engineering"

        -- Resolve slot categories via GetItemInfo.  When an item is not yet in the client
        -- cache, GetItemInfo returns nil for ALL return values — including the item name.
        -- We use the name as a "is cached?" signal: nil name means pending, not truly Misc.
        local defaultCat = professionDefaultCategory[profName]
        for _, recipe in ipairs(recipeList) do
            recipe.resolvedCategory = nil
            if recipe.creates then
                local itemName, _, _, _, _, _, _, _, equipLoc = GetItemInfo(recipe.creates.id)
                if itemName then
                    -- Only derive a slot category when no manual category is set.
                    if not recipe.category then
                        recipe.resolvedCategory = slotCategory[equipLoc]
                            or defaultCat
                            or (isGear and "Misc" or nil)
                    end
                elseif not recipe.category and (isGear or defaultCat) then
                    -- Item not cached yet and no manual category; hold and track for later.
                    recipe.resolvedCategory = defaultCat or "Misc"
                    pendingByItemId[recipe.creates.id] = recipe
                end
            elseif not recipe.category and defaultCat then
                -- Recipe creates nothing (e.g. Basic Campfire) — assign the profession default.
                recipe.resolvedCategory = defaultCat
            end
        end

        -- If any items were uncached, listen for GET_ITEM_INFO_RECEIVED so the OnEvent
        -- handler (set up in createMainFrame) can promote them out of "Misc" when they arrive.
        if next(pendingByItemId) then
            mainFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    end

    table.sort(recipeList, function(a, b)
        local sa, sb = a.skill or 0, b.skill or 0
        if sa ~= sb then return sa < sb end
        return (a.name or "") < (b.name or "")
    end)

    local categoryList = buildCategoryList()
    -- Default to the first real category so something is always visible on load.
    activeCategory = "Misc"
    for _, cat in ipairs(categoryList) do
        if cat ~= "---" then activeCategory = cat break end
    end
    ACC.renderCategoryPanel(categoryList)
    ACC.renderPage()
end

-- Rebuilds the category panel buttons from the given list.
-- "---" entries are rendered as blank spacing rather than buttons.
function ACC.renderCategoryPanel(categoryList)
    for _, catButton in ipairs(categoryButtons) do
        catButton:Hide()
    end
    categoryButtons = {}
    local yOffset = 8
    for _, category in ipairs(categoryList) do
        if category == "---" then
            yOffset = yOffset + 25
        else
            local button = CreateFrame("Button", nil, categoryFrame)
            button:SetPoint("TOPLEFT", categoryFrame, "TOPLEFT", 8, -yOffset)
            button:SetHeight(20)
            button:SetWidth(148)
            button:SetScript("OnClick", function()
                ACC.closeAllBrowserWindows()
                activeCategory = category
                pageIndex = 1
                ACC.renderPage()
            end)
            local label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", button, "LEFT", 0, 0)
            label:SetText(category)
            categoryButtons[#categoryButtons + 1] = button
            yOffset = yOffset + 20
        end
    end
end

-- Renders the current page of the active category into the row buttons.
function ACC.renderPage()
    local filteredList = ACC.getFilteredList()
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
            if recipe._separator then
                rowButtons[i].icon:SetTexture(nil)
                rowButtons[i].recipeName:SetText("")
                rowButtons[i].skillText:SetText("")
                rowButtons[i].recipe = nil
                rowButtons[i]:Show()
            else
                local iconName = (recipe.creates and recipe.creates.icon) or recipe.recipeItemIcon
                local iconTex  = iconName and ("Interface\\Icons\\" .. iconName)
                if not iconTex then
                    local id = (recipe.creates and recipe.creates.id) or recipe.recipeItemId
                    iconTex = id and select(10, GetItemInfo(id))
                        or profFallbackIcon[currentProfName]
                        or "Interface\\Icons\\INV_Misc_QuestionMark"
                end
                rowButtons[i].icon:SetTexture(iconTex)
                rowButtons[i].recipeName:SetText(ACC.makeSpellLink(recipe))
                rowButtons[i].skillText:SetText(recipe.skill or "")
                rowButtons[i].recipe = recipe
                rowButtons[i]:Show()
            end
        else
            rowButtons[i].icon:SetTexture(nil)
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
function ACC.getFilteredList()
    local result = {}
    for _, recipe in ipairs(recipeList) do
        if recipe.category == activeCategory or recipe.resolvedCategory == activeCategory then
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
    -- Insert a blank separator between subCategory or displayGroup changes.
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
    if recipe._vein then return end
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
    if recipe._smelt or recipe._train then
        if IsShiftKeyDown() then
            if recipe.spellId then
                ChatEdit_InsertLink(ACC.makeSpellLink(recipe))
            end
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
