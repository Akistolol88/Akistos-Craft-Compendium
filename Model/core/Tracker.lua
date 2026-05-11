ACC_Tracker = {}

local knownNames  = {}   -- { [recipeName] = true } for the current character
local currentChar = nil

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

local function scanTradeSkill()
    for i = 1, GetNumTradeSkills() do
        local name, skillType = GetTradeSkillInfo(i)
        if name and skillType ~= "header" then
            knownNames[name] = true
        end
    end
end

local function persist()
    if not ACC_AccountData then ACC_AccountData = {} end
    if not ACC_AccountData.characters then ACC_AccountData.characters = {} end
    ACC_AccountData.characters[currentChar] = knownNames
end

local trackerFrame = CreateFrame("Frame")
trackerFrame:RegisterEvent("PLAYER_LOGIN")
trackerFrame:RegisterEvent("TRADE_SKILL_SHOW")
trackerFrame:RegisterEvent("TRADE_SKILL_UPDATE")
trackerFrame:SetScript("OnEvent", function(self, event)
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

function ACC_Tracker.IsKnown(spellId)
    if not spellId then return false end
    local recipe = ACC_DataManager.recipeById[spellId]
    if not recipe then return false end
    return knownNames[recipe.name] == true
end

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
