-- File-level locals are shared across all functions in this file.
-- They hold the browser's persistent state between function calls.
local mainFrame

local recipeList = {}   -- filtered recipe list for the selected profession
local pageIndex = 1     -- which page is currently displayed

local rowsPerPage = 20
local rowButtons = {}   -- holds the 20 row Button frames so renderPage can update them

local prevButton        -- declared here so renderPage can enable/disable them later
local nextButton
local pageLabel

function browserInit()
    mainFrame = CreateFrame("Frame", "AccMainFrame", UIParent, "BasicFrameTemplate")
    mainFrame:SetWidth(600)
    mainFrame:SetHeight(400)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:Hide()

    local dropDownProffessions = CreateFrame("Frame", "AccProfessionDropdown", mainFrame, "UIDropDownMenuTemplate")
    dropDownProffessions:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -30)

    -- UIDropDownMenu_Initialize runs this function each time the dropdown opens.
    -- profName is captured by each button's closure, so each button remembers its own profession.
    UIDropDownMenu_Initialize(dropDownProffessions, function()
        for i, group in ipairs(GetProfessionGroups()) do
            UIDropDownMenu_AddButton({ text = group.title, isTitle = true, notCheckable = true })
            for j, profName in ipairs(group.professions) do
                UIDropDownMenu_AddButton({ text = profName,
                func = function() UIDropDownMenu_SetText(dropDownProffessions, profName)
                    selectProfession(profName)
                end,
                notCheckable = true })
            end
            if i < #GetProfessionGroups() then
                UIDropDownMenu_AddButton({ isSeparator = true, notCheckable = true })
            end
        end
    end)

    -- Two SetPoint calls (TOPLEFT + TOPRIGHT) stretch the button edge-to-edge
    -- without hardcoding a pixel width. The -65 Y offset clears the dropdown above.
    -- WoW requires every named frame to have a globally unique name, hence "AccRecipeRow" .. i.
    for i = 1, rowsPerPage do
        local button = CreateFrame("Button", "AccRecipeRow" .. i, mainFrame)
        rowButtons[i] = button
        button:SetHeight(16)
        button:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -65 - (i - 1) * 16)
        button:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -12, -65 - (i - 1) * 16)

        local recipeName = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        recipeName:SetPoint("LEFT", button, "LEFT", 4, 0)
        button.recipeName = recipeName

        local skillText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        skillText:SetPoint("RIGHT", button, "RIGHT", -4, 0)
        button.skillText = skillText

        -- Hidden by default; renderPage shows only the rows that have a recipe.
        button:Hide()
    end

    prevButton = CreateFrame("Button", "AccPrevButton", mainFrame, "UIPanelButtonTemplate")
    prevButton:SetWidth(80)
    prevButton:SetHeight(22)
    prevButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 12, 8)
    prevButton:SetText("< Prev")

    nextButton = CreateFrame("Button", "AccNextButton", mainFrame, "UIPanelButtonTemplate")
    nextButton:SetWidth(80)
    nextButton:SetHeight(22)
    nextButton:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -12, 8)
    nextButton:SetText("Next >")

    pageLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pageLabel:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 13)
    pageLabel:SetText("")
end

function showBrowser()
    mainFrame:Show()
end

function selectProfession(profName)
    local recipeData = ACC_Data[profName] or {}
    recipeList = {}
    for _, recipe in ipairs(recipeData) do
        -- skill 9999 is the "learn profession" trainer spell, not a craftable recipe.
        if not (recipe.skill and recipe.skill == 9999) then
            recipeList[#recipeList + 1] = recipe
        end
    end
    pageIndex = 1
    renderPage()
end

function renderPage()
    -- math.ceil ensures a partial last page still counts as a full page.
    local totalPages = math.max(1, math.ceil(#recipeList / rowsPerPage))

    -- startIndex jumps to the correct slice of recipeList for the current page.
    local startIndex = (pageIndex - 1) * rowsPerPage + 1

    for i = 1, rowsPerPage do
        local recipe = recipeList[startIndex + i - 1]
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
