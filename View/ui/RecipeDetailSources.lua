-- RecipeDetailSources.lua — source section builder and renderer for the RecipeDetail panel.

local RDS = ACC_RecipeDetailState

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
    local dropLines = {}
    for i = 1, math.min(#drops, 8) do
        local c    = drops[i]
        local line = c.name
        if c.zone then
            -- World boss creatures carry multiple spawn zones as an array rather than a string.
            local z = type(c.zone) == "table" and table.concat(c.zone, ", ") or c.zone
            line = line .. "  —  " .. z
        end
        if c.rate then line = line .. "  |cffaaaaaa(" .. string.format("%.2f", c.rate) .. "%)|r" end
        dropLines[#dropLines + 1] = line
    end
    addSection("Drops from:", dropLines)

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

    return sections
end

-- Source sections (Sold by, Taught by, Drops from, etc.). Returns updated y.
function ACC.layoutSources(recipe, y)
    local sections       = buildSourceSections(recipe)
    local hdrIdx, lblIdx = 0, 0
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
        y = y - RDS.ROW_GAP
    end
    for i = hdrIdx + 1, RDS.MAX_SOURCE_HEADERS do RDS.sourceHeaders[i]:Hide() end
    for i = lblIdx + 1, RDS.MAX_SOURCE_LINES   do RDS.sourceLabels[i]:Hide()  end
    return y
end
