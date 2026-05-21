-- BrowserHelpers.lua — stateless UI helper functions for the browser.
-- makeSpellLink is also consumed by RecipeDetail.lua so it lives here rather than
-- buried inside Browser.lua where it would be harder to find.

-- Builds a clickable spell hyperlink string for use in tooltips and chat.
function ACC.makeSpellLink(recipe)
    if not recipe.spellId then
        return "|cffffd700[" .. (recipe.name or "???") .. "]|r"
    end
    return "|cff71d5ff|Hspell:" .. recipe.spellId .. "|h[" .. recipe.name .. "]|h|r"
end

-- Populates an already-owned GameTooltip with gathering-node info.
-- Handles three node types — vein, herb, and smelt — via the recipe's _vein/_herb/_smelt fields.
function ACC.showGatheringTooltip(recipe)
    local vein  = recipe._vein
    local herb  = recipe._herb
    local smelt = recipe._smelt
    local c     = recipe.colors

    -- Adds the four skill-difficulty colours: orange=hard, yellow=medium, green=easy, grey=trivial.
    local function addColorLine()
        if not c then return end
        GameTooltip:AddLine(
            "|cffff8000" .. (c[1] or "?") .. "|r  " ..
            "|cffffff00" .. (c[2] or "?") .. "|r  " ..
            "|cff40ff40" .. (c[3] or "?") .. "|r  " ..
            "|cff808080" .. (c[4] or "?") .. "|r",
            1, 1, 1
        )
    end

    if vein then
        GameTooltip:SetText(vein.name, 1, 1, 1)
        addColorLine()
        if vein.note then GameTooltip:AddLine(vein.note, 1, 0.82, 0, true) end
        GameTooltip:AddLine("Taps per node: " .. (vein.taps or "2-4"), 0.9, 0.9, 0.9)
        if vein.ore and #vein.ore > 0 then
            GameTooltip:AddLine("Drops:", 1, 1, 0)
            for _, drop in ipairs(vein.ore) do
                GameTooltip:AddLine("  " .. drop.name, 1, 1, 1)
            end
        end
        if vein.gems and #vein.gems > 0 then
            GameTooltip:AddLine("Possible Gems:", 1, 1, 0)
            for _, gem in ipairs(vein.gems) do
                GameTooltip:AddLine("  " .. gem.name .. " (" .. gem.rate .. "%)", 0.8, 0.8, 0.8)
            end
        end
        if vein.zones and #vein.zones > 0 then
            GameTooltip:AddLine("Found in:", 1, 1, 0)
            GameTooltip:AddLine(table.concat(vein.zones, ", "), 0.7, 0.7, 0.7, true)
        end
    elseif herb then
        GameTooltip:SetText(herb.name, 1, 1, 1)
        if not herb.noColors then addColorLine() end
        if herb.terrain then GameTooltip:AddLine(herb.terrain, 0.9, 0.9, 0.9, true) end
        if herb.note    then GameTooltip:AddLine(herb.note,    1,   0.82, 0,   true) end
        if herb.zones and #herb.zones > 0 then
            GameTooltip:AddLine("Found in:", 1, 1, 0)
            GameTooltip:AddLine(table.concat(herb.zones, ", "), 0.7, 0.7, 0.7, true)
        end
    elseif smelt then
        GameTooltip:SetText(smelt.name, 1, 1, 1)
        addColorLine()
        if smelt.creates then
            GameTooltip:AddLine("Creates: " .. smelt.creates.name .. " x" .. smelt.creates.count, 0.9, 0.9, 0.9)
        end
        if smelt.reagents and #smelt.reagents > 0 then
            GameTooltip:AddLine("Requires:", 1, 1, 0)
            for _, r in ipairs(smelt.reagents) do
                GameTooltip:AddLine("  " .. r.name .. " x" .. r.count, 1, 1, 1)
            end
        end
    end
    GameTooltip:Show()
end
