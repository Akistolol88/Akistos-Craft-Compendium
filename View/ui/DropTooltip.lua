-- DropTooltip.lua — adds "can drop this recipe" lines to the tooltip of a creature.
-- Hovering a mob (in the world or on its nameplate) lists the recipes it drops according
-- to the recipe data, with the drop chance. Never shown in combat.
-- Toggle with /acc drops; the choice persists in ACC_AccountData.

-- Most recipes listed for one creature before the rest is summarised as "... and N more".
local LINE_LIMIT = 6

-- dropsByCreature[creature name] = { { recipe, profession, rate }, ... }, best drop rate first.
local dropsByCreature

local function buildDropIndex()
    dropsByCreature = {}
    for profession, recipes in pairs(ACC_Data) do
        for _, recipe in ipairs(recipes) do
            for _, src in ipairs(recipe.sources or {}) do
                if src.type == "drop" and src.creatures then
                    for _, creature in ipairs(src.creatures) do
                        local list = dropsByCreature[creature.name]
                        if not list then
                            list = {}
                            dropsByCreature[creature.name] = list
                        end
                        list[#list + 1] = { recipe = recipe, profession = profession, rate = creature.rate }
                    end
                end
            end
        end
    end
    for _, list in pairs(dropsByCreature) do
        table.sort(list, function(a, b) return (a.rate or 0) > (b.rate or 0) end)
    end
end

local function dropTooltipsEnabled()
    return not (ACC_AccountData and ACC_AccountData.dropTooltipsHidden)
end

local function onTooltipSetUnit(tooltip)
    if not dropTooltipsEnabled() then return end
    -- Never in combat, whatever the setting: tooltips should stay short while fighting.
    if InCombatLockdown() then return end

    local name, unit = tooltip:GetUnit()
    if not name or (unit and UnitIsPlayer(unit)) then return end

    -- Built on first use so it never slows down login.
    if not dropsByCreature then buildDropIndex() end
    local drops = dropsByCreature[name]
    if not drops then return end

    tooltip:AddLine(" ")
    tooltip:AddLine("Recipe drops:", 1, 0.82, 0)
    for i, drop in ipairs(drops) do
        if i > LINE_LIMIT then
            tooltip:AddLine("... and " .. (#drops - LINE_LIMIT) .. " more", 0.7, 0.7, 0.7)
            break
        end
        local recipe = drop.recipe
        local left = (recipe.recipeItemName or recipe.name or "?") .. " |cff888888(" .. drop.profession .. ")|r"
        local right = drop.rate and string.format("%.2f%%", drop.rate) or ""
        -- Recipes this character already knows are greyed out.
        local known = recipe.spellId and ACC_Tracker.IsKnown(recipe.spellId)
        local shade = known and 0.5 or 1
        tooltip:AddDoubleLine(left, right, shade, shade, shade, 0.7, 0.7, 0.7)
    end
    tooltip:Show()
end

GameTooltip:HookScript("OnTooltipSetUnit", onTooltipSetUnit)

-- Called by /acc drops.
function ACC.toggleDropTooltips()
    ACC_AccountData = ACC_AccountData or {}
    ACC_AccountData.dropTooltipsHidden = not ACC_AccountData.dropTooltipsHidden
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffACC:|r Recipe drops in creature tooltips "
        .. (dropTooltipsEnabled() and "shown" or "hidden") .. ". Type |cffffffff/acc drops|r to toggle.")
end
