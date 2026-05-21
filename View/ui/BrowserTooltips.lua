-- BrowserTooltips.lua — hover tooltip rendering for every row entry type.
-- ACC.showHoverTooltip(recipe) is called from the OnEnter script in Browser.lua.

-- Populates an already-owned GameTooltip for fishing items (poles, lures, tournament rewards).
local function showFishingItemTooltip(r)
    if r.recipeItemId then
        GameTooltip:SetHyperlink("item:" .. r.recipeItemId)
    else
        GameTooltip:SetText(r.name, 1, 1, 1)
    end
    for _, src in ipairs(r.sources or {}) do
        if src.type == "quest" and src.quests and src.quests[1] then
            local q = src.quests[1]
            local qName = "|cffffff00[" .. (q.name or "Quest") .. "]|r"
            GameTooltip:AddLine("From quest: " .. qName, 1, 1, 1)
            if     q.faction == "alliance" then GameTooltip:AddLine("Alliance only", 0.41, 0.80, 0.94)
            elseif q.faction == "horde"    then GameTooltip:AddLine("Horde only",    0.94, 0.41, 0.41) end
        elseif src.type == "vendor" and src.vendors and src.vendors[1] then
            GameTooltip:AddLine("Sold by: " .. src.vendors[1].name, 0.8, 0.8, 0.8)
        elseif src.type == "container" and src.containers and src.containers[1] then
            local c = src.containers[1]
            local line = "Found in: " .. c.name .. "  —  " .. (c.zone or "")
            if c.rate then line = line .. string.format("  (%.2f%%)", c.rate) end
            GameTooltip:AddLine(line, 0.8, 0.8, 0.8)
        elseif src.type == "craft" then
            GameTooltip:AddLine("Crafted by " .. (src.prof or "profession"), 0.8, 0.8, 0.8)
        elseif src.type == "note" then
            GameTooltip:AddLine(src.text or "", 0.8, 0.8, 0.8, true)
        end
    end
    GameTooltip:AddLine("Click for details  •  Shift-click to link", 0, 1, 0)
    GameTooltip:Show()
end

-- Dispatches tooltip rendering for a recipe row. Caller is responsible for
-- SetOwner + SetPoint before calling this; this function only fills in the content.
function ACC.showHoverTooltip(recipe)
    if recipe._vein or recipe._herb then
        ACC.showGatheringTooltip(recipe)
    elseif recipe._smelt then
        GameTooltip:SetHyperlink(ACC.makeSpellLink(recipe))
        local c = recipe.colors
        if c then
            GameTooltip:AddLine(
                "|cffff8000" .. (c[1] or "?") .. "|r  " ..
                "|cffffff00" .. (c[2] or "?") .. "|r  " ..
                "|cff40ff40" .. (c[3] or "?") .. "|r  " ..
                "|cff808080" .. (c[4] or "?") .. "|r",
                1, 1, 1
            )
        end
        local smelt = recipe._smelt
        if smelt.creates then
            GameTooltip:AddLine("Creates: " .. smelt.creates.name .. " x" .. smelt.creates.count, 0.9, 0.9, 0.9)
        end
        if smelt.reagents and #smelt.reagents > 0 then
            GameTooltip:AddLine("Requires:", 1, 1, 0)
            for _, r in ipairs(smelt.reagents) do
                GameTooltip:AddLine("  " .. r.name .. " x" .. r.count, 1, 1, 1)
            end
        end
        if smelt.tribute and #smelt.tribute > 0 then
            GameTooltip:AddLine("Tribute:", 1, 1, 0)
            for _, t in ipairs(smelt.tribute) do
                GameTooltip:AddLine("  " .. t.name .. " x" .. t.count, 1, 1, 1)
            end
        end
        if smelt.quest and smelt.questId then
            local level = smelt.questLevel or 60
            local questLink = "|cffffff00|Hquest:" .. smelt.questId .. ":" .. level .. "|h[" .. smelt.quest .. "]|h|r"
            GameTooltip:AddLine("Quest: " .. questLink, 1, 1, 1)
        end
        if smelt.note then
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine(smelt.note, 0.8, 0.8, 0.8, true)
        end
        GameTooltip:Show()
    elseif recipe._book then
        local bookLabel = recipe.bookName
        if recipe.bookItemId then
            local _, link = GetItemInfo(recipe.bookItemId)
            if link then bookLabel = link end
        end
        GameTooltip:SetText(recipe.name, 1, 0.82, 0)
        GameTooltip:AddLine("Requires: " .. bookLabel, 1, 1, 1)
        if #recipe.vendors > 0 then
            GameTooltip:AddLine("Sold by:", 1, 1, 0)
            for _, v in ipairs(recipe.vendors) do
                local vr, vg, vb = 1, 1, 1
                if     v.faction == "alliance" then vr, vg, vb = 0.41, 0.80, 0.94
                elseif v.faction == "horde"    then vr, vg, vb = 0.94, 0.41, 0.41 end
                GameTooltip:AddLine("  " .. v.name .. "  —  " .. (v.zone or ""), vr, vg, vb)
            end
        end
        GameTooltip:AddLine("Shift-click to link in chat", 0, 1, 0)
        GameTooltip:Show()
    elseif recipe._quest then
        GameTooltip:SetText(recipe.name, 1, 0.82, 0)
        if #recipe.questGivers > 0 then
            GameTooltip:AddLine("Quest giver:", 1, 1, 0)
            for _, q in ipairs(recipe.questGivers) do
                local qr, qg, qb = 1, 1, 1
                if     q.faction == "alliance" then qr, qg, qb = 0.41, 0.80, 0.94
                elseif q.faction == "horde"    then qr, qg, qb = 0.94, 0.41, 0.41 end
                local qId = q.questId or recipe.questId
                local level = recipe.questLevel or 60
                local suffix = qId and ("  |cffffff00|Hquest:" .. qId .. ":" .. level .. "|h[" .. (recipe.questName or "Quest") .. "]|h|r") or ""
                GameTooltip:AddLine("  " .. q.name .. "  —  " .. (q.zone or "") .. suffix, qr, qg, qb)
            end
        else
            local qLabel = recipe.questName or "Quest"
            if recipe.questId then
                local level = recipe.questLevel or 60
                qLabel = "|cffffff00|Hquest:" .. recipe.questId .. ":" .. level .. "|h[" .. qLabel .. "]|h|r"
            end
            GameTooltip:AddLine("Learned from: " .. qLabel, 1, 1, 1)
        end
        if recipe.questFish and #recipe.questFish > 0 then
            GameTooltip:AddLine("Required fish:", 1, 1, 0)
            for _, f in ipairs(recipe.questFish) do
                GameTooltip:AddLine("  " .. f.name .. "  —  " .. f.zone .. "  (" .. f.coords .. ")", 1, 1, 1)
                GameTooltip:AddLine("    " .. f.area, 0.7, 0.7, 0.7)
            end
        end
        if recipe.note then
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine(recipe.note, 0.8, 0.8, 0.8, true)
        end
        GameTooltip:AddLine("Shift-click to show quest link in chat", 0, 1, 0)
        GameTooltip:Show()
    elseif recipe._zone then
        GameTooltip:SetText(recipe.name, 1, 1, 1)
        GameTooltip:AddLine("Minimum to cast:     " .. (recipe.minCast   or "?"), 1, 1, 1)
        GameTooltip:AddLine("Guaranteed catch:  " .. (recipe.guaranteed or "?"), 0.4, 1, 0.4)
        GameTooltip:Show()
    elseif recipe._fishingItem then
        showFishingItemTooltip(recipe)
    elseif recipe._train then
        GameTooltip:SetText(recipe.name, 1, 1, 1)
        local trainers = recipe.trainers
        if trainers and #trainers > 0 then
            GameTooltip:AddLine("Trainers:", 1, 1, 0)
            for _, t in ipairs(trainers) do
                local tr, tg, tb = 1, 1, 1
                if     t.faction == "alliance" then tr, tg, tb = 0.41, 0.80, 0.94
                elseif t.faction == "horde"    then tr, tg, tb = 0.94, 0.41, 0.41 end
                GameTooltip:AddLine("  " .. t.name .. "  —  " .. (t.zone or ""), tr, tg, tb)
            end
        end
        GameTooltip:Show()
    else
        GameTooltip:SetHyperlink(ACC.makeSpellLink(recipe))
        local reagents = recipe.reagents or {}
        if #reagents > 0 then
            GameTooltip:AddLine("Materials:", 1, 1, 0)
            for _, r in ipairs(reagents) do
                local name = GetItemInfo(r.id) or ("|cffffff00[" .. r.id .. "]|r")
                GameTooltip:AddLine("  " .. name .. " x" .. r.count, 1, 1, 1)
            end
        end
        -- Loop all sources and display each type.
        local dropCreatures  = {}
        local containerItems = {}
        local miscLines      = {}
        for _, src in ipairs(recipe.sources or {}) do
            if src.type == "vendor" and src.vendors then
                GameTooltip:AddLine("Sold by:", 1, 1, 0)
                if src.reputation then
                    GameTooltip:AddLine("  |cffffff00" .. src.reputation.faction .. " — " .. src.reputation.level .. " required|r", 1, 1, 1)
                end
                for _, v in ipairs(src.vendors) do
                    local vr, vg, vb = 1, 1, 1
                    if     v.faction == "alliance" then vr, vg, vb = 0.41, 0.80, 0.94
                    elseif v.faction == "horde"    then vr, vg, vb = 0.94, 0.41, 0.41 end
                    GameTooltip:AddLine("  " .. v.name .. "  —  " .. (v.zone or ""), vr, vg, vb)
                end
            elseif src.type == "trainer" and src.trainers then
                GameTooltip:AddLine("Taught by trainer:", 1, 1, 0)
                for _, t in ipairs(src.trainers) do
                    local vr, vg, vb = 1, 1, 1
                    if     t.faction == "alliance" then vr, vg, vb = 0.41, 0.80, 0.94
                    elseif t.faction == "horde"    then vr, vg, vb = 0.94, 0.41, 0.41 end
                    GameTooltip:AddLine("  " .. t.name .. "  —  " .. (t.zone or ""), vr, vg, vb)
                end
            elseif src.type == "npc" and src.npcs then
                GameTooltip:AddLine("Taught by:", 1, 1, 0)
                for _, n in ipairs(src.npcs) do
                    GameTooltip:AddLine("  " .. n.name .. "  —  " .. (n.zone or ""), 1, 1, 1)
                end
            elseif src.type == "drop" and src.creatures then
                for _, c in ipairs(src.creatures) do dropCreatures[#dropCreatures + 1] = c end
            elseif (src.type == "chest" or src.type == "lockbox" or src.type == "other" or src.type == "decoded") and src.containers then
                for _, c in ipairs(src.containers) do containerItems[#containerItems + 1] = c end
            elseif src.type == "world_drop" then
                local line = "World drop"
                if src.level_range then
                    line = line .. "  (level " .. src.level_range[1] .. "–" .. src.level_range[2] .. ")"
                end
                miscLines[#miscLines + 1] = line
            elseif src.type == "holiday" then
                miscLines[#miscLines + 1] = "Holiday: " .. (src.event or "")
            elseif src.type == "object" then
                miscLines[#miscLines + 1] = "Clickable object" .. (src.zone and ("  —  " .. src.zone) or "")
            elseif src.type == "quest" and src.quests then
                for _, q in ipairs(src.quests) do
                    local line = "Quest reward: " .. q.name
                    if q.faction then line = line .. "  |cffaaaaaa(" .. q.faction .. ")|r" end
                    miscLines[#miscLines + 1] = line
                end
            end
        end
        -- Drops sorted by rate, capped at 4 on hover (RecipeDetail shows up to 8).
        table.sort(dropCreatures, function(a, b) return (a.rate or 0) > (b.rate or 0) end)
        if #dropCreatures > 0 then
            GameTooltip:AddLine("Drops from:", 1, 1, 0)
            local dropCount = 0
            for _, c in ipairs(dropCreatures) do
                dropCount = dropCount + 1
                if dropCount > 4 then break end
                local line = "  " .. c.name
                if c.zone then
                    -- World boss creatures carry multiple spawn zones as an array rather than a string.
                    local z = type(c.zone) == "table" and table.concat(c.zone, ", ") or c.zone
                    line = line .. "  —  " .. z
                end
                if c.rate then line = line .. " (" .. string.format("%.2f", c.rate) .. "%)" end
                GameTooltip:AddLine(line, 1, 1, 1)
            end
            if #dropCreatures > 4 then
                GameTooltip:AddLine("  |cffaaaaaa… click for full list|r", 1, 1, 1)
            end
        end
        -- Container sources sorted by rate, capped at 4 on hover.
        table.sort(containerItems, function(a, b) return (a.rate or 0) > (b.rate or 0) end)
        if #containerItems > 0 then
            GameTooltip:AddLine("Found in:", 1, 1, 0)
            local containerCount = 0
            for _, c in ipairs(containerItems) do
                containerCount = containerCount + 1
                if containerCount > 4 then break end
                local line = "  " .. c.name
                if c.rate then line = line .. " (" .. string.format("%.2f", c.rate) .. "%)" end
                GameTooltip:AddLine(line, 1, 1, 1)
            end
            if #containerItems > 4 then
                GameTooltip:AddLine("  |cffaaaaaa… click for full list|r", 1, 1, 1)
            end
        end
        -- Misc: world drop, holiday, clickable object, quest reward.
        for _, line in ipairs(miscLines) do
            GameTooltip:AddLine(line, 1, 0.82, 0)
        end
        GameTooltip:Show()
    end
end
