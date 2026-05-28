-- RecipeDetailZone.lua — fishing zone detail layout for the RecipeDetail panel.
-- Reuses reagentButtons (pool 16) for item links instead of the normal reagent rows.

local RDS = ACC_RecipeDetailState

-- Fishing zone detail: cast thresholds, clickable pool fish, clickable open-water fish.
-- Returns final y so the caller can size the frame.
function ACC.layoutZone(recipe)
    RDS.spellButton.text:SetText("|cffffff00" .. recipe.name .. "|r")
    RDS.spellButton.icon:SetTexture("Interface\\Icons\\Trade_Fishing")
    -- Clear handlers: zone title is display-only; stale recipe handlers must not fire.
    RDS.spellButton:SetScript("OnEnter", nil)
    RDS.spellButton:SetScript("OnLeave", nil)
    RDS.spellButton:SetScript("OnClick", nil)

    RDS.specLabel:Hide()
    RDS.knownLabel:Hide()
    for i = 1, RDS.MAX_CHARS do RDS.charLabels[i]:Hide() end
    RDS.createsButton:Hide()
    RDS.materialsHeader:Hide()
    for i = 1, 4 do
        RDS.questButtons[i]:SetScript("OnEnter", nil)
        RDS.questButtons[i]:SetScript("OnLeave", nil)
        RDS.questButtons[i]:SetScript("OnClick", nil)
        RDS.questButtons[i]:Hide()
    end

    local y       = -40 - RDS.ROW_HEIGHT - RDS.ROW_GAP
    local hdrIdx  = 0
    local lblIdx  = 0
    local rbtnIdx = 0

    -- Cast info
    hdrIdx = hdrIdx + 1
    local hdr = RDS.sourceHeaders[hdrIdx]
    hdr:ClearAllPoints()
    hdr:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.PADDING, y)
    hdr:SetText("Fishing info:")
    hdr:Show()
    y = y - RDS.ROW_HEIGHT - 2

    lblIdx = lblIdx + 1
    local lbl = RDS.sourceLabels[lblIdx]
    lbl:ClearAllPoints()
    lbl:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.INDENT, y)
    lbl:SetText("|cffff4040Minimum to cast:  " .. (recipe.minCast or "?") .. "|r")
    lbl:Show()
    y = y - RDS.ROW_HEIGHT

    lblIdx = lblIdx + 1
    lbl = RDS.sourceLabels[lblIdx]
    lbl:ClearAllPoints()
    lbl:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.INDENT, y)
    lbl:SetText("|cff40ff40Guaranteed:  " .. (recipe.guaranteed or "?") .. "|r")
    lbl:Show()
    y = y - RDS.ROW_HEIGHT - RDS.ROW_GAP

    -- Pool entries store only a fish name, not an itemId.  Build a reverse-lookup
    -- from FishingCatches so each pool row can resolve an item link.
    local catchByName = {}
    for _, catch in ipairs(ACC_Data.FishingCatches or {}) do
        catchByName[catch.name] = catch
    end

    -- Pools section
    local pools = recipe.pools or {}
    if #pools > 0 then
        hdrIdx = hdrIdx + 1
        hdr = RDS.sourceHeaders[hdrIdx]
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.PADDING, y)
        hdr:SetText("Pools:")
        hdr:Show()
        y = y - RDS.ROW_HEIGHT - 2

        for _, pool in ipairs(pools) do
            rbtnIdx = rbtnIdx + 1
            if rbtnIdx <= 16 then
                local rbtn  = RDS.reagentButtons[rbtnIdx]
                local catch = catchByName[pool.fish]
                local fId   = catch and catch.itemId
                rbtn:ClearAllPoints()
                rbtn:SetPoint("TOPLEFT",  RDS.frame, "TOPLEFT",  RDS.PADDING + 4, y)
                rbtn:SetPoint("TOPRIGHT", RDS.frame, "TOPRIGHT", -(RDS.PADDING + 20), y)
                if fId then
                    rbtn.icon:SetTexture(ACC.resolveItemIcon(fId, nil))
                    -- Pool name in blue to distinguish it from the fish item link.
                    local text = ACC.resolveItemLink(fId, pool.fish, nil) .. "  |cff4488ff(" .. pool.name .. ")"
                    if pool.note then text = text .. "  —  " .. pool.note end
                    rbtn.text:SetText(text .. "|r")
                    -- Capture fId per-iteration; the loop variable would be stale in closures.
                    local capturedId = fId
                    rbtn:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(rbtn, "ANCHOR_NONE")
                        GameTooltip:SetPoint("BOTTOMLEFT", rbtn, "TOPLEFT", 0, 2)
                        GameTooltip:SetHyperlink("item:" .. capturedId)
                        GameTooltip:Show()
                    end)
                    rbtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                    rbtn:SetScript("OnClick", function()
                        local _, freshLink = GetItemInfo(capturedId)
                        if freshLink then ACC.insertLink(freshLink) end
                    end)
                else
                    rbtn.icon:SetTexture("Interface\\Icons\\Trade_Fishing")
                    local text = "|cffffff00" .. pool.fish .. "|r  |cff4488ff(" .. pool.name .. ")"
                    if pool.note then text = text .. "  —  " .. pool.note end
                    rbtn.text:SetText(text .. "|r")
                    rbtn:SetScript("OnEnter", nil)
                    rbtn:SetScript("OnLeave", nil)
                    rbtn:SetScript("OnClick", nil)
                end
                rbtn:Show()
                y = y - RDS.ROW_HEIGHT
            end
        end
        y = y - RDS.ROW_GAP
    end

    -- Open Water section: FishingCatches entries whose zones list includes this zone.
    -- Two matching rules:
    --   Forward: clicking a parent zone shows fish annotated with sub-zones
    --     e.g. "Stranglethorn Vale" matches "Stranglethorn Vale (Jaguero Isle)"
    --   Reverse: clicking a sub-zone shows fish stored under the parent zone name
    --     e.g. "Feralas (Jademir Lake)" matches "Feralas"
    local zoneName  = recipe.name
    local parentZone = zoneName:match("^(.+) %(")  -- nil for top-level zones
    local openWater = {}
    for _, catch in ipairs(ACC_Data.FishingCatches or {}) do
        if catch.zones then
            for _, z in ipairs(catch.zones) do
                local matched = z == zoneName
                    or z:find(zoneName .. " (", 1, true) == 1
                    or (parentZone and (z == parentZone or z:find(parentZone .. " (", 1, true) == 1))
                if matched then
                    -- Store matched zone string for rate lookup — zoneRates is keyed by exact zone name.
                    openWater[#openWater + 1] = { data = catch, matchedZone = z }
                    break
                end
            end
        end
    end
    table.sort(openWater, function(a, b) return (a.data.minSkill or 0) < (b.data.minSkill or 0) end)

    if #openWater > 0 then
        hdrIdx = hdrIdx + 1
        if hdrIdx <= RDS.MAX_SOURCE_HEADERS then
            hdr = RDS.sourceHeaders[hdrIdx]
            hdr:ClearAllPoints()
            hdr:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.PADDING, y)
            hdr:SetText("Open Water:")
            hdr:Show()
            y = y - RDS.ROW_HEIGHT - 2
        end
        for _, entry in ipairs(openWater) do
            rbtnIdx = rbtnIdx + 1
            if rbtnIdx <= 16 then
                local catch = entry.data
                local rbtn  = RDS.reagentButtons[rbtnIdx]
                local fId   = catch.itemId
                rbtn:ClearAllPoints()
                rbtn:SetPoint("TOPLEFT",  RDS.frame, "TOPLEFT",  RDS.PADDING + 4, y)
                rbtn:SetPoint("TOPRIGHT", RDS.frame, "TOPRIGHT", -(RDS.PADDING + 20), y)
                rbtn.icon:SetTexture(ACC.resolveItemIcon(fId, nil))
                local extraParts = { "|cffff4040Min " .. (catch.minSkill or "?") .. "|r" }
                local rate = catch.zoneRates and catch.zoneRates[entry.matchedZone]
                if rate then extraParts[#extraParts + 1] = string.format("|cff40ff40%.1f%%|r", rate) end
                -- Hard time restriction badge.
                if     catch.timeOfDay == "night" then extraParts[#extraParts + 1] = "|cff4488ffNight Only|r"
                elseif catch.timeOfDay == "day"   then extraParts[#extraParts + 1] = "|cffffff00Day Only|r" end
                -- Season: name uses catch.season.color, date range stays orange.
                if catch.season then
                    local sCol = catch.season.color or "ff6600"
                    local sName, sDates = catch.season.label:match("^(.-)%s*%((.-)%)$")
                    if sName then
                        extraParts[#extraParts + 1] = "|cff" .. sCol .. sName .. "|r  |cffff6600(" .. sDates .. ")|r"
                    else
                        extraParts[#extraParts + 1] = "|cff" .. sCol .. catch.season.label .. "|r"
                    end
                end
                rbtn.text:SetText(ACC.resolveItemLink(fId, catch.name, nil) .. "  |cffaaaaaa(|r" .. table.concat(extraParts, "  ") .. "|cffaaaaaa)|r")
                -- Capture fId per-iteration; the loop variable would be stale in closures.
                local capturedId = fId
                rbtn:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(rbtn, "ANCHOR_NONE")
                    GameTooltip:SetPoint("BOTTOMLEFT", rbtn, "TOPLEFT", 0, 2)
                    GameTooltip:SetHyperlink("item:" .. capturedId)
                    GameTooltip:Show()
                end)
                rbtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                rbtn:SetScript("OnClick", function()
                    local _, freshLink = GetItemInfo(capturedId)
                    if freshLink then ACC.insertLink(freshLink) end
                end)
                rbtn:Show()
                y = y - RDS.ROW_HEIGHT
            end
        end
        y = y - RDS.ROW_GAP
    end

    -- Hide unused widgets.
    for i = hdrIdx + 1, RDS.MAX_SOURCE_HEADERS do RDS.sourceHeaders[i]:Hide() end
    for i = lblIdx + 1, RDS.MAX_SOURCE_LINES   do RDS.sourceLabels[i]:Hide()  end
    for i = rbtnIdx + 1, 16 do
        RDS.reagentButtons[i]:SetScript("OnEnter", nil)
        RDS.reagentButtons[i]:SetScript("OnLeave", nil)
        RDS.reagentButtons[i]:SetScript("OnClick", nil)
        RDS.reagentButtons[i].icon:SetTexture(nil)
        RDS.reagentButtons[i]:Hide()
    end

    return y
end
