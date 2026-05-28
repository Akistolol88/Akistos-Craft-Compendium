-- RecipeDetailFrame.lua — widget construction for the RecipeDetail panel.
-- Builds all child frames once at load time and stores references in ACC_RecipeDetailState.
-- Layout and data binding live in RecipeDetail.lua.

ACC_RecipeDetailState = {
    -- Layout constants used by both this file and RecipeDetail.lua.
    ROW_HEIGHT         = 16,
    ROW_GAP            = 4,
    PADDING            = 8,
    INDENT             = 20,
    MAX_CHARS          = 10,
    MAX_SOURCE_HEADERS = 6,
    MAX_SOURCE_LINES   = 24,

    -- URL shown in the static popup; set in layoutQuests() before StaticPopup_Show.
    urlPromptUrl = "",

    -- Stored so the "show more drops" button can re-call showRecipeDetail without
    -- needing the browser to pass the arguments again.
    currentRecipe = nil,
    currentBtn    = nil,

    -- Widget references — all populated by createDetailFrame() via ACC.initRecipeDetail().
    frame                = nil,
    spellButton          = nil,
    knownLabel           = nil,
    specLabel            = nil,
    charLabels           = {},
    createsButton        = nil,
    materialsHeader      = nil,
    reagentButtons       = {},
    questButtons         = {},
    sourceHeaders        = {},
    sourceLabels         = {},
    showMoreDropsButton  = nil,
}

local RDS = ACC_RecipeDetailState

-- URL prompt shown when a quest entry has a wowheadUrl instead of a linkable quest ID.
StaticPopupDialogs["ACC_URL"] = {
    text         = "Copy this URL and open it in your browser:",
    button1      = "Close",
    hasEditBox   = 1,
    editBoxWidth = 320,
    OnShow = function(self)
        local eb = _G[self:GetName() .. "EditBox"]
        if eb then eb:SetText(RDS.urlPromptUrl) end
    end,
    timeout      = 0,
    whileDead    = 1,
    hideOnEscape = 1,
}

-- Creates a square icon texture anchored to the left edge of a parent frame.
local function addIcon(parent)
    local icon = parent:CreateTexture(nil, "OVERLAY")
    icon:SetWidth(RDS.ROW_HEIGHT)
    icon:SetHeight(RDS.ROW_HEIGHT)
    icon:SetPoint("LEFT", parent, "LEFT", 0, 0)
    return icon
end

local function createDetailFrame()
    RDS.frame = CreateFrame("Frame", "AccRecipeDetailFrame", UIParent, "BasicFrameTemplate")
    RDS.frame:SetWidth(260)
    RDS.frame:SetHeight(100)
    RDS.frame:SetPoint("CENTER", UIParent, "CENTER", 320, 0)
    RDS.frame:SetFrameStrata("DIALOG")
    RDS.frame:EnableMouse(true)
    RDS.frame:SetMovable(true)
    RDS.frame:RegisterForDrag("LeftButton")
    RDS.frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    RDS.frame:SetScript("OnDragStop",  function(self) self:StopMovingOrSizing() end)
    RDS.frame:Hide()

    -- Spell / recipe item row — always the first row, fixed at y = -40.
    RDS.spellButton = CreateFrame("Button", "AccRecipeButton", RDS.frame)
    RDS.spellButton:SetHeight(RDS.ROW_HEIGHT)
    RDS.spellButton:SetPoint("TOPLEFT",  RDS.frame, "TOPLEFT",  RDS.PADDING, -40)
    RDS.spellButton:SetPoint("TOPRIGHT", RDS.frame, "TOPRIGHT", -(RDS.PADDING + 20), -40)
    RDS.spellButton:EnableMouse(true)
    RDS.spellButton:RegisterForClicks("LeftButtonUp")
    RDS.spellButton.icon = addIcon(RDS.spellButton)
    local spellText = RDS.spellButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    spellText:SetPoint("LEFT", RDS.spellButton, "LEFT", RDS.ROW_HEIGHT + 2, 0)
    spellText:SetJustifyH("LEFT")
    RDS.spellButton.text = spellText

    -- Specialization label (Gnomish / Goblin) — position set dynamically, hidden by default.
    RDS.specLabel = RDS.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    RDS.specLabel:Hide()

    -- Known / Not Known label — position set dynamically.
    RDS.knownLabel = RDS.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")

    -- Character name labels — position set dynamically, hidden by default.
    for i = 1, RDS.MAX_CHARS do
        local lbl = RDS.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:Hide()
        RDS.charLabels[i] = lbl
    end

    -- Creates row — position set dynamically.
    RDS.createsButton = CreateFrame("Button", nil, RDS.frame)
    RDS.createsButton:SetHeight(RDS.ROW_HEIGHT)
    RDS.createsButton:EnableMouse(true)
    RDS.createsButton:RegisterForClicks("LeftButtonUp")
    RDS.createsButton.icon = addIcon(RDS.createsButton)
    local createsText = RDS.createsButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    createsText:SetPoint("LEFT", RDS.createsButton, "LEFT", RDS.ROW_HEIGHT + 2, 0)
    createsText:SetJustifyH("LEFT")
    RDS.createsButton.text = createsText

    -- Materials header — position set dynamically.
    RDS.materialsHeader = RDS.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    RDS.materialsHeader:SetText("Materials:")

    -- Reagent rows — position set dynamically, hidden by default.
    for i = 1, 16 do
        local btn = CreateFrame("Button", nil, RDS.frame)
        btn:SetHeight(RDS.ROW_HEIGHT)
        btn:EnableMouse(true)
        btn:RegisterForClicks("LeftButtonUp")
        btn.icon = addIcon(btn)
        local itemText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        itemText:SetPoint("LEFT", btn, "LEFT", RDS.ROW_HEIGHT + 2, 0)
        itemText:SetJustifyH("LEFT")
        btn.text = itemText
        btn:Hide()
        RDS.reagentButtons[i] = btn
    end

    -- Source section: headers and content lines, populated from sources data.
    for i = 1, RDS.MAX_SOURCE_HEADERS do
        local hdr = RDS.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hdr:Hide()
        RDS.sourceHeaders[i] = hdr
    end
    for i = 1, RDS.MAX_SOURCE_LINES do
        local lbl = RDS.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetTextColor(1, 1, 1)
        lbl:Hide()
        RDS.sourceLabels[i] = lbl
    end

    -- "Show more drops" button — shown below drop lines when the list is truncated.
    RDS.showMoreDropsButton = CreateFrame("Button", nil, RDS.frame)
    RDS.showMoreDropsButton:SetHeight(RDS.ROW_HEIGHT)
    RDS.showMoreDropsButton:EnableMouse(true)
    RDS.showMoreDropsButton:RegisterForClicks("LeftButtonUp")
    local smText = RDS.showMoreDropsButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    smText:SetPoint("LEFT", RDS.showMoreDropsButton, "LEFT", 0, 0)
    smText:SetJustifyH("LEFT")
    RDS.showMoreDropsButton.text = smText
    RDS.showMoreDropsButton:Hide()

    -- Quest buttons — pool of up to 4 clickable quest links.
    for i = 1, 4 do
        local btn = CreateFrame("Button", nil, RDS.frame)
        btn:SetHeight(RDS.ROW_HEIGHT)
        btn:EnableMouse(true)
        btn:RegisterForClicks("LeftButtonUp")
        local qText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        qText:SetPoint("LEFT", btn, "LEFT", 0, 0)
        qText:SetJustifyH("LEFT")
        btn.text = qText
        btn:Hide()
        RDS.questButtons[i] = btn
    end
end

-- Called from browserInit() so the detail frame is ready before the player opens the browser.
function ACC.initRecipeDetail()
    createDetailFrame()
end

-- Called when the user switches profession or category to dismiss the stale detail panel.
function ACC.closeAllBrowserWindows()
    if RDS.frame then
        RDS.frame:Hide()
    end
end
