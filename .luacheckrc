std = "lua51"

exclude_files = { "tests/luaunit.lua" }

globals = {
    "ACC", "AkistosCraftCompendium",
    "ACC_Data", "ACC_BrowserConfig", "ACC_BrowserState", "ACC_DataManager",
    "ACC_Tracker", "ACC_AccountData", "ACC_CharacterData",
    "SLASH_ACC1", "SlashCmdList",
    "StaticPopupDialogs",
}

read_globals = {
    "CreateFrame", "UIParent",
    "GameTooltip", "ItemRefTooltip",
    "GetItemInfo", "GetSpellInfo",
    "GetNumSpellTabs", "GetSpellTabInfo", "GetSpellBookItemInfo",
    "GetNumTradeSkills", "GetTradeSkillInfo",
    "GetNumSkillLines", "GetSkillLineInfo",
    "UnitName", "UnitFactionGroup",
    "hooksecurefunc",
    "UIDropDownMenu_Initialize", "UIDropDownMenu_AddButton", "UIDropDownMenu_SetText",
    "IsShiftKeyDown", "ChatEdit_InsertLink", "DEFAULT_CHAT_FRAME",
    "StaticPopup_Show",
}

files["tests/test_tracker.lua"] = {
    globals = {
        "luaunit", "TestTracker",
        "CreateFrame", "hooksecurefunc", "GameTooltip", "ItemRefTooltip",
    }
}

files["Model/data"] = { max_line_length = false }
files["View/ui"] = { max_line_length = false }
