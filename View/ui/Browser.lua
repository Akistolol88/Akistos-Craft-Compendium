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


-- Fixed category display order for specific professions.
-- Only categories that actually have at least one recipe are shown.
local professionCategoryOrder = {
    Engineering = {
        "Helm", "Armor", "Trinket", "Guns",
        "---",
        "Door Explosive", "Dummies", "Explosives",
        "---",
        "Bullets", "Scopes",
        "---",
        "Parts", "Fireworks", "Pets", "Misc",
    },
    Enchanting = {
        "Chest", "Cloak", "Gloves", "Boots", "Bracer",
        "Weapon", "2H Weapon", "Shield",
        "---",
        "Oils", "Wands", "Rods", "Misc",
    },
    Alchemy = {
        "Flasks",
        "Offensive Elixirs", "Defensive Elixirs",
        "Healing/Mana Potions", "Protection Potions",
        "Utility Elixirs",
        "Transmute",
        "---",
        "Oils", "Misc",
    },
    Leatherworking = {
        "Helm", "Shoulders", "Cloak", "Chest", "Gloves", "Belt", "Legs", "Boots", "Bracers",
        "---",
        "Quivers & Pouches", "Armorkits", "Skins", "Misc",
        "---",
        "Fire Resistance", "Nature Resistance", "Frost Resistance",
    },
    Blacksmithing = {
        "Helm", "Shoulders", "Chest", "Gloves", "Belt", "Legs", "Boots", "Bracers",
        "Shield",
        "One-Hand",
        "Mainhand",
        "Two-Hand",
        "Rods",
        "Enhancements",
        "Sharpening Stones",
        "Keys",
        "Misc",
        "Fire Resistance", "Shadow Resistance", "Frost Resistance", "Nature Resistance",
    },
    Mining = {
        "Veins",
        "---",
        "Smelting",
        "---",
        "Misc",
    },
    Herbalism = {
        "Herbs",
        "---",
        "Misc",
    },
    ["First Aid"] = {
        "Bandages",
        "---",
        "Misc",
    },
    Cooking = {
        "Food",
        "---",
        "Misc",
    },
}

-- Sort order for subCategory within a category (lower = first).
-- Items without a subCategory sort last (order 99).
local subCategoryOrder = {
    -- Weapon types
    Swords              = 1,
    Maces               = 2,
    Axes                = 3,
    Daggers             = 4,
    Polearms            = 5,
    -- Stone types
    ["Sharpening Stones"] = 1,
    Weightstones          = 2,
    ["Grinding Stones"]   = 3,
    -- Enhancement types
    ["Shield Spikes"]     = 1,
}

-- Default category assigned when a profession's crafted items have no equipment slot
-- (e.g. First Aid bandages return INVTYPE_NON_EQUIP / "").
local professionDefaultCategory = {
    ["Cooking"]   = "Food",
    ["First Aid"] = "Bandages",
}

-- Fallback icon used when a recipe has no formula item and creates nothing with an icon.
-- Enchanting enchants are the main case: they apply directly to gear with no scroll icon.
local profFallbackIcon = {
    Enchanting = "Interface\\Icons\\trade_engraving",
    Mining     = "Interface\\Icons\\trade_mining",
    Herbalism  = "Interface\\Icons\\trade_herbalism",
}

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
    if not recipe.spellId then
        return "|cffffd700[" .. (recipe.name or "???") .. "]|r"
    end
    return "|cff71d5ff|Hspell:" .. recipe.spellId .. "|h[" .. recipe.name .. "]|h|r"
end

-- Populates an already-owned GameTooltip with gathering node info (vein, herb, or smelt).
local function showGatheringTooltip(recipe)
    local vein  = recipe._vein
    local herb  = recipe._herb
    local smelt = recipe._smelt
    local c     = recipe.colors

    local function addColorLine()
        if not c then return end
        GameTooltip:AddLine(
            "|cffff8000" .. (c[1] or "?") .. "|r  " ..
            "|cffffff00" .. (c[2] or "?") .. "|r  " ..
            "|cff40ff40" .. (c[3] or "?") .. "|r  " ..
            "|cff808080" .. (c[4] or "?") .. "|r",
            1, 1, 1
        )
    end

    if vein then
        GameTooltip:SetText(vein.name, 1, 1, 1)
        addColorLine()
        if vein.note then GameTooltip:AddLine(vein.note, 1, 0.82, 0, true) end
        GameTooltip:AddLine("Taps per node: " .. (vein.taps or "2-4"), 0.9, 0.9, 0.9)
        if vein.ore and #vein.ore > 0 then
            GameTooltip:AddLine("Drops:", 1, 1, 0)
            for _, drop in ipairs(vein.ore) do
                GameTooltip:AddLine("  " .. drop.name, 1, 1, 1)
            end
        end
        if vein.gems and #vein.gems > 0 then
            GameTooltip:AddLine("Possible Gems:", 1, 1, 0)
            for _, gem in ipairs(vein.gems) do
                GameTooltip:AddLine("  " .. gem.name .. " (" .. gem.rate .. "%)", 0.8, 0.8, 0.8)
            end
        end
        if vein.zones and #vein.zones > 0 then
            GameTooltip:AddLine("Found in:", 1, 1, 0)
            GameTooltip:AddLine(table.concat(vein.zones, ", "), 0.7, 0.7, 0.7, true)
        end
    elseif herb then
        GameTooltip:SetText(herb.name, 1, 1, 1)
        addColorLine()
        if herb.terrain then GameTooltip:AddLine(herb.terrain, 0.9, 0.9, 0.9, true) end
        if herb.note    then GameTooltip:AddLine(herb.note,    1,   0.82, 0,   true) end
        if herb.zones and #herb.zones > 0 then
            GameTooltip:AddLine("Found in:", 1, 1, 0)
            GameTooltip:AddLine(table.concat(herb.zones, ", "), 0.7, 0.7, 0.7, true)
        end
    elseif smelt then
        GameTooltip:SetText(smelt.name, 1, 1, 1)
        addColorLine()
        if smelt.creates then
            GameTooltip:AddLine("Creates: " .. smelt.creates.name .. " x" .. smelt.creates.count, 0.9, 0.9, 0.9)
        end
        if smelt.reagents and #smelt.reagents > 0 then
            GameTooltip:AddLine("Requires:", 1, 1, 0)
            for _, r in ipairs(smelt.reagents) do
                GameTooltip:AddLine("  " .. r.name .. " x" .. r.count, 1, 1, 1)
            end
        end
    end
    GameTooltip:Show()
end

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
    mainFrame:SetScript("OnHide", function() closeAllBrowserWindows() end)
    mainFrame:SetScript("OnEvent", function(_, event, arg1)
        if event == "PLAYER_LOGIN" then
            -- SavedVariables are guaranteed populated by PLAYER_LOGIN; auto-select last profession.
            mainFrame:UnregisterEvent("PLAYER_LOGIN")
            local last = ACC_CharacterData and ACC_CharacterData.lastProfession
            selectProfession(last or "Alchemy")
        elseif event == "GET_ITEM_INFO_RECEIVED" then
            -- Resolves slot categories for items that weren't in the cache when the profession was selected.
            local recipe = pendingByItemId[arg1]
            if recipe then
                local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(arg1)
                recipe.resolvedCategory = slotCategory[equipLoc]
                    or professionDefaultCategory[currentProfName]
                    or "Misc"
                pendingByItemId[arg1] = nil
                renderCategoryPanel(buildCategoryList())
                renderPage()
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
        button:SetScript("OnClick", function() onRecipeClick(button.recipe, button) end)
        button:SetScript("OnEnter", function()
            if button.recipe then
                GameTooltip:SetOwner(button, "ANCHOR_NONE")
                GameTooltip:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, 2)
                if button.recipe._vein or button.recipe._herb then
                    showGatheringTooltip(button.recipe)
                elseif button.recipe._smelt then
                    GameTooltip:SetHyperlink(makeSpellLink(button.recipe))
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
                    GameTooltip:Show()
                else
                    GameTooltip:SetHyperlink(makeSpellLink(button.recipe))
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
                recipeItemId   = smelt.creates and smelt.creates.id,
                recipeItemIcon = smelt.creates and smelt.creates.icon,
                _smelt         = smelt,
            }
        end
        for _, train in ipairs(ACC_Data.MiningTraining or {}) do
            recipeList[#recipeList + 1] = {
                name     = train.name,
                spellId  = train.spellId,
                skill    = train.skill,
                category = "Misc",
                _train   = true,
                trainers = train.trainers or {},
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
                name     = train.name,
                spellId  = train.spellId,
                skill    = train.skill,
                category = "Misc",
                _train   = true,
                trainers = train.trainers or {},
            }
        end
    else
        local recipeData = ACC_Data[profName] or {}
        for _, recipe in ipairs(recipeData) do
            if recipe.skill == 9999 then
                -- skip the "Learn Profession" entry
            elseif recipe.creates == nil and (not recipe.reagents or #recipe.reagents == 0) then
                -- rank-up training entry (Journeyman/Expert/Artisan) — wrap with Misc category
                local src = recipe.sources and recipe.sources[1]
                recipeList[#recipeList + 1] = {
                    name     = recipe.name,
                    spellId  = recipe.spellId,
                    skill    = recipe.skill,
                    category = "Misc",
                    _train   = true,
                    trainers = (src and src.trainers) or {},
                }
            else
                recipeList[#recipeList + 1] = recipe
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
            yOffset = yOffset + 25
        else
            local button = CreateFrame("Button", nil, categoryFrame)
            button:SetPoint("TOPLEFT", categoryFrame, "TOPLEFT", 8, -yOffset)
            button:SetHeight(20)
            button:SetWidth(148)
            button:SetScript("OnClick", function()
                closeAllBrowserWindows()
                activeCategory = category
                pageIndex = 1
                renderPage()
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
                rowButtons[i].recipeName:SetText(makeSpellLink(recipe))
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
function getFilteredList()
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
function onRecipeClick(recipe, btn)
    if not recipe then return end
    if recipe._vein then return end
    if recipe._herb then
        if IsShiftKeyDown() and recipe._herb.item then
            local link = select(2, GetItemInfo(recipe._herb.item))
            if link then ChatEdit_InsertLink(link) end
        end
        return
    end
    if recipe._smelt or recipe._train then
        if IsShiftKeyDown() and recipe.spellId then
            ChatEdit_InsertLink(makeSpellLink(recipe))
        end
        return
    end
    if IsShiftKeyDown() then
        ChatEdit_InsertLink(makeSpellLink(recipe))
        return
    end
    showRecipeDetail(recipe, btn)
end
