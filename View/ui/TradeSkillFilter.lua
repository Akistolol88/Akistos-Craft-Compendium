-- TradeSkillFilter.lua — live text search on the native TradeSkill and CraftFrame.

local tsFilter    = ""
local craftFilter = ""
local tsMatsOnly, craftMatsOnly = false, false
local tsBox, craftBox
local tsMatsCheck, craftMatsCheck
local tsHooked, craftHooked     = false, false
local inWrappedTs, inWrappedCraft = false, false

local tsFilt    = {}
local craftFilt = {}

-- Cleared when the filter text or the "have mats" toggle changes; kept across
-- expand/collapse so a collapsed category header remains visible and
-- re-expandable during search.
local tsMatchingHeaders = {}
local lastTsFilterKey   = ""

local origTsUpdate, origGetNumTs, origGetTsInfo, origGetTsSel
local origCraftUpdate, origGetNumCrafts, origGetCraftInfo

-- ── Craftability checks ─────────────────────────────────────────────────────────

-- Blizzard's own reagent-count APIs only ever reflect bag contents (crafting
-- has never been able to draw reagents from the bank), so no separate
-- bags-vs-bank accounting is needed here.
local function isTsCraftable(realIndex)
    local numReagents = GetTradeSkillNumReagents(realIndex)
    if not numReagents or numReagents == 0 then return true end
    for r = 1, numReagents do
        local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(realIndex, r)
        if not reagentCount or (playerReagentCount or 0) < reagentCount then
            return false
        end
    end
    return true
end

local function isCraftCraftable(realIndex)
    local numReagents = GetCraftNumReagents(realIndex)
    if not numReagents or numReagents == 0 then return true end
    for r = 1, numReagents do
        local _, _, reagentCount, playerReagentCount = GetCraftReagentInfo(realIndex, r)
        if not reagentCount or (playerReagentCount or 0) < reagentCount then
            return false
        end
    end
    return true
end

-- ── Filter-list builders ──────────────────────────────────────────────────────

local tsFiltReverse = {}

local function matchesTs(realIndex, name)
    if tsFilter ~= "" and not (name and name:lower():find(tsFilter, 1, true)) then
        return false
    end
    if tsMatsOnly and not isTsCraftable(realIndex) then
        return false
    end
    return true
end

local function buildTsFilt()
    local filterKey = tsFilter .. "\0" .. tostring(tsMatsOnly)
    if filterKey ~= lastTsFilterKey then
        tsMatchingHeaders = {}
        lastTsFilterKey = filterKey
    end

    tsFilt = {}
    tsFiltReverse = {}
    local total = origGetNumTs()
    local lastHeaderName = nil

    for i = 1, total do
        local name, skillType = origGetTsInfo(i)
        if skillType == "header" then
            lastHeaderName = name
        elseif lastHeaderName and matchesTs(i, name) then
            tsMatchingHeaders[lastHeaderName] = true
        end
    end

    for i = 1, total do
        local name, skillType = origGetTsInfo(i)
        if skillType == "header" then
            if tsMatchingHeaders[name] then tsFilt[#tsFilt + 1] = i end
        elseif matchesTs(i, name) then
            tsFilt[#tsFilt + 1] = i
        end
    end

    for fakeIdx, realIdx in ipairs(tsFilt) do
        tsFiltReverse[realIdx] = fakeIdx
    end
end

local function buildCraftFilt()
    craftFilt = {}
    local total = origGetNumCrafts()
    for i = 1, total do
        local name = origGetCraftInfo(i)
        if name and name:lower():find(craftFilter, 1, true) and (not craftMatsOnly or isCraftCraftable(i)) then
            craftFilt[#craftFilt + 1] = i
        end
    end
end

-- ── Post-render ID fix ────────────────────────────────────────────────────────

-- Sole authority for TradeSkillHighlightFrame: always either anchors it to the
-- one button showing the truly-selected recipe, or hides it. Run after every
-- render (filtered or plain) so no stale/duplicate highlight can survive a
-- scroll, a collapse, or a frame close/reopen.
local function fixTsHighlight()
    if not TradeSkillHighlightFrame then return end

    local n = TRADE_SKILLS_DISPLAYED or 8
    local sel = GetTradeSkillSelectionIndex and GetTradeSkillSelectionIndex()
    local found = false

    if sel and sel > 0 then
        for i = 1, n do
            local btn = _G["TradeSkillSkill" .. i]
            if btn and btn:IsShown() and btn:GetID() == sel then
                TradeSkillHighlightFrame:ClearAllPoints()
                TradeSkillHighlightFrame:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
                TradeSkillHighlightFrame:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
                TradeSkillHighlightFrame:Show()
                found = true
                break
            end
        end
    end

    if not found then TradeSkillHighlightFrame:Hide() end
end

local function fixTsButtonIDs()
    local n = TRADE_SKILLS_DISPLAYED or 8

    -- Read back the fake (filtered-space) index Blizzard's own render just
    -- assigned via SetID, rather than recomputing our own scroll offset —
    -- the two can desync (e.g. the scrollbar clamping mid-render when the
    -- filtered count shrinks), which would remap every row to the wrong
    -- real recipe.
    for i = 1, n do
        local btn = _G["TradeSkillSkill" .. i]
        if btn and btn:IsShown() then
            local fakeIndex = btn:GetID()
            local realIndex = fakeIndex and fakeIndex > 0 and tsFilt[fakeIndex]
            if realIndex then
                btn:SetID(realIndex)
                btn.skillIndex = realIndex
            end
        end
    end

    fixTsHighlight()
end

local function fixCraftButtonIDs()
    local n = CRAFTS_DISPLAYED or 8
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
    if tsFilter == "" and not tsMatsOnly then
        origTsUpdate()
        fixTsHighlight()
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
    -- Blizzard's update loop compares filtered (loop) index against the real
    -- selection index — both to place the highlight AND, separately, to find
    -- the selected recipe's numAvailable for the "Create All" button. Both
    -- comparisons run against fake (filtered-space) indices, so the real
    -- selection index has to be translated into its fake counterpart here
    -- (or 0 if the selected recipe is filtered out) rather than just zeroed —
    -- zeroing it left numAvailable stale under a filter, so Create All fed
    -- DoTradeSkill a nil/stale count and only crafted once. fixTsButtonIDs
    -- still re-applies the highlight afterward using real IDs regardless.
    if origGetTsSel then
        local realSel = origGetTsSel()
        local fakeSel = (realSel and realSel > 0 and tsFiltReverse[realSel]) or 0
        GetTradeSkillSelectionIndex = function() return fakeSel end
    end

    local ok = pcall(origTsUpdate)

    GetNumTradeSkills = origGetNumTs
    GetTradeSkillInfo = origGetTsInfo
    if origGetTsSel then
        GetTradeSkillSelectionIndex = origGetTsSel
    end
    inWrappedTs = false

    if ok then fixTsButtonIDs() end
end

local function wrappedCraftUpdate()
    if craftFilter == "" and not craftMatsOnly then
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

    GetNumCrafts = origGetNumCrafts
    GetCraftInfo = origGetCraftInfo
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

local function createTsMatsCheck()
    if tsMatsCheck then return end

    tsMatsCheck = CreateFrame("CheckButton", "ACCTradeSkillMatsOnly", TradeSkillFrame, "UICheckButtonTemplate")
    tsMatsCheck:SetWidth(20)
    tsMatsCheck:SetHeight(20)
    tsMatsCheck:SetChecked(tsMatsOnly)

    tsMatsCheck:SetScript("OnClick", function(self)
        tsMatsOnly = self:GetChecked() and true or false
        if not TradeSkillFrame:IsShown() then return end
        local sb = _G["TradeSkillListScrollFrameScrollBar"]
        if sb then sb:SetValue(0) end
        TradeSkillFrame_Update()
    end)
    tsMatsCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Have Mats", 1, 1, 1)
        GameTooltip:AddLine("Only show recipes you can craft right now with reagents in your bags.", 1, 0.82, 0, true)
        GameTooltip:AddLine("Bank reagents don't count.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    tsMatsCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function positionTsBox()
    tsBox:ClearAllPoints()
    local toggle = _G["AccMissingToggle"]
    if toggle and toggle:IsShown() then
        tsBox:SetPoint("TOPRIGHT", toggle, "TOPLEFT", -4, -1)
    else
        tsBox:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -40, 1)
    end

    tsMatsCheck:ClearAllPoints()
    tsMatsCheck:SetPoint("RIGHT", tsBox, "LEFT", -2, 0)
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

local function createCraftMatsCheck()
    if craftMatsCheck then return end

    craftMatsCheck = CreateFrame("CheckButton", "ACCCraftMatsOnly", CraftFrame, "UICheckButtonTemplate")
    craftMatsCheck:SetWidth(20)
    craftMatsCheck:SetHeight(20)
    craftMatsCheck:SetChecked(craftMatsOnly)

    craftMatsCheck:SetScript("OnClick", function(self)
        craftMatsOnly = self:GetChecked() and true or false
        if not CraftFrame:IsShown() then return end
        local sb = _G["CraftListScrollFrameScrollBar"]
        if sb then sb:SetValue(0) end
        CraftFrame_Update()
    end)
    craftMatsCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Have Mats", 1, 1, 1)
        GameTooltip:AddLine("Only show recipes you can craft right now with reagents in your bags.", 1, 0.82, 0, true)
        GameTooltip:AddLine("Bank reagents don't count.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    craftMatsCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function positionCraftBox()
    craftBox:ClearAllPoints()
    local toggle = _G["AccMissingToggle"]
    if toggle and toggle:IsShown() then
        craftBox:SetPoint("TOPRIGHT", toggle, "TOPLEFT", -4, -1)
    else
        craftBox:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -40, 1)
    end

    craftMatsCheck:ClearAllPoints()
    craftMatsCheck:SetPoint("RIGHT", craftBox, "LEFT", -2, 0)
end

-- ── Events ────────────────────────────────────────────────────────────────────

-- Coalesces bursts of BAG_UPDATE (e.g. a stack splitting across many slots)
-- into a single refresh, and only bothers at all while a "have mats" filter
-- is actually active on a visible frame.
local pendingBagRefresh = false
local function scheduleBagRefresh()
    if not tsMatsOnly and not craftMatsOnly then return end
    if pendingBagRefresh then return end
    pendingBagRefresh = true
    C_Timer.After(0.2, function()
        pendingBagRefresh = false
        if tsMatsOnly and TradeSkillFrame and TradeSkillFrame:IsShown() then
            TradeSkillFrame_Update()
        end
        if craftMatsOnly and CraftFrame and CraftFrame:IsShown() then
            CraftFrame_Update()
        end
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")
eventFrame:RegisterEvent("CRAFT_SHOW")
eventFrame:RegisterEvent("CRAFT_CLOSE")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "TRADE_SKILL_SHOW" then
        if not tsHooked then
            tsHooked = true
            origTsUpdate = TradeSkillFrame_Update
            origGetNumTs = GetNumTradeSkills
            origGetTsInfo = GetTradeSkillInfo
            origGetTsSel = GetTradeSkillSelectionIndex
            TradeSkillFrame_Update = wrappedTsUpdate
        end
        createTsBox()
        createTsMatsCheck()
        positionTsBox()
        tsBox:Show()
        tsBox.label:Show()
        tsMatsCheck:Show()

    elseif event == "TRADE_SKILL_CLOSE" then
        if tsBox then
            tsFilter = ""
            tsBox:SetText("")
            tsBox:ClearFocus()
            tsBox:Hide()
            tsBox.label:Hide()
        end
        if tsMatsCheck then
            tsMatsOnly = false
            tsMatsCheck:SetChecked(false)
            tsMatsCheck:Hide()
        end

    elseif event == "CRAFT_SHOW" then
        if not craftHooked then
            craftHooked = true
            origCraftUpdate = CraftFrame_Update
            origGetNumCrafts = GetNumCrafts
            origGetCraftInfo = GetCraftInfo
            CraftFrame_Update = wrappedCraftUpdate
        end
        createCraftBox()
        createCraftMatsCheck()
        positionCraftBox()
        craftBox:Show()
        craftBox.label:Show()
        craftMatsCheck:Show()

    elseif event == "CRAFT_CLOSE" then
        if craftBox then
            craftFilter = ""
            craftBox:SetText("")
            craftBox:ClearFocus()
            craftBox:Hide()
            craftBox.label:Hide()
        end
        if craftMatsCheck then
            craftMatsOnly = false
            craftMatsCheck:SetChecked(false)
            craftMatsCheck:Hide()
        end

    elseif event == "BAG_UPDATE" then
        scheduleBagRefresh()
    end
end)
