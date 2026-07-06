-- TradeSkillFilter.lua — live text search on the native TradeSkill and CraftFrame.

local tsFilter    = ""
local craftFilter = ""
local tsBox, craftBox
local tsHooked, craftHooked = false, false
local inWrappedTs, inWrappedCraft = false, false

local tsFilt    = {}
local craftFilt = {}

-- Cleared when the filter text changes; kept across expand/collapse so a
-- collapsed category header remains visible and re-expandable during search.
local tsMatchingHeaders = {}
local lastTsFilter      = ""

local origTsUpdate, origGetNumTs, origGetTsInfo
local origCraftUpdate, origGetNumCrafts, origGetCraftInfo

-- ── Filter-list builders ──────────────────────────────────────────────────────

local function buildTsFilt()
    if tsFilter ~= lastTsFilter then
        tsMatchingHeaders = {}
        lastTsFilter = tsFilter
    end

    tsFilt = {}
    local total = origGetNumTs()
    local lastHeader = nil

    for i = 1, total do
        local name, skillType = origGetTsInfo(i)
        if skillType == "header" then
            lastHeader = i
        elseif lastHeader and name and name:lower():find(tsFilter, 1, true) then
            tsMatchingHeaders[lastHeader] = true
        end
    end

    for i = 1, total do
        local name, skillType = origGetTsInfo(i)
        if skillType == "header" then
            if tsMatchingHeaders[i] then tsFilt[#tsFilt + 1] = i end
        elseif name and name:lower():find(tsFilter, 1, true) then
            tsFilt[#tsFilt + 1] = i
        end
    end
end

local function buildCraftFilt()
    craftFilt = {}
    local total = origGetNumCrafts()
    for i = 1, total do
        local name = origGetCraftInfo(i)
        if name and name:lower():find(craftFilter, 1, true) then
            craftFilt[#craftFilt + 1] = i
        end
    end
end

-- ── Post-render ID fix ────────────────────────────────────────────────────────

local function fixTsButtonIDs()
    local n      = TRADE_SKILLS_DISPLAYED or 8
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

    -- Blizzard matched highlight by filtered index; re-anchor to original index.
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

local function wrappedTsUpdate()
    if tsFilter == "" then
        origTsUpdate()
        return
    end

    if inWrappedTs then
        -- Re-entrant from FauxScrollFrame scroll callback; redirects are active.
        origTsUpdate()
        return
    end

    inWrappedTs = true
    buildTsFilt()

    GetNumTradeSkills = function() return #tsFilt end
    GetTradeSkillInfo = function(i)
        local si = (i and i > 0 and i <= #tsFilt) and tsFilt[i]
        if si then return origGetTsInfo(si) end
        return nil, nil, 0, nil, nil
    end

    local ok = pcall(origTsUpdate)

    GetNumTradeSkills = origGetNumTs
    GetTradeSkillInfo = origGetTsInfo
    inWrappedTs = false

    if ok then fixTsButtonIDs() end
end

local function wrappedCraftUpdate()
    if craftFilter == "" then
        origCraftUpdate()
        return
    end

    if inWrappedCraft then
        origCraftUpdate()
        return
    end

    inWrappedCraft = true
    buildCraftFilt()

    GetNumCrafts = function() return #craftFilt end
    GetCraftInfo = function(i)
        local ci = (i and i > 0 and i <= #craftFilt) and craftFilt[i]
        if ci then return origGetCraftInfo(ci) end
        return nil, nil, 0, nil, nil
    end

    local ok = pcall(origCraftUpdate)

    GetNumCrafts  = origGetNumCrafts
    GetCraftInfo  = origGetCraftInfo
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
            tsHooked         = true
            origTsUpdate     = TradeSkillFrame_Update
            origGetNumTs     = GetNumTradeSkills
            origGetTsInfo    = GetTradeSkillInfo
            TradeSkillFrame_Update = wrappedTsUpdate
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
            craftHooked      = true
            origCraftUpdate  = CraftFrame_Update
            origGetNumCrafts = GetNumCrafts
            origGetCraftInfo = GetCraftInfo
            CraftFrame_Update = wrappedCraftUpdate
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
