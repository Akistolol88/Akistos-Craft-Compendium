-- Browser.lua — frame construction and profession selection for the recipe browser.
-- Rendering:   BrowserRender.lua   (renderPage, onRecipeClick)
-- Categories:  BrowserCategory.lua (buildCategoryList, renderCategoryPanel, getFilteredList)
-- Tooltips:    BrowserTooltips.lua (showHoverTooltip)
-- Data build:  BrowserSelectProfession.lua (build*List per profession)
-- Static config: BrowserConfig.lua (ACC_BrowserConfig, ACC_BrowserState)

local S = ACC_BrowserState  -- shared mutable state (defined in BrowserConfig.lua)

local rowsPerPage   = 40
local rowsPerColumn = 20

-- Config aliases
local professionDefaultCategory = ACC_BrowserConfig.professionDefaultCategory
local slotCategory              = ACC_BrowserConfig.slotCategory

-- ── Frame construction ────────────────────────────────────────────────────────

local function createMainFrame()
    S.mainFrame = CreateFrame("Frame", "AccMainFrame", UIParent, "BasicFrameTemplate")
    S.mainFrame:SetWidth(800)
    S.mainFrame:SetHeight(540)
    S.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    S.mainFrame:SetMovable(true)
    S.mainFrame:EnableMouse(true)
    S.mainFrame:RegisterForDrag("LeftButton")
    S.mainFrame:SetScript("OnDragStart", S.mainFrame.StartMoving)
    S.mainFrame:SetScript("OnDragStop",  S.mainFrame.StopMovingOrSizing)
    S.mainFrame:SetScript("OnHide", function() ACC.closeAllBrowserWindows() end)
    S.mainFrame:SetScript("OnEvent", function(_, event, arg1)
        if event == "PLAYER_LOGIN" then
            S.mainFrame:UnregisterEvent("PLAYER_LOGIN")
            local last = ACC_CharacterData and ACC_CharacterData.lastProfession
            ACC.selectProfession(last or "Alchemy")
        elseif event == "GET_ITEM_INFO_RECEIVED" then
            -- Resolves slot categories for items that weren't cached when the profession was selected.
            local recipe = S.pendingByItemId[arg1]
            if recipe then
                local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(arg1)
                recipe.resolvedCategory = slotCategory[equipLoc]
                    or professionDefaultCategory[S.currentProfName]
                    or "Misc"
                S.pendingByItemId[arg1] = nil
                ACC.renderCategoryPanel(ACC.buildCategoryList())
                ACC.renderPage()
            end
            if not next(S.pendingByItemId) then
                S.mainFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
            end
        end
    end)
    S.mainFrame:RegisterEvent("PLAYER_LOGIN")
    S.mainFrame:Hide()
end

local function createCategoryPanel()
    S.categoryFrame = CreateFrame("Frame", "AccCategoryPanel", S.mainFrame, "InsetFrameTemplate")
    S.categoryFrame:SetWidth(160)
    S.categoryFrame:SetHeight(425)
    S.categoryFrame:SetPoint("TOPRIGHT", S.mainFrame, "TOPRIGHT", -20, -60)
end

local function createDropdown()
    local dropDownProfessions = CreateFrame("Frame", "AccProfessionDropdown", S.mainFrame, "UIDropDownMenuTemplate")
    dropDownProfessions:SetPoint("TOPLEFT", S.mainFrame, "TOPLEFT", 10, -30)
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
local COL_W  = 280
local COL1_X = 12
local COL2_X = 300

-- Pre-builds all row buttons once at load time; renderPage() updates their content per frame.
local function createRowButtons()
    for i = 1, rowsPerPage do
        local col  = i <= rowsPerColumn and 1 or 2
        local row  = (i - 1) % rowsPerColumn
        local xOff = col == 1 and COL1_X or COL2_X

        local button = CreateFrame("Button", "AccRecipeRow" .. i, S.mainFrame)
        S.rowButtons[i] = button
        button:SetHeight(22)
        button:SetWidth(COL_W)
        button:SetPoint("TOPLEFT", S.mainFrame, "TOPLEFT", xOff, -65 - row * 22)

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

        -- button.recipe is set per-render; closures reference it via the button local, not 'self'.
        button:SetScript("OnClick", function() ACC.onRecipeClick(button.recipe, button) end)
        button:SetScript("OnEnter", function()
            if button.recipe then
                GameTooltip:SetOwner(button, "ANCHOR_NONE")
                GameTooltip:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, 2)
                ACC.showHoverTooltip(button.recipe)
            end
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button:Hide()
    end
end

local function createNavButtons()
    S.prevButton = CreateFrame("Button", "AccPrevButton", S.mainFrame, "UIPanelButtonTemplate")
    S.prevButton:SetWidth(80)
    S.prevButton:SetHeight(22)
    S.prevButton:SetPoint("BOTTOMLEFT", S.mainFrame, "BOTTOMLEFT", 12, 8)
    S.prevButton:SetText("< Prev")
    S.prevButton:SetScript("OnClick", function()
        S.pageIndex = S.pageIndex - 1
        ACC.saveNavState()
        ACC.renderPage()
    end)

    S.nextButton = CreateFrame("Button", "AccNextButton", S.mainFrame, "UIPanelButtonTemplate")
    S.nextButton:SetWidth(80)
    S.nextButton:SetHeight(22)
    S.nextButton:SetPoint("BOTTOMRIGHT", S.mainFrame, "BOTTOMRIGHT", -20, 8)
    S.nextButton:SetText("Next >")
    S.nextButton:SetScript("OnClick", function()
        S.pageIndex = S.pageIndex + 1
        ACC.saveNavState()
        ACC.renderPage()
    end)

    S.pageLabel = S.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    S.pageLabel:SetPoint("BOTTOM", S.mainFrame, "BOTTOM", 0, 13)
    S.pageLabel:SetText("")
end

-- ── Public API ────────────────────────────────────────────────────────────────

function ACC.browserInit()
    createMainFrame()
    createCategoryPanel()
    createDropdown()
    createRowButtons()
    createNavButtons()
    ACC.initRecipeDetail()
end

function ACC.showBrowser()
    S.mainFrame:Show()
end

function ACC.hideBrowser()
    S.mainFrame:Hide()
    ACC.closeAllBrowserWindows()
end

-- Loads a profession into the browser: builds the recipe list, resolves slot categories,
-- derives the category order, and renders the first page.
function ACC.selectProfession(profName)
    S.mainFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
    S.pendingByItemId = {}
    S.currentProfName = profName

    if not ACC_CharacterData then ACC_CharacterData = {} end
    ACC_CharacterData.lastProfession = profName
    local dropdown = _G["AccProfessionDropdown"]
    if dropdown then UIDropDownMenu_SetText(dropdown, profName) end

    S.recipeList = {}
    S.pageIndex  = 1

    if profName == "Mining" then
        ACC.buildMiningList(S.recipeList)
    elseif profName == "Herbalism" then
        ACC.buildHerbalismList(S.recipeList)
    elseif profName == "Skinning" then
        ACC.buildSkinningList(S.recipeList)
    elseif profName == "Fishing" then
        ACC.buildFishingList(S.recipeList)
    else
        ACC.buildGeneralList(S.recipeList, profName, S.pendingByItemId, S.mainFrame)
    end

    -- Pre-warm the item cache so shift-click linking and icon resolution work on first attempt.
    for _, r in ipairs(S.recipeList) do
        if r.recipeItemId then GetItemInfo(r.recipeItemId) end
        if r.bookItemId   then GetItemInfo(r.bookItemId)   end
    end

    table.sort(S.recipeList, function(a, b)
        local sa, sb = a.skill or 0, b.skill or 0
        if sa ~= sb then return sa < sb end
        return (a.name or "") < (b.name or "")
    end)

    local categoryList = ACC.buildCategoryList()
    S.activeCategory = "Misc"
    for _, cat in ipairs(categoryList) do
        if cat ~= "---" then S.activeCategory = cat break end
    end

    local saved = ACC_CharacterData and ACC_CharacterData.lastState and ACC_CharacterData.lastState[profName]
    if saved and saved.category then
        for _, cat in ipairs(categoryList) do
            if cat == saved.category then
                S.activeCategory = saved.category
                S.pageIndex      = saved.page or 1
                break
            end
        end
    end

    ACC.renderCategoryPanel(categoryList)
    ACC.renderPage()
end
