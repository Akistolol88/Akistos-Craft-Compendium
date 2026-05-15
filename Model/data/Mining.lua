-- Mining vein data for WoW Classic (1.12)
-- colors = { orange_start, yellow_start, green_start, grey_start }
-- taps   = how many times the node can be mined before depleting
-- rate   = drop chance per node (%) — Classic ERA, All phases

ACC_Data = ACC_Data or {}
ACC_Data.Mining = {

    {
        name   = "Copper Vein",
        icon   = "inv_ore_copper_01",
        colors = { 1, 25, 50, 100 },
        taps   = "2-4",
        ore    = {
            { name = "Copper Ore",  rate = 100.0 },
        },
        stone  = {
            { name = "Rough Stone", rate = 44.0 },
        },
        gems   = {
            { name = "Malachite",   rate = 1.0 },
            { name = "Tigerseye",   rate = 1.0 },
            { name = "Shadowgem",   rate = 1.0 },
        },
        zones  = {
            "Darkshore", "Dun Morogh", "Durotar", "Elwynn Forest",
            "Loch Modan", "Mulgore", "Redridge Mountains", "Silverpine Forest",
            "Stonetalon Mountains", "Teldrassil", "The Barrens",
            "Tirisfal Glades", "Westfall",
        },
    },

    {
        name   = "Tin Vein",
        icon   = "inv_ore_tin_01",
        colors = { 65, 90, 115, 165 },
        taps   = "2-4",
        ore    = {
            { name = "Tin Ore",      rate = 100.0 },
        },
        stone  = {
            { name = "Coarse Stone", rate = 40.0 },
        },
        gems   = {
            { name = "Moss Agate",       rate = 1.2 },
            { name = "Shadowgem",        rate = 1.2 },
            { name = "Lesser Moonstone", rate = 0.9 },
            { name = "Jade",             rate = 0.3 },
        },
        zones  = {
            "Arathi Highlands", "Ashenvale", "Darkshore", "Duskwood",
            "Hillsbrad Foothills", "Loch Modan", "Redridge Mountains",
            "Silverpine Forest", "Stonetalon Mountains", "The Barrens",
            "Thousand Needles", "Westfall", "Wetlands",
        },
    },

    {
        name   = "Incendicite Mineral Vein",
        icon   = "inv_stone_13",
        colors = { 65, 90, 115, 165 },
        taps   = "2-4",
        note   = "Quest vein — drops Incendicite Ore for 'The Dark Iron War' quest chain",
        ore    = {
            { name = "Incendicite Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {},
        zones  = {
            "Wetlands",
        },
    },

    {
        name   = "Silver Vein",
        icon   = "inv_stone_16",
        colors = { 75, 100, 125, 175 },
        taps   = "2-4",
        ore    = {
            { name = "Silver Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {
            { name = "Moss Agate",       rate = 1.5 },
            { name = "Shadowgem",        rate = 1.0 },
            { name = "Lesser Moonstone", rate = 0.9 },
        },
        zones  = {
            "Arathi Highlands", "Ashenvale", "Darkshore", "Hillsbrad Foothills",
            "Redridge Mountains", "Stonetalon Mountains", "Stranglethorn Vale",
            "Thousand Needles", "Wetlands",
        },
    },

    {
        name   = "Ooze Covered Silver Vein",
        icon   = "inv_stone_16",
        colors = { 75, 100, 125, 175 },
        taps   = "2-4",
        ore    = {
            { name = "Silver Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {
            { name = "Moss Agate", rate = 2.0 },
        },
        zones  = {
            "Thousand Needles",
        },
    },

    {
        name   = "Lesser Bloodstone Deposit",
        icon   = "inv_misc_food_wheat_02",
        colors = { 75, 100, 125, 175 },
        taps   = "2-4",
        note   = "Quest vein — drops Lesser Bloodstone Ore for a quest in Arathi Highlands",
        ore    = {
            { name = "Lesser Bloodstone Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {},
        zones  = {
            "Arathi Highlands",
        },
    },

    {
        name   = "Iron Deposit",
        icon   = "inv_ore_iron_01",
        colors = { 125, 150, 175, 225 },
        taps   = "2-4",
        ore    = {
            { name = "Iron Ore",    rate = 100.0 },
        },
        stone  = {
            { name = "Heavy Stone", rate = 40.0 },
        },
        gems   = {
            { name = "Jade",             rate = 1.2 },
            { name = "Lesser Moonstone", rate = 0.9 },
            { name = "Citrine",          rate = 0.7 },
            { name = "Aquamarine",       rate = 0.2 },
        },
        zones  = {
            "Alterac Mountains", "Arathi Highlands", "Badlands", "Desolace",
            "Duskwood", "Dustwallow Marsh", "Feralas", "Hillsbrad Foothills",
            "Stranglethorn Vale", "Thousand Needles", "Wetlands",
        },
    },

    {
        name   = "Indurium Mineral Vein",
        colors = { 150, 175, 200, 250 },
        taps   = "2-4",
        note   = "Quest vein — drops Indurium Ore for the Uldaman quest chain",
        ore    = {
            { name = "Indurium Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {},
        zones  = {
            "Uldaman",
        },
    },

    {
        name   = "Gold Vein",
        icon   = "inv_ore_copper_01",
        colors = { 155, 180, 205, 255 },
        taps   = "2-4",
        ore    = {
            { name = "Gold Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {
            { name = "Citrine",          rate = 1.0 },
            { name = "Jade",             rate = 1.0 },
            { name = "Lesser Moonstone", rate = 0.9 },
        },
        zones  = {
            "Alterac Mountains", "Arathi Highlands", "Badlands", "Desolace",
            "Dustwallow Marsh", "Feralas", "Hillsbrad Foothills",
            "Stranglethorn Vale", "Thousand Needles", "Wetlands",
        },
    },

    {
        name   = "Ooze Covered Gold Vein",
        icon   = "inv_ore_copper_01",
        colors = { 155, 180, 205, 255 },
        taps   = "2-4",
        ore    = {
            { name = "Gold Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {
            { name = "Jade",             rate = 1.6 },
            { name = "Lesser Moonstone", rate = 1.6 },
        },
        zones  = {
            "Feralas", "Thousand Needles",
        },
    },

    {
        name   = "Mithril Deposit",
        icon   = "inv_ore_mithril_02",
        colors = { 175, 200, 225, 275 },
        taps   = "2-4",
        ore    = {
            { name = "Mithril Ore", rate = 100.0 },
        },
        stone  = {
            { name = "Solid Stone", rate = 40.0 },
        },
        gems   = {
            { name = "Black Vitriol", rate = 1.0 },
            { name = "Citrine",       rate = 1.0 },
            { name = "Aquamarine",    rate = 0.8 },
            { name = "Star Ruby",     rate = 0.8 },
        },
        zones  = {
            "Azshara", "Badlands", "Blasted Lands", "Burning Steppes",
            "Desolace", "Dustwallow Marsh", "Felwood", "Feralas",
            "Searing Gorge", "Silithus", "Stranglethorn Vale",
            "Swamp of Sorrows", "Tanaris", "The Hinterlands",
            "Thousand Needles", "Un'Goro Crater", "Western Plaguelands",
            "Winterspring",
        },
    },

    {
        name   = "Ooze Covered Mithril Deposit",
        icon   = "inv_ore_mithril_02",
        colors = { 175, 200, 225, 275 },
        taps   = "2-4",
        ore    = {
            { name = "Mithril Ore", rate = 100.0 },
        },
        stone  = {
            { name = "Solid Stone", rate = 38.0 },
        },
        gems   = {
            { name = "Black Vitriol", rate = 0.8 },
            { name = "Aquamarine",    rate = 0.7 },
            { name = "Citrine",       rate = 0.7 },
            { name = "Star Ruby",     rate = 0.4 },
        },
        zones  = {
            "Feralas", "Thousand Needles",
        },
    },

    {
        name   = "Truesilver Deposit",
        icon   = "inv_ore_truesilver_01",
        colors = { 205, 230, 255, 305 },
        taps   = "2-4",
        ore    = {
            { name = "Truesilver Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {
            { name = "Aquamarine", rate = 1.5 },
            { name = "Citrine",    rate = 0.9 },
            { name = "Star Ruby",  rate = 0.9 },
        },
        zones  = {
            "Azshara", "Burning Steppes", "Desolace", "Eastern Plaguelands",
            "Felwood", "Feralas", "Searing Gorge", "Silithus",
            "Swamp of Sorrows", "Tanaris", "The Hinterlands",
            "Un'Goro Crater", "Western Plaguelands", "Winterspring",
        },
    },

    {
        name   = "Ooze Covered Truesilver Deposit",
        icon   = "inv_ore_truesilver_01",
        colors = { 205, 230, 255, 305 },
        taps   = "2-4",
        ore    = {
            { name = "Truesilver Ore", rate = 100.0 },
        },
        stone  = {},
        gems   = {
            { name = "Aquamarine", rate = 1.2 },
            { name = "Citrine",    rate = 1.2 },
            { name = "Star Ruby",  rate = 1.1 },
        },
        zones  = {
            "Feralas", "Silithus", "Un'Goro Crater",
        },
    },

    {
        name   = "Dark Iron Deposit",
        icon   = "inv_ore_mithril_01",
        colors = { 230, 255, 280, 330 },
        taps   = "2-4",
        ore    = {
            { name = "Dark Iron Ore",         rate = 100.0 },
        },
        stone  = {},
        gems   = {
            { name = "Black Vitriol",         rate = 0.9 },
            { name = "Blood of the Mountain", rate = 0.6 },
            { name = "Black Diamond",         rate = 0.3 },
        },
        zones  = {
            "Blackrock Depths", "Burning Steppes", "Molten Core", "Searing Gorge",
        },
    },

    {
        name   = "Small Thorium Vein",
        icon   = "inv_ore_thorium_02",
        colors = { 245, 270, 295, 345 },
        taps   = "1-2",
        ore    = {
            { name = "Thorium Ore", rate = 100.0 },
        },
        stone  = {
            { name = "Dense Stone", rate = 40.0 },
        },
        gems   = {
            { name = "Black Vitriol",      rate = 1.0 },
            { name = "Huge Emerald",       rate = 0.8 },
            { name = "Star Ruby",          rate = 0.8 },
            { name = "Azerothian Diamond", rate = 0.7 },
            { name = "Blue Sapphire",      rate = 0.7 },
            { name = "Large Opal",         rate = 0.7 },
        },
        zones  = {
            "Azshara", "Burning Steppes", "Eastern Plaguelands", "Felwood",
            "Feralas", "Searing Gorge", "Silithus", "Tanaris",
            "The Hinterlands", "Un'Goro Crater", "Western Plaguelands",
            "Winterspring",
        },
    },

    {
        name   = "Ooze Covered Thorium Vein",
        icon   = "inv_ore_thorium_02",
        colors = { 245, 270, 295, 345 },
        taps   = "2-4",
        ore    = {
            { name = "Thorium Ore", rate = 100.0 },
        },
        stone  = {
            { name = "Dense Stone", rate = 38.0 },
        },
        gems   = {
            { name = "Huge Emerald",       rate = 1.1 },
            { name = "Black Vitriol",      rate = 1.0 },
            { name = "Large Opal",         rate = 0.9 },
            { name = "Blue Sapphire",      rate = 0.8 },
            { name = "Azerothian Diamond", rate = 0.7 },
            { name = "Star Ruby",          rate = 0.5 },
        },
        zones  = {
            "Un'Goro Crater",
        },
    },

    {
        name   = "Rich Thorium Vein",
        icon   = "inv_ore_thorium_02",
        colors = { 275, 300, 325, 375 },
        taps   = "2-4",
        ore    = {
            { name = "Thorium Ore", rate = 100.0 },
        },
        stone  = {
            { name = "Dense Stone", rate = 40.0 },
        },
        gems   = {
            { name = "Arcane Crystal",     rate = 3.0 },
            { name = "Azerothian Diamond", rate = 0.8 },
            { name = "Huge Emerald",       rate = 0.8 },
            { name = "Large Opal",         rate = 0.8 },
            { name = "Blue Sapphire",      rate = 0.7 },
            { name = "Star Ruby",          rate = 0.7 },
        },
        zones  = {
            "Azshara", "Burning Steppes", "Dire Maul", "Eastern Plaguelands",
            "Silithus", "Un'Goro Crater", "Western Plaguelands", "Winterspring",
        },
    },

    {
        name   = "Ooze Covered Rich Thorium Vein",
        icon   = "inv_ore_thorium_02",
        colors = { 275, 300, 325, 375 },
        taps   = "2-4",
        ore    = {
            { name = "Thorium Ore", rate = 100.0 },
        },
        stone  = {
            { name = "Dense Stone", rate = 40.0 },
        },
        gems   = {
            { name = "Arcane Crystal",     rate = 3.0 },
            { name = "Blue Sapphire",      rate = 0.9 },
            { name = "Azerothian Diamond", rate = 0.8 },
            { name = "Huge Emerald",       rate = 0.8 },
            { name = "Star Ruby",          rate = 0.8 },
            { name = "Large Opal",         rate = 0.7 },
        },
        zones  = {
            "Silithus", "Un'Goro Crater",
        },
    },

    {
        name   = "Hakkari Thorium Vein",
        icon   = "inv_ore_thorium_02",
        colors = { 275, 300, 325, 375 },
        taps   = "2-4",
        note   = "Souldarite only drops if Bloodscythe is in your bags",
        ore    = {
            { name = "Thorium Ore", rate = 100.0 },
        },
        stone  = {
            { name = "Dense Stone", rate = 39.0 },
        },
        gems   = {
            { name = "Souldarite",         rate = 36.0, note = "requires Bloodscythe in bags" },
            { name = "Arcane Crystal",     rate = 3.0  },
            { name = "Star Ruby",          rate = 1.1  },
            { name = "Huge Emerald",       rate = 1.0  },
            { name = "Azerothian Diamond", rate = 0.8  },
            { name = "Large Opal",         rate = 0.7  },
            { name = "Blue Sapphire",      rate = 0.6  },
        },
        zones  = {
            "Zul'Gurub",
        },
    },

    {
        name   = "Small Obsidian Chunk",
        icon   = "inv_stone_15",
        colors = { 305, 330, 355, 405 },
        taps   = "1-2",
        note   = "Requires 305 mining — at skill cap (300) you need Enchant Gloves - Mining (+5) or be a Dwarf (+10 racial)",
        ore    = {
            { name = "Small Obsidian Shard", rate = 90.0 },
            { name = "Large Obsidian Shard", rate = 4.0  },
        },
        stone  = {},
        gems   = {
            { name = "Essence of Earth",   rate = 4.0 },
            { name = "Huge Emerald",       rate = 1.1 },
            { name = "Azerothian Diamond", rate = 0.9 },
            { name = "Arcane Crystal",     rate = 0.3 },
        },
        zones  = {
            "Ruins of Ahn'Qiraj", "Temple of Ahn'Qiraj",
        },
    },

    {
        name   = "Large Obsidian Chunk",
        icon   = "inv_bracer_10",
        colors = { 325, 350, 375, 425 },
        taps   = "2-4",
        ore    = {
            { name = "Small Obsidian Shard", rate = 49.0 },
            { name = "Large Obsidian Shard", rate = 39.0 },
        },
        stone  = {},
        gems   = {
            { name = "Essence of Earth",   rate = 9.0 },
            { name = "Azerothian Diamond", rate = 1.6 },
            { name = "Arcane Crystal",     rate = 0.5 },
            { name = "Huge Emerald",       rate = 0.5 },
        },
        zones  = {
            "Ruins of Ahn'Qiraj", "Temple of Ahn'Qiraj",
        },
    },

}

-- colors = { orange_start, yellow_start, green_start, grey_start }
-- Thresholds for Iron, Steel, Mithril, Truesilver, Dark Iron, Thorium, Elementium are estimated [est]
-- Reagent quantities marked [est] should be verified against in-game or Wowhead skill page
ACC_Data.MiningSmelt = {

    {
        name     = "Smelt Copper",
        spellId  = 2657,
        skill    = 1,
        colors   = { 1, 25, 47, 70 },
        reagents = { { name = "Copper Ore", count = 1 } },
        creates  = { name = "Copper Bar", id = 2840, count = 1 , icon = "inv_ingot_02"},
        source   = "trainer",
        trainers = {
            { name = "Dank Drizzlecut",     zone = "Dun Morogh",        faction = "alliance" },
            { name = "Yarr Hammerstone",    zone = "Dun Morogh",        faction = "alliance" },
            { name = "Brock Stoneseeker",   zone = "Loch Modan",        faction = "alliance" },
            { name = "Gelman Stonehand",    zone = "Stormwind City",    faction = "alliance" },
            { name = "Geofram Bouldertoe",  zone = "Ironforge",         faction = "alliance" },
            { name = "Kurdram Stonehammer", zone = "Darkshore",         faction = "alliance" },
            { name = "Matt Johnson",        zone = "Duskwood",          faction = "alliance" },
            { name = "Johan Focht",         zone = "Silverpine Forest", faction = "horde" },
            { name = "Krunn",               zone = "Durotar",           faction = "horde" },
            { name = "Brek Stonehoof",      zone = "Thunder Bluff",     faction = "horde" },
            { name = "Makaru",              zone = "Orgrimmar",         faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",         faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Tin",
        spellId  = 3304,
        skill    = 65,
        colors   = { 65, 75, 100, 125 },    -- [est] yellow/green/grey
        reagents = { { name = "Tin Ore", count = 1 } },
        creates  = { name = "Tin Bar", id = 3576, count = 1 , icon = "inv_ingot_05"},
        source   = "trainer",
        trainers = {
            { name = "Dank Drizzlecut",     zone = "Dun Morogh",        faction = "alliance" },
            { name = "Yarr Hammerstone",    zone = "Dun Morogh",        faction = "alliance" },
            { name = "Brock Stoneseeker",   zone = "Loch Modan",        faction = "alliance" },
            { name = "Gelman Stonehand",    zone = "Stormwind City",    faction = "alliance" },
            { name = "Geofram Bouldertoe",  zone = "Ironforge",         faction = "alliance" },
            { name = "Kurdram Stonehammer", zone = "Darkshore",         faction = "alliance" },
            { name = "Matt Johnson",        zone = "Duskwood",          faction = "alliance" },
            { name = "Johan Focht",         zone = "Silverpine Forest", faction = "horde" },
            { name = "Krunn",               zone = "Durotar",           faction = "horde" },
            { name = "Brek Stonehoof",      zone = "Thunder Bluff",     faction = "horde" },
            { name = "Makaru",              zone = "Orgrimmar",         faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",         faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Bronze",
        spellId  = 2659,
        skill    = 65,
        colors   = { 65, 90, 100, 115 },
        reagents = {
            { name = "Copper Bar", count = 1 },
            { name = "Tin Bar",    count = 1 },
        },
        creates  = { name = "Bronze Bar", id = 2841, count = 2 , icon = "inv_ingot_bronze"},
        source   = "trainer",
        trainers = {
            { name = "Dank Drizzlecut",     zone = "Dun Morogh",        faction = "alliance" },
            { name = "Yarr Hammerstone",    zone = "Dun Morogh",        faction = "alliance" },
            { name = "Brock Stoneseeker",   zone = "Loch Modan",        faction = "alliance" },
            { name = "Gelman Stonehand",    zone = "Stormwind City",    faction = "alliance" },
            { name = "Geofram Bouldertoe",  zone = "Ironforge",         faction = "alliance" },
            { name = "Kurdram Stonehammer", zone = "Darkshore",         faction = "alliance" },
            { name = "Matt Johnson",        zone = "Duskwood",          faction = "alliance" },
            { name = "Johan Focht",         zone = "Silverpine Forest", faction = "horde" },
            { name = "Krunn",               zone = "Durotar",           faction = "horde" },
            { name = "Brek Stonehoof",      zone = "Thunder Bluff",     faction = "horde" },
            { name = "Makaru",              zone = "Orgrimmar",         faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",         faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Silver",
        spellId  = 2658,
        skill    = 75,
        colors   = { 75, 100, 112, 125 },
        reagents = { { name = "Silver Ore", count = 1 } },
        creates  = { name = "Silver Bar", id = 2842, count = 1 , icon = "inv_ingot_01"},
        source   = "trainer",
        trainers = {
            { name = "Dank Drizzlecut",     zone = "Dun Morogh",        faction = "alliance" },
            { name = "Yarr Hammerstone",    zone = "Dun Morogh",        faction = "alliance" },
            { name = "Brock Stoneseeker",   zone = "Loch Modan",        faction = "alliance" },
            { name = "Gelman Stonehand",    zone = "Stormwind City",    faction = "alliance" },
            { name = "Geofram Bouldertoe",  zone = "Ironforge",         faction = "alliance" },
            { name = "Kurdram Stonehammer", zone = "Darkshore",         faction = "alliance" },
            { name = "Matt Johnson",        zone = "Duskwood",          faction = "alliance" },
            { name = "Johan Focht",         zone = "Silverpine Forest", faction = "horde" },
            { name = "Krunn",               zone = "Durotar",           faction = "horde" },
            { name = "Brek Stonehoof",      zone = "Thunder Bluff",     faction = "horde" },
            { name = "Makaru",              zone = "Orgrimmar",         faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",         faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Iron",
        spellId  = 3307,
        skill    = 125,
        colors   = { 125, 130, 135, 140 },
        reagents = { { name = "Iron Ore", count = 1 } },
        creates  = { name = "Iron Bar", id = 3575, count = 1 , icon = "inv_ingot_iron"},
        source   = "trainer",
        trainers = {
            { name = "Gelman Stonehand",    zone = "Stormwind City",    faction = "alliance" },
            { name = "Geofram Bouldertoe",  zone = "Ironforge",         faction = "alliance" },
            { name = "Kurdram Stonehammer", zone = "Darkshore",         faction = "alliance" },
            { name = "Matt Johnson",        zone = "Duskwood",          faction = "alliance" },
            { name = "Brek Stonehoof",      zone = "Thunder Bluff",     faction = "horde" },
            { name = "Makaru",              zone = "Orgrimmar",         faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",         faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Gold",
        spellId  = 3308,
        skill    = 155,
        colors   = { 155, 170, 177, 185 },
        reagents = { { name = "Gold Ore", count = 1 } },
        creates  = { name = "Gold Bar", id = 3577, count = 1 , icon = "inv_ingot_03"},
        source   = "trainer",
        trainers = {
            { name = "Gelman Stonehand",    zone = "Stormwind City",    faction = "alliance" },
            { name = "Geofram Bouldertoe",  zone = "Ironforge",         faction = "alliance" },
            { name = "Kurdram Stonehammer", zone = "Darkshore",         faction = "alliance" },
            { name = "Matt Johnson",        zone = "Duskwood",          faction = "alliance" },
            { name = "Brek Stonehoof",      zone = "Thunder Bluff",     faction = "horde" },
            { name = "Makaru",              zone = "Orgrimmar",         faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",         faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Steel",
        spellId  = 3569,
        skill    = 165,
        colors   = { 165, 175, 185, 215 },   -- [est] yellow/green/grey
        reagents = {
            { name = "Iron Bar", count = 1 },
            { name = "Coal",     count = 1, vendor = true },
        },
        creates  = { name = "Steel Bar", id = 3859, count = 1 , icon = "inv_ingot_steel"},
        source   = "trainer",
        trainers = {
            { name = "Gelman Stonehand",    zone = "Stormwind City",    faction = "alliance" },
            { name = "Geofram Bouldertoe",  zone = "Ironforge",         faction = "alliance" },
            { name = "Kurdram Stonehammer", zone = "Darkshore",         faction = "alliance" },
            { name = "Matt Johnson",        zone = "Duskwood",          faction = "alliance" },
            { name = "Brek Stonehoof",      zone = "Thunder Bluff",     faction = "horde" },
            { name = "Makaru",              zone = "Orgrimmar",         faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",         faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Mithril",
        spellId  = 10097,
        skill    = 175,
        colors   = { 175, 200, 215, 235 },   -- [est] yellow/green/grey
        reagents = { { name = "Mithril Ore", count = 1 } },
        creates  = { name = "Mithril Bar", id = 3860, count = 1 , icon = "inv_ingot_06"},
        source   = "trainer",
        trainers = {
            { name = "Geofram Bouldertoe",  zone = "Ironforge",     faction = "alliance" },
            { name = "Makaru",              zone = "Orgrimmar",     faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",     faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Truesilver",
        spellId  = 10098,
        skill    = 205,                       -- [est] some sources say 230; verify in-game
        colors   = { 205, 215, 225, 245 },   -- [est]
        reagents = { { name = "Truesilver Ore", count = 1 } },
        creates  = { name = "Truesilver Bar", id = 6037, count = 1 , icon = "inv_ingot_08"},
        source   = "trainer",
        trainers = {
            { name = "Geofram Bouldertoe",  zone = "Ironforge",     faction = "alliance" },
            { name = "Makaru",              zone = "Orgrimmar",     faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",     faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Dark Iron",
        spellId  = 14891,
        skill    = 230,
        colors   = { 230, 255, 270, 285 },   -- [est]
        reagents = { { name = "Dark Iron Ore", count = 8 } },
        creates  = { name = "Dark Iron Bar", id = 11371, count = 1 , icon = "inv_ingot_mithril"},
        source   = "quest",
        npc      = { name = "Gloom'rel", zone = "Blackrock Depths" },
        quest      = "The Spectral Chalice",
        questId    = 4083,
        questLevel = 55,
        tribute  = {
            { name = "Gold Bar",       count = 20 },
            { name = "Truesilver Bar", count = 10 },
            { name = "Star Ruby",      count = 2  },
        },
        note     = "In the Summoners' Tomb (the Seven Dwarves room), talk to Gloom'rel first to spawn the Eternal Brazier — talking to any other dwarf ghost first triggers Doom'rel and a boss fight. Turn in the tribute at the Brazier to learn the spell. Dark Iron can only be smelted at the Black Forge, just outside the Molten Core entrance.",
    },

    {
        name     = "Smelt Thorium",
        spellId  = 16153,
        skill    = 245,
        colors   = { 245, 255, 270, 295 },   -- [est]
        reagents = { { name = "Thorium Ore", count = 1 } },
        creates  = { name = "Thorium Bar", id = 12359, count = 1 , icon = "inv_ingot_07"},
        source   = "trainer",
        trainers = {
            { name = "Geofram Bouldertoe",  zone = "Ironforge",     faction = "alliance" },
            { name = "Makaru",              zone = "Orgrimmar",     faction = "horde" },
            { name = "Brom Killian",        zone = "Undercity",     faction = "horde" },
            { name = "Pikkle",              zone = "Tanaris" },
        },
    },

    {
        name     = "Smelt Elementium",
        spellId  = 22967,
        skill    = 300,
        colors   = { 300, 310, 320, 330 },   -- always orange at max skill (cap is 300)
        reagents = {
            { name = "Elementium Ore", count = 1  },
            { name = "Arcanite Bar",   count = 10 },
            { name = "Fiery Core",     count = 1  },
            { name = "Elemental Flux", count = 3  },
        },
        creates  = { name = "Elementium Bar", id = 17771, count = 1 , icon = "inv_ingot_thorium"},
        source   = "mindcontrol",
        npc      = { name = "Master Elemental Shaper Krixix", zone = "Blackwing Lair" },
        note     = "Learned by having a Priest mind control Master Elemental Shaper Krixix, located at the bottom of the ramp just before Ebonroc and Flamegor in Blackwing Lair. While mind-controlled, Krixix can target Miners in the raid to teach them the spell.",
    },

}

ACC_Data.MiningTraining = {

    {
        name     = "Journeyman Miner",
        spellId  = 2582,
        skill    = 50,
        trainers = {
            { name = "Geofram Bouldertoe",  zone = "Ironforge",         faction = "alliance" },
            { name = "Gelman Stonehand",    zone = "Stormwind City",    faction = "alliance" },
            { name = "Kurdram Stonehammer", zone = "Darkshore",         faction = "alliance" },
            { name = "Matt Johnson",        zone = "Duskwood",          faction = "alliance" },
            { name = "Yarr Hammerstone",    zone = "Dun Morogh",        faction = "alliance" },
            { name = "Makaru",              zone = "Orgrimmar",         faction = "horde"    },
            { name = "Brom Killian",        zone = "Undercity",         faction = "horde"    },
            { name = "Johan Focht",         zone = "Silverpine Forest", faction = "horde"    },
            { name = "Krunn",               zone = "Durotar",           faction = "horde"    },
            { name = "Pikkle",              zone = "Tanaris",           faction = "neutral"  },
        },
    },

    {
        name     = "Expert Miner",
        spellId  = 3568,
        skill    = 125,
        trainers = {
            { name = "Geofram Bouldertoe", zone = "Ironforge",      faction = "alliance" },
            { name = "Gelman Stonehand",   zone = "Stormwind City", faction = "alliance" },
            { name = "Makaru",             zone = "Orgrimmar",      faction = "horde"    },
            { name = "Brom Killian",       zone = "Undercity",      faction = "horde"    },
            { name = "Pikkle",             zone = "Tanaris",        faction = "neutral"  },
        },
    },

    {
        name     = "Artisan Miner",
        spellId  = 10249,
        skill    = 200,
        trainers = {
            { name = "Geofram Bouldertoe", zone = "Ironforge",      faction = "alliance" },
            { name = "Gelman Stonehand",   zone = "Stormwind City", faction = "alliance" },
            { name = "Makaru",             zone = "Orgrimmar",      faction = "horde"    },
            { name = "Brom Killian",       zone = "Undercity",      faction = "horde"    },
            { name = "Brek Stonehoof",     zone = "Thunder Bluff",  faction = "horde"    },
            { name = "Pikkle",             zone = "Tanaris",        faction = "neutral"  },
        },
    },

}
