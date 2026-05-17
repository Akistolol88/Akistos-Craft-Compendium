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
            end
        end
    end
end

-- Supplements the spellbook scan with the open trade-skill window.
-- Catches newly-learned recipes that may not have propagated to the spellbook yet.
local function scanTradeSkill()
    for i = 1, GetNumTradeSkills() do
        local name, skillType = GetTradeSkillInfo(i)
        if name and skillType ~= "header" then
            knownNames[name] = true
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

local trackerFrame = CreateFrame("Frame")
trackerFrame:RegisterEvent("PLAYER_LOGIN")
trackerFrame:RegisterEvent("TRADE_SKILL_SHOW")
trackerFrame:RegisterEvent("TRADE_SKILL_UPDATE")
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
        -- Extra scan when a profession window is opened; catches anything the spellbook missed.
        scanTradeSkill()
        persist()
    end
end)

-- Returns true if the current character knows the recipe for the given spellId.
-- Looks up by name (not spellId) because that is what the spellbook/trade-skill scans store.
function ACC_Tracker.IsKnown(spellId)
    if not spellId then return false end
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

-- When an item isn't in the client cache, WoW fills the tooltip asynchronously after
-- SetHyperlink returns, wiping any lines we added in the hook. Deferring one frame
-- ensures the tooltip is fully settled before we append our known-status lines.
local pendingTooltip = nil  -- tooltip frame waiting for known-status lines
local pendingSpellId = nil  -- spellId for the pending tooltip

-- Hidden frame used purely as a one-frame timer via OnUpdate.
local tooltipDeferFrame = CreateFrame("Frame")
tooltipDeferFrame:Hide()
tooltipDeferFrame:SetScript("OnUpdate", function(self)
    -- Disable immediately so this only fires once per queued tooltip.
    self:Hide()
    -- Only append if the tooltip is still visible; user may have moved the mouse away.
    if pendingTooltip and pendingSpellId and pendingTooltip:IsShown() then
        appendKnownStatus(pendingTooltip, pendingSpellId)
    end
    pendingTooltip = nil
    pendingSpellId = nil
end)

-- Hooks SetHyperlink on a tooltip frame to inject known-status lines for recipe items.
-- Clicking a chat hyperlink shows ItemRefTooltip; hovering in-world uses GameTooltip —
-- both frames need the same hook so the feature works in either context.
local function hookTooltipFrame(frame)
    hooksecurefunc(frame, "SetHyperlink", function(self, link)
        -- Extract the numeric item ID from the hyperlink (e.g. "item:14043:0:0:...").
        local itemId = tonumber(link:match("item:(%d+)"))
        if not itemId then return end
        -- itemToSpell maps recipe item IDs to the spell they teach; non-recipe items return nil.
        local spellId = ACC_DataManager.itemToSpell[itemId]
        if not spellId then return end
        -- Queue the append for next frame rather than running immediately,
        -- so WoW has time to finish populating the tooltip with item data.
        pendingTooltip = self
        pendingSpellId = spellId
        tooltipDeferFrame:Show()
    end)
end

hookTooltipFrame(GameTooltip)
hookTooltipFrame(ItemRefTooltip)

