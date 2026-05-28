-- RecipeDetailSources.lua — source section builder and renderer for the RecipeDetail panel.

local RDS          = ACC_RecipeDetailState
local DROP_LIMIT   = 8
-- Set to true by the "show more" button before re-calling showRecipeDetail; reset to false
-- at the end of layoutSources so every fresh recipe open starts collapsed again.
local showAllDrops = false

-- Collects all recipe sources into an ordered list of {header, lines} sections for display.
local function buildSourceSections(recipe)
    local sections = {}
    local sources  = recipe.sources or {}

    local function addSection(header, lines)
        if #lines > 0 then sections[#sections + 1] = { header = header, lines = lines } end
    end

    local vendorLines = {}
    for _, src in ipairs(sources) do
        if src.type == "vendor" and src.vendors then
            if src.reputation then
                vendorLines[#vendorLines + 1] = "|cffffff00" .. src.reputation.faction .. " — " .. src.reputation.level .. " required|r"
            end
            for _, v in ipairs(src.vendors) do
                vendorLines[#vendorLines + 1] = v.name .. "  —  " .. (v.zone or "")
            end
        end
    end
    addSection("Sold by:", vendorLines)

    local trainerLines = {}
    for _, src in ipairs(sources) do
        if src.type == "trainer" and src.trainers then
            for _, t in ipairs(src.trainers) do
                trainerLines[#trainerLines + 1] = t.name .. "  —  " .. (t.zone or "")
            end
        elseif src.type == "npc" and src.npcs then
            for _, n in ipairs(src.npcs) do
                trainerLines[#trainerLines + 1] = n.name .. "  —  " .. (n.zone or "")
            end
        end
    end
    addSection("Taught by:", trainerLines)

    local drops = {}
    for _, src in ipairs(sources) do
        if src.type == "drop" and src.creatures then
            for _, c in ipairs(src.creatures) do drops[#drops + 1] = c end
        end
    end
    table.sort(drops, function(a, b) return (a.rate or 0) > (b.rate or 0) end)
    local limit    = (showAllDrops or #drops <= DROP_LIMIT) and #drops or DROP_LIMIT
    local dropLines = {}
    for i = 1, limit do
        local c    = drops[i]
        local line = c.name
        if c.zone then
            local z = type(c.zone) == "table" and table.concat(c.zone, ", ") or c.zone
            line = line .. "  —  " .. z
        end
        if c.rate then line = line .. "  |cffaaaaaa(" .. string.format("%.2f", c.rate) .. "%)|r" end
        dropLines[#dropLines + 1] = line
    end
    addSection("Drops from:", dropLines)
    local hiddenDrops = #drops - limit

    local containerLines = {}
    local CONTAINER = { chest = true, lockbox = true, other = true, decoded = true }
    for _, src in ipairs(sources) do
        if CONTAINER[src.type] and src.containers then
            for _, c in ipairs(src.containers) do
                local line = c.name
                if c.rate then line = line .. "  |cffaaaaaa(" .. string.format("%.2f", c.rate) .. "%)|r" end
                containerLines[#containerLines + 1] = line
            end
        end
    end
    if #containerLines > 0 then table.sort(containerLines) end
    addSection("Found in:", containerLines)

    local miscLines = {}
    for _, src in ipairs(sources) do
        if src.type == "world_drop" then
            local line = "World drop"
            if src.level_range then
                line = line .. "  |cffaaaaaa(level " .. src.level_range[1] .. "–" .. src.level_range[2] .. ")|r"
            end
            miscLines[#miscLines + 1] = line
        elseif src.type == "holiday" then
            miscLines[#miscLines + 1] = "Holiday: " .. (src.event or "")
        elseif src.type == "object" then
            miscLines[#miscLines + 1] = "Clickable object" .. (src.zone and ("  —  " .. src.zone) or "")
        elseif src.type == "note" then
            miscLines[#miscLines + 1] = src.text or ""
        end
    end
    addSection("Also from:", miscLines)

    return sections, hiddenDrops or 0
end

-- Source sections (Sold by, Taught by, Drops from, etc.). Returns updated y.
function ACC.layoutSources(recipe, y)
    local sections, hiddenDrops = buildSourceSections(recipe)
    local hdrIdx, lblIdx        = 0, 0
    local buttonShown           = false

    for _, sec in ipairs(sections) do
        hdrIdx = hdrIdx + 1
        if hdrIdx > RDS.MAX_SOURCE_HEADERS then break end
        local hdr = RDS.sourceHeaders[hdrIdx]
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.PADDING, y)
        hdr:SetText(sec.header)
        hdr:Show()
        y = y - RDS.ROW_HEIGHT - 2
        for _, line in ipairs(sec.lines) do
            lblIdx = lblIdx + 1
            if lblIdx > RDS.MAX_SOURCE_LINES then break end
            local lbl = RDS.sourceLabels[lblIdx]
            lbl:ClearAllPoints()
            lbl:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.INDENT, y)
            lbl:SetText(line)
            lbl:Show()
            y = y - RDS.ROW_HEIGHT
        end
        -- After drop lines, show "… N more" button if some were hidden.
        if sec.header == "Drops from:" and hiddenDrops > 0 then
            RDS.showMoreDropsButton:ClearAllPoints()
            RDS.showMoreDropsButton:SetPoint("TOPLEFT", RDS.frame, "TOPLEFT", RDS.INDENT, y)
            RDS.showMoreDropsButton:SetWidth(RDS.frame:GetWidth() - RDS.INDENT - RDS.PADDING)
            RDS.showMoreDropsButton.text:SetText("|cff00ccff… " .. hiddenDrops .. " more — click to show all|r")
            RDS.showMoreDropsButton:SetScript("OnClick", function()
                showAllDrops = true
                ACC.showRecipeDetail(RDS.currentRecipe, RDS.currentBtn)
            end)
            RDS.showMoreDropsButton:Show()
            buttonShown = true
            y = y - RDS.ROW_HEIGHT
        end
        y = y - RDS.ROW_GAP
    end

    for i = hdrIdx + 1, RDS.MAX_SOURCE_HEADERS do RDS.sourceHeaders[i]:Hide() end
    for i = lblIdx + 1, RDS.MAX_SOURCE_LINES   do RDS.sourceLabels[i]:Hide()  end
    if not buttonShown then RDS.showMoreDropsButton:Hide() end

    showAllDrops = false
    return y
end
