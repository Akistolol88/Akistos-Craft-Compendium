-- BrowserConfig.lua — static lookup tables for the Browser UI.
-- All tables are stored under ACC_BrowserConfig so Browser.lua can alias them as
-- locals without polluting the global namespace with individual table names.

ACC_BrowserConfig = {}

-- Fixed category display order for specific professions.
-- Only categories that actually have at least one recipe are shown.
ACC_BrowserConfig.professionCategoryOrder = {
    Engineering = {
        "Helm", "Armor", "Trinket", "Guns",
        "---",
        "Door Explosive", "Dummies", "Explosives",
        "---",
        "Bullets", "Scopes",
        "---",
        "Parts", "Fireworks", "Pets", "Misc",
    },
    Enchanting = {
        "Chest", "Cloak", "Gloves", "Boots", "Bracer",
        "Weapon", "2H Weapon", "Shield",
        "---",
        "Oils", "Wands", "Rods", "Misc",
    },
    Alchemy = {
        "Flasks",
        "Offensive Elixirs", "Defensive Elixirs",
        "Healing/Mana Potions", "Protection Potions",
        "Utility Elixirs",
        "Transmute",
        "---",
        "Oils", "Misc",
    },
    Leatherworking = {
        "Helm", "Shoulders", "Cloak", "Chest", "Gloves", "Belt", "Legs", "Boots", "Bracers",
        "---",
        "Quivers & Pouches", "Armorkits", "Skins", "Misc",
        "---",
        "Fire Resistance", "Nature Resistance", "Frost Resistance",
    },
    Blacksmithing = {
        "Helm", "Shoulders", "Chest", "Gloves", "Belt", "Legs", "Boots", "Bracers",
        "Shield",
        "One-Hand",
        "Mainhand",
        "Two-Hand",
        "Rods",
        "Enhancements",
        "Sharpening Stones",
        "Keys",
        "Misc",
        "Fire Resistance", "Shadow Resistance", "Frost Resistance", "Nature Resistance",
    },
    Mining = {
        "Veins",
        "---",
        "Smelting",
        "---",
        "Misc",
    },
    Herbalism = {
        "Herbs",
        "---",
        "Misc",
    },
    Skinning = {
        "Formula",
        "---",
        "Misc",
    },
    Fishing = {
        "Fish",
        "---",
        "Zones",
        "---",
        "Poles",
        "Lures",
        "Tournament",
        "---",
        "Misc",
    },
    ["First Aid"] = {
        "Bandages",
        "---",
        "Misc",
    },
    Cooking = {
        "Stamina",
        "Stats",
        "Health / Mana",
        "---",
        "Misc",
    },
}

-- Sort order for subCategory within a category (lower = first).
-- Items without a subCategory sort last (order 99).
ACC_BrowserConfig.subCategoryOrder = {
    -- Weapon types
    Swords              = 1,
    Maces               = 2,
    Axes                = 3,
    Daggers             = 4,
    Polearms            = 5,
    -- Stone types
    ["Sharpening Stones"] = 1,
    Weightstones          = 2,
    ["Grinding Stones"]   = 3,
    -- Enhancement types
    ["Shield Spikes"]     = 1,
    -- Enchanting oil types
    ["Spell Damage"]      = 1,
    ["Mana"]              = 2,
}

-- Default category assigned when a profession's crafted items have no equipment slot
-- (e.g. First Aid bandages return INVTYPE_NON_EQUIP / "").
ACC_BrowserConfig.professionDefaultCategory = {
    ["Cooking"]   = "Health / Mana",
    ["First Aid"] = "Bandages",
}

-- Fallback icon used when a recipe has no formula item and creates nothing with an icon.
-- Used for Enchanting enchants (no scroll) and all rank-up training entries (50/125/200).
ACC_BrowserConfig.profFallbackIcon = {
    Alchemy        = "Interface\\Icons\\trade_alchemy",
    Blacksmithing  = "Interface\\Icons\\trade_blacksmithing",
    Cooking        = "Interface\\Icons\\inv_misc_food_15",
    Enchanting     = "Interface\\Icons\\trade_engraving",
    Engineering    = "Interface\\Icons\\trade_engineering",
    ["First Aid"]  = "Interface\\Icons\\spell_holy_sealofsacrifice",
    Fishing        = "Interface\\Icons\\trade_fishing",
    Herbalism      = "Interface\\Icons\\trade_herbalism",
    Leatherworking = "Interface\\Icons\\trade_leatherworking",
    Mining         = "Interface\\Icons\\trade_mining",
    Skinning       = "Interface\\Icons\\inv_misc_pelt_wolf_01",
    Tailoring      = "Interface\\Icons\\trade_tailoring",
}

-- Maps WoW INVTYPE_* constants to the display category shown in the panel.
-- INVTYPE_ROBE is a chest-slot robe, so it shares the "Chest" category with INVTYPE_CHEST.
ACC_BrowserConfig.slotCategory = {
    INVTYPE_HEAD           = "Helm",
    INVTYPE_SHOULDER       = "Shoulders",
    INVTYPE_BODY           = "Shirt",
    INVTYPE_CHEST          = "Chest",
    INVTYPE_ROBE           = "Chest",
    INVTYPE_WAIST          = "Belt",
    INVTYPE_LEGS           = "Legs",
    INVTYPE_FEET           = "Boots",
    INVTYPE_WRIST          = "Bracers",
    INVTYPE_HAND           = "Gloves",
    INVTYPE_TRINKET        = "Trinket",
    INVTYPE_BACK           = "Cloak",
    INVTYPE_WEAPON         = "One-Hand",
    INVTYPE_SHIELD         = "Shield",
    INVTYPE_2HWEAPON       = "Two-Hand",
    INVTYPE_WEAPONMAINHAND = "Mainhand",
    INVTYPE_WEAPONOFFHAND  = "Offhand(Weapon)",
    INVTYPE_HOLDABLE       = "Offhand",
    INVTYPE_RANGED         = "Ranged",
    INVTYPE_RANGEDRIGHT    = "Wand",
    INVTYPE_THROWN         = "Thrown",
    INVTYPE_BAG            = "Bags",
    INVTYPE_QUIVER         = "Quiver",
    INVTYPE_TABARD         = "Tabard",
}

-- Mutable browser state shared between Browser.lua and BrowserRender.lua.
-- Initialised here so both files can alias it with `local S = ACC_BrowserState` at load time.
ACC_BrowserState = {
    mainFrame       = nil,
    categoryFrame   = nil,
    pageLabel       = nil,
    prevButton      = nil,
    nextButton      = nil,
    rowButtons      = {},
    categoryButtons = {},
    recipeList      = {},
    pageIndex       = 1,
    activeCategory  = nil,
    currentProfName = nil,
    pendingByItemId = {},
}
