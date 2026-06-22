-- Tracker.lua — tracks which recipes each character knows across sessions.
-- Scans the spellbook and trade-skill window at login/open, then persists the result
-- in ACC_AccountData (SavedVariables) so WhoKnows queries work for all alts.

ACC_Tracker = {}

-- Keyed by recipe name (string), not spellId, because GetTradeSkillInfo only returns names.
local knownNames  = {}   -- { [recipeName] = true } for the current character
-- Set at PLAYER_LOGIN; used as the SavedVariables key and for sorting WhoKnows results.
local currentChar = nil

-- Scans every spellbook tab for known spells.  Profession recipes appear here
-- even before the player opens the trade-skill window, making this safe to run at login.
local function scanSpellbook()
    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, numSpells = GetSpellTabInfo(tab)
        for i = 1, numSpells do
            local _, id = GetSpellBookItemInfo(offset + i, "SPELL")
            if id then
                local name = GetSpellInfo(id)
                if name then knownNames[name] = true end
                -- Also store by our canonical recipe name so that any name mismatch
                -- between GetSpellInfo and our data (common for Enchanting) doesn't
                -- cause IsKnown to return false for known recipes.
                local recipe = ACC_DataManager.recipeById[id]
                if recipe then knownNames[recipe.name] = true end
            end
        end
    end
end

-- Writes knownNames into ACC_AccountData so it survives across sessions and is
-- visible to WhoKnows queries from other characters on the same account.
local function persist()
    if not ACC_AccountData then ACC_AccountData = {} end
    if not ACC_AccountData.characters then ACC_AccountData.characters = {} end
    ACC_AccountData.characters[currentChar] = knownNames
end

-- Supplements the spellbook scan with the open trade-skill window.
-- Catches newly-learned recipes that may not have propagated to the spellbook yet.
-- Resolves by spell ID so the canonical English name is stored regardless of client locale.
local function scanTradeSkill()
    for i = 1, GetNumTradeSkills() do
        local name, skillType = GetTradeSkillInfo(i)
        if name and skillType ~= "header" then
            local link = GetTradeSkillRecipeLink and GetTradeSkillRecipeLink(i)
            if link then
                local spellId = tonumber(link:match("enchant:(%d+)") or link:match("spell:(%d+)"))
                if spellId then
                    local recipe = ACC_DataManager.recipeById[spellId]
                    if recipe then
                        knownNames[recipe.name] = true
                    else
                        knownNames[name] = true
                    end
                else
                    knownNames[name] = true
                end
            else
                knownNames[name] = true
            end
        end
    end
    persist()
end

-- Enchanting in Classic ERA Vanilla uses CraftFrame (not TradeSkillFrame) and fires
-- CRAFT_SHOW / CRAFT_UPDATE instead of TRADE_SKILL_SHOW.  GetCraftRecipeLink returns
-- |Henchant:spellId| links, giving us the real spell ID to look up our canonical name.
local function scanCraft()
    for i = 1, GetNumCrafts() do
        local name = GetCraftInfo(i)
        if name then
            local link = GetCraftRecipeLink and GetCraftRecipeLink(i)
            if link then
                local spellId = tonumber(link:match("enchant:(%d+)"))
                if spellId then
                    local recipe = ACC_DataManager.recipeById[spellId]
                    if recipe then
                        knownNames[recipe.name] = true
                    else
                        knownNames[name] = true
                    end
                end
            else
                knownNames[name] = true
            end
        end
    end
    persist()
end

local trackerFrame = CreateFrame("Frame")
trackerFrame:RegisterEvent("PLAYER_LOGIN")
trackerFrame:RegisterEvent("TRADE_SKILL_SHOW")
trackerFrame:RegisterEvent("TRADE_SKILL_UPDATE")
trackerFrame:RegisterEvent("CRAFT_SHOW")
trackerFrame:RegisterEvent("CRAFT_UPDATE")
trackerFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        currentChar = UnitName("player")
        -- Load any data saved from previous sessions for this character.
        if ACC_AccountData and ACC_AccountData.characters
                and ACC_AccountData.characters[currentChar] then
            knownNames = ACC_AccountData.characters[currentChar]
        end
        -- Scan the spellbook — profession recipes are included in the standard tabs.
        scanSpellbook()
        persist()

    elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" then
        scanTradeSkill()

    elseif event == "CRAFT_SHOW" or event == "CRAFT_UPDATE" then
        -- Enchanting uses CraftFrame in Classic ERA and fires these events instead.
        scanCraft()
    end
end)

-- Returns true if the current character knows the recipe for the given spellId.
-- Looks up by name (not spellId) because that is what the spellbook/trade-skill scans store.
function ACC_Tracker.IsKnown(spellId)
    if not spellId then return false end
    -- Fast path: direct spell-ID check for the current session.
    -- Handles Enchanting and any other profession where GetSpellInfo names
    -- don't exactly match our recipe.name, without relying on name matching.
    if IsSpellKnown and IsSpellKnown(spellId) then return true end
    local recipe = ACC_DataManager.recipeById[spellId]
    if not recipe then return false end
    return knownNames[recipe.name] == true
end

-- Returns a sorted list of character names that know the given recipe.
-- The current character is always placed first; remaining names are alphabetical.
function ACC_Tracker.WhoKnows(spellId)
    if not spellId then return {} end
    local recipe = ACC_DataManager.recipeById[spellId]
    if not recipe then return {} end
    local recipeName = recipe.name
    if not ACC_AccountData or not ACC_AccountData.characters then return {} end

    local result = {}
    for charName, names in pairs(ACC_AccountData.characters) do
        if names[recipeName] then
            result[#result + 1] = charName
        end
    end

    table.sort(result, function(a, b)
        if a == currentChar then return true end
        if b == currentChar then return false end
        return a < b
    end)

    return result
end

-- Test-only hook — injects currentChar and knownNames without needing WoW events.
function ACC_Tracker._setTestState(char, known)
    currentChar = char
    knownNames = known
end

-- Appends known-status lines to a tooltip frame for the given spellId.
-- Shows "Known" (green) or "Not Known" (red) for the logged-in character,
-- then lists any other alts that know the recipe. The logged-in character is
-- excluded from the "Known on:" list since their status is already on the first line.
-- self:Show() is called at the end to force the tooltip to resize for the new lines.
local function appendKnownStatus(self, spellId)
    if ACC_Tracker.IsKnown(spellId) then
        self:AddLine("|cff00ff00Known|r")
    else
        self:AddLine("|cffff0000Not Known|r")
    end

    -- Build a list of OTHER characters that know this recipe (skip current char).
    local others = {}
    for _, name in ipairs(ACC_Tracker.WhoKnows(spellId)) do
        if name ~= currentChar then
            others[#others + 1] = name
        end
    end
    if #others > 0 then
        self:AddLine("|cff00ff00Known on: " .. table.concat(others, ", ") .. "|r")
    end

    -- Force tooltip resize so our new lines are not clipped.
    self:Show()
end

-- OnTooltipSetItem fires after WoW has fully populated the tooltip for any item,
-- regardless of where it came from (bags, AH, merchant, loot, chat links, etc.).
-- GetItem() returns the name and full hyperlink of whatever item is shown.
-- tooltipLastLink guards against double-firing (e.g. AH triggers the event twice
-- for recipe items — once for base info, once after adding the materials list).
local tooltipLastLink = {}

local function onTooltipSetItem(self)
    local _, link = self:GetItem()
    if not link or tooltipLastLink[self] == link then return end
    tooltipLastLink[self] = link
    local itemId = tonumber(link:match("item:(%d+)"))
    if not itemId then return end
    local spellId = ACC_DataManager.itemToSpell[itemId]
    if not spellId then return end
    appendKnownStatus(self, spellId)
end

local function onTooltipCleared(self)
    tooltipLastLink[self] = nil
end

GameTooltip:HookScript("OnTooltipSetItem", onTooltipSetItem)
GameTooltip:HookScript("OnTooltipCleared", onTooltipCleared)
ItemRefTooltip:HookScript("OnTooltipSetItem", onTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipCleared", onTooltipCleared)

-- Enchanting recipes link as |Henchant:spellId| in Classic ERA, not item links,
-- so OnTooltipSetItem never fires for them. Hook SetItemRef instead.
hooksecurefunc("SetItemRef", function(link)
    local spellId = tonumber(link:match("^enchant:(%d+)$"))
    if spellId and ItemRefTooltip:IsShown() then
        appendKnownStatus(ItemRefTooltip, spellId)
    end
end)

