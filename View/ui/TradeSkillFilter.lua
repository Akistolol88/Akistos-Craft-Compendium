-- TradeSkillFilter.lua — live text search on the native TradeSkill / CraftFrame.
--
-- Core strategy: redirect GetNumTradeSkills() and GetTradeSkillInfo() to serve
-- tsFilt data while Blizzard's own TradeSkillFrame_Update runs.  Blizzard then
-- handles all button text, colours, scroll-bar sizing, and positioning exactly as
-- it would for a real list — no manual SetText or ClearAllPoints on our part.
-- After the render we fix button IDs back to original skill indices so that
-- click handlers and the selection highlight work correctly.

local tsFilter    = ""
local craftFilter = ""
local tsBox, craftBox
local tsHooked, craftHooked = false, false
local inWrappedTs, inWrappedCraft = false, false

local tsFilt    = {}
local craftFilt = {}

-- Headers remembered to have matching children for the current filter term.
-- Persists across expand/collapse so a collapsed header stays visible.
-- Cleared whenever the filter text itself changes.
local tsMatchingHeaders = {}
local lastTsFilter      = ""

-- saved originals – populated on first TRADE_SKILL_SHOW / CRAFT_SHOW
local orig_TradeSkillFrame_Update
local orig_GetNumTradeSkills
local orig_GetTradeSkillInfo

local orig_CraftFrame_Update
local orig_GetNumCrafts
local orig_GetCraftInfo

-- ── Filter-list builders ──────────────────────────────────────────────────────

local function buildTsFilt()
    -- When the search text changes, forget which headers had matches so we start
    -- fresh.  While the text stays the same (e.g. user collapses a header),
    -- tsMatchingHeaders is preserved so the collapsed header stays visible.
    if tsFilter ~= lastTsFilter then
        tsMatchingHeaders = {}
        lastTsFilter = tsFilter
    end

    tsFilt = {}
    local total = orig_GetNumTradeSkills()

    -- Pass 1: scan currently visible (expanded) recipes to update tsMatchingHeaders.
    local lastHeader = nil
    for i = 1, total do
        local name, skillType = orig_GetTradeSkillInfo(i)
        if skillType == "header" then
            lastHeader = i
        elseif lastHeader and name and name:lower():find(tsFilter, 1, true) then
            tsMatchingHeaders[lastHeader] = true
        end
    end

    -- Pass 2: include any header we know has matches (visible or collapsed) +
    -- all visible matching recipes.
    for i = 1, total do
        local name, skillType = orig_GetTradeSkillInfo(i)
        if skillType == "header" then
            if tsMatchingHeaders[i] then tsFilt[#tsFilt + 1] = i end
        elseif name and name:lower():find(tsFilter, 1, true) then
            tsFilt[#tsFilt + 1] = i
        end
    end
end

local function buildCraftFilt()
    craftFilt = {}
    local total = orig_GetNumCrafts()
    for i = 1, total do
        local name = orig_GetCraftInfo(i)
        if name and name:lower():find(craftFilter, 1, true) then
            craftFilt[#craftFilt + 1] = i
        end
    end
end

-- ── Post-render ID fix ────────────────────────────────────────────────────────
-- Blizzard sets each button ID to its loop index (1..#tsFilt).  We replace those
-- with original skill indices so TradeSkillFrame_SetSelection gets the right value.

local function fixTsButtonIDs()
    local n      = TRADE_SKILLS_DISPLAYED or 8
    local rowH   = TRADE_SKILL_HEIGHT or 16
    local offset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)

    for i = 1, n do
        local btn = _G["TradeSkillSkill" .. i]
        if btn then
            local fi = offset + i
            if fi <= #tsFilt then
                btn:SetID(tsFilt[fi])
                btn.skillIndex = tsFilt[fi]
            end
        end
    end

    -- Re-anchor the selection highlight.  Blizzard matched by filtered index;
    -- now that IDs are original indices the highlight needs re-positioning.
    local sel = GetTradeSkillSelectionIndex and GetTradeSkillSelectionIndex()
    if sel and sel > 0 and TradeSkillHighlightFrame then
        local found = false
        for i = 1, n do
            local btn = _G["TradeSkillSkill" .. i]
            if btn and btn:IsShown() and btn:GetID() == sel then
                TradeSkillHighlightFrame:ClearAllPoints()
                TradeSkillHighlightFrame:SetPoint("TOPLEFT",     btn, "TOPLEFT",     0, 0)
                TradeSkillHighlightFrame:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
                TradeSkillHighlightFrame:Show()
                found = true
                break
            end
        end
        if not found then TradeSkillHighlightFrame:Hide() end
    end
end

local function fixCraftButtonIDs()
    local n      = CRAFTS_DISPLAYED or 8
    local offset = FauxScrollFrame_GetOffset(CraftListScrollFrame)
    for i = 1, n do
        local btn = _G["CraftSkill" .. i]
        if btn then
            local fi = offset + i
            if fi <= #craftFilt then btn:SetID(craftFilt[fi]) end
        end
    end
end

-- ── Wrapped update functions ──────────────────────────────────────────────────

local function wrappedTradeSkillFrame_Update()
    if tsFilter == "" then
        orig_TradeSkillFrame_Update()
        return
    end

    if inWrappedTs then
        -- Re-entrant call (from FauxScrollFrame scroll callback inside orig update).
        -- Redirects are already active; just run the original.
        orig_TradeSkillFrame_Update()
        return
    end

    inWrappedTs = true
    buildTsFilt()

    -- Redirect skill API to our filtered list for the duration of the Blizzard call.
    GetNumTradeSkills = function() return #tsFilt end
    GetTradeSkillInfo = function(i)
        local si = (i and i > 0 and i <= #tsFilt) and tsFilt[i]
        if si then return orig_GetTradeSkillInfo(si) end
        return nil, nil, 0, nil, nil
    end

    local ok = pcall(orig_TradeSkillFrame_Update)

    -- Always restore originals, even on error.
    GetNumTradeSkills = orig_GetNumTradeSkills
    GetTradeSkillInfo = orig_GetTradeSkillInfo
    inWrappedTs = false

    if ok then fixTsButtonIDs() end
end

local function wrappedCraftFrame_Update()
    if craftFilter == "" then
        orig_CraftFrame_Update()
        return
    end

    if inWrappedCraft then
        orig_CraftFrame_Update()
        return
    end

    inWrappedCraft = true
    buildCraftFilt()

    GetNumCrafts = function() return #craftFilt end
    GetCraftInfo = function(i)
        local ci = (i and i > 0 and i <= #craftFilt) and craftFilt[i]
        if ci then return orig_GetCraftInfo(ci) end
        return nil, nil, 0, nil, nil
    end

    local ok = pcall(orig_CraftFrame_Update)

    GetNumCrafts = orig_GetNumCrafts
    GetCraftInfo = orig_GetCraftInfo
    inWrappedCraft = false

    if ok then fixCraftButtonIDs() end
end

-- ── Search boxes ──────────────────────────────────────────────────────────────

local function createTsBox()
    if tsBox then return end

    tsBox = CreateFrame("EditBox", "ACCTradeSkillSearch", TradeSkillFrame, "InputBoxTemplate")
    tsBox:SetWidth(110)
    tsBox:SetHeight(18)
    tsBox:SetAutoFocus(false)
    tsBox:SetMaxLetters(50)

    local lbl = TradeSkillFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("BOTTOM", tsBox, "TOP", 0, 2)
    lbl:SetText("Search")
    tsBox.label = lbl

    tsBox:SetScript("OnTextChanged", function(self)
        tsFilter = self:GetText():lower()
        if not TradeSkillFrame:IsShown() then return end
        if tsFilter == "" then
            -- Scroll back to top when clearing the filter.
            local sb = _G["TradeSkillListScrollFrameScrollBar"]
            if sb then sb:SetValue(0) end
        end
        TradeSkillFrame_Update()
    end)
    tsBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    tsBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
end

local function positionTsBox()
    tsBox:ClearAllPoints()
    local toggle = _G["AccMissingToggle"]
    if toggle and toggle:IsShown() then
        tsBox:SetPoint("TOPRIGHT", toggle, "TOPLEFT", -4, -1)
    else
        tsBox:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -40, 1)
    end
end

local function createCraftBox()
    if craftBox then return end

    craftBox = CreateFrame("EditBox", "ACCCraftSearch", CraftFrame, "InputBoxTemplate")
    craftBox:SetWidth(110)
    craftBox:SetHeight(18)
    craftBox:SetAutoFocus(false)
    craftBox:SetMaxLetters(50)

    local lbl = CraftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("BOTTOM", craftBox, "TOP", 0, 2)
    lbl:SetText("Search")
    craftBox.label = lbl

    craftBox:SetScript("OnTextChanged", function(self)
        craftFilter = self:GetText():lower()
        if not CraftFrame:IsShown() then return end
        if craftFilter == "" then
            local sb = _G["CraftListScrollFrameScrollBar"]
            if sb then sb:SetValue(0) end
        end
        CraftFrame_Update()
    end)
    craftBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    craftBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
end

local function positionCraftBox()
    craftBox:ClearAllPoints()
    local toggle = _G["AccMissingToggle"]
    if toggle and toggle:IsShown() then
        craftBox:SetPoint("TOPRIGHT", toggle, "TOPLEFT", -4, -1)
    else
        craftBox:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -40, 1)
    end
end

-- ── Events ────────────────────────────────────────────────────────────────────

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")
eventFrame:RegisterEvent("CRAFT_SHOW")
eventFrame:RegisterEvent("CRAFT_CLOSE")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "TRADE_SKILL_SHOW" then
        if not tsHooked then
            tsHooked = true
            orig_TradeSkillFrame_Update = TradeSkillFrame_Update
            orig_GetNumTradeSkills      = GetNumTradeSkills
            orig_GetTradeSkillInfo      = GetTradeSkillInfo
            TradeSkillFrame_Update      = wrappedTradeSkillFrame_Update
        end
        createTsBox()
        positionTsBox()
        tsBox:Show()
        tsBox.label:Show()

    elseif event == "TRADE_SKILL_CLOSE" then
        if tsBox then
            tsFilter = ""
            tsBox:SetText("")
            tsBox:ClearFocus()
            tsBox:Hide()
            tsBox.label:Hide()
        end

    elseif event == "CRAFT_SHOW" then
        if not craftHooked then
            craftHooked = true
            orig_CraftFrame_Update = CraftFrame_Update
            orig_GetNumCrafts      = GetNumCrafts
            orig_GetCraftInfo      = GetCraftInfo
            CraftFrame_Update      = wrappedCraftFrame_Update
        end
        createCraftBox()
        positionCraftBox()
        craftBox:Show()
        craftBox.label:Show()

    elseif event == "CRAFT_CLOSE" then
        if craftBox then
            craftFilter = ""
            craftBox:SetText("")
            craftBox:ClearFocus()
            craftBox:Hide()
            craftBox.label:Hide()
        end
    end
end)
