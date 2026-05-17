std = "lua51"

globals = {
    "ACC", "AkistosCraftCompendium",
    "ACC_Data", "ACC_BrowserConfig", "ACC_DataManager",
    "ACC_Tracker", "ACC_AccountData", "ACC_CharacterData",
    "SLASH_ACC1", "SlashCmdList",
}

read_globals = {
    "CreateFrame", "UIParent",
    "GameTooltip", "ItemRefTooltip",
    "GetItemInfo", "GetSpellInfo",
    "GetNumSpellTabs", "GetSpellTabInfo", "GetSpellBookItemInfo",
    "GetNumTradeSkills", "GetTradeSkillInfo",
    "UnitName", "UnitFactionGroup",
    "hooksecurefunc",
    "UIDropDownMenu_Initialize", "UIDropDownMenu_AddButton", "UIDropDownMenu_SetText",
    "IsShiftKeyDown", "ChatEdit_InsertLink", "DEFAULT_CHAT_FRAME",
}

files["Model/data"] = { max_line_length = false }
files["View/ui"] = { max_line_length = false }
