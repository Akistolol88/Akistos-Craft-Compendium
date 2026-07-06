std = "lua51"

exclude_files = { "tests/luaunit.lua" }

globals = {
    "ACC", "AkistosCraftCompendium",
    "ACC_Data", "ACC_BrowserConfig", "ACC_BrowserState", "ACC_DataManager",
    "ACC_RecipeDetailState",
    "ACC_Tracker", "ACC_AccountData", "ACC_CharacterData",
    "SLASH_ACC1", "SlashCmdList",
    "StaticPopupDialogs",
    -- TradeSkillFilter replaces these globals temporarily during filtered renders
    "GetNumTradeSkills", "GetTradeSkillInfo",
    "GetNumCrafts", "GetCraftInfo",
    "TradeSkillFrame_Update", "CraftFrame_Update",
}

read_globals = {
    "CreateFrame", "UIParent",
    "GameTooltip", "ItemRefTooltip",
    "GetItemInfo", "GetSpellInfo",
    "GetNumSpellTabs", "GetSpellTabInfo", "GetSpellBookItemInfo",
    "GetTradeSkillRecipeLink",
    "GetCraftRecipeLink",
    "IsSpellKnown",
    "GetTradeSkillLine",
    "GetNumSkillLines", "GetSkillLineInfo",
    "TradeSkillFrame", "CraftFrame",
    "TradeSkillListScrollFrame", "CraftListScrollFrame",
    "TradeSkillHighlightFrame",
    "GetTradeSkillSelectionIndex",
    "TRADE_SKILLS_DISPLAYED", "TRADE_SKILL_HEIGHT",
    "CRAFTS_DISPLAYED",
    "FauxScrollFrame_GetOffset", "FauxScrollFrame_Update",
    "FauxScrollFrame_OnVerticalScroll", "FauxScrollFrame_SetOffset",
    "UnitName", "UnitFactionGroup",
    "hooksecurefunc",
    "UIDropDownMenu_Initialize", "UIDropDownMenu_AddButton", "UIDropDownMenu_SetText",
    "UIDropDownMenu_CreateInfo", "UIDROPDOWNMENU_OPEN_MENU",
    "ToggleDropDownMenu", "CloseDropDownMenus",
    "IsShiftKeyDown", "ChatEdit_InsertLink", "DEFAULT_CHAT_FRAME",
    "StaticPopup_Show",
    "Minimap", "GetCursorPosition",
    "tinsert", "UISpecialFrames",
}

files["tests/test_tracker.lua"] = {
    globals = {
        "luaunit", "TestTracker",
        "CreateFrame", "hooksecurefunc", "GameTooltip", "ItemRefTooltip",
    }
}

files["Model/data"] = { max_line_length = false }
files["View/ui"] = { max_line_length = false }
