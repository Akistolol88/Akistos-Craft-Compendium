-- Herbalism node data for WoW Classic (1.12)
-- colors = { orange_start, yellow_start, green_start, grey_start }
-- terrain = spawn surface / environment description
-- zones   = all zones where the herb spawns

ACC_Data = ACC_Data or {}
ACC_Data.Herbalism = {

    {
        name    = "Peacebloom",
        item    = 2447,
        icon    = "inv_misc_flower_02",
        colors  = { 1, 25, 50, 100 },
        terrain = "Found in open terrain, low-elevation fields and clearings",
        zones   = {
            "Darkshore", "Dun Morogh", "Durotar", "Elwynn Forest",
            "Loch Modan", "Mulgore", "Redridge Mountains", "Silverpine Forest",
            "Teldrassil", "The Barrens", "Tirisfal Glades", "Westfall",
        },
    },

    {
        name    = "Silverleaf",
        item    = 765,
        icon    = "inv_misc_herb_10",
        colors  = { 1, 25, 50, 100 },
        terrain = "Found near trees and shrubs, forest edges and clearings",
        zones   = {
            "Darkshore", "Dun Morogh", "Durotar", "Elwynn Forest",
            "Loch Modan", "Mulgore", "Redridge Mountains", "Silverpine Forest",
            "Teldrassil", "The Barrens", "Tirisfal Glades", "Westfall",
        },
    },

    {
        name    = "Earthroot",
        item    = 2449,
        icon    = "inv_misc_herb_07",
        colors  = { 15, 40, 65, 115 },
        terrain = "Found near rocky terrain, cliff bases and boulders",
        zones   = {
            "Arathi Highlands", "Darkshore", "Dun Morogh", "Durotar",
            "Elwynn Forest", "Loch Modan", "Mulgore", "Redridge Mountains",
            "Silverpine Forest", "Stonetalon Mountains", "Teldrassil",
            "The Barrens", "Tirisfal Glades", "Westfall", "Wetlands",
        },
    },

    {
        name    = "Mageroyal",
        item    = 785,
        icon    = "inv_jewelry_talisman_03",
        colors  = { 50, 75, 100, 150 },
        terrain = "Found in open fields and scrubland",
        note    = "Can drop Swiftthistle",
        zones   = {
            "Arathi Highlands", "Darkshore", "Duskwood", "Hillsbrad Foothills",
            "Loch Modan", "Redridge Mountains", "Silverpine Forest",
            "Stonetalon Mountains", "The Barrens", "Thousand Needles",
            "Westfall", "Wetlands",
        },
    },

    {
        name    = "Briarthorn",
        item    = 2450,
        icon    = "inv_misc_root_01",
        colors  = { 70, 95, 120, 170 },
        terrain = "Found in wooded and hilly terrain, forest undergrowth",
        note    = "Can drop Swiftthistle",
        zones   = {
            "Arathi Highlands", "Ashenvale", "Darkshore", "Duskwood",
            "Hillsbrad Foothills", "Redridge Mountains", "Silverpine Forest",
            "Stonetalon Mountains", "Stranglethorn Vale", "Wetlands",
        },
    },

    {
        name    = "Stranglekelp",
        item    = 3820,
        icon    = "inv_misc_herb_11",
        colors  = { 85, 110, 135, 185 },
        terrain = "Found underwater only, on ocean and river floors",
        zones   = {
            "Arathi Highlands", "Azshara", "Dustwallow Marsh", "Feralas",
            "Hillsbrad Foothills", "Stranglethorn Vale", "Tanaris",
            "The Barrens", "Westfall", "Wetlands",
        },
    },

    {
        name    = "Bruiseweed",
        item    = 2453,
        icon    = "inv_misc_herb_01",
        colors  = { 100, 125, 150, 200 },
        terrain = "Found in open ground, often near roads and paths",
        zones   = {
            "Alterac Mountains", "Arathi Highlands", "Ashenvale", "Desolace",
            "Duskwood", "Hillsbrad Foothills", "Stonetalon Mountains",
            "Stranglethorn Vale", "Thousand Needles", "Wetlands",
        },
    },

    {
        name    = "Wild Steelbloom",
        item    = 3355,
        icon    = "inv_misc_flower_01",
        colors  = { 115, 140, 165, 215 },
        terrain = "Found on hillsides and rocky highland terrain",
        zones   = {
            "Alterac Mountains", "Arathi Highlands", "Badlands",
            "Desolace", "Hillsbrad Foothills", "Stonetalon Mountains",
            "Stranglethorn Vale",
        },
    },

    {
        name    = "Grave Moss",
        item    = 3369,
        icon    = "inv_misc_dust_02",
        colors  = { 120, 145, 170, 220 },
        terrain = "Found near graveyards, crypts and undead-inhabited areas",
        zones   = {
            "Darkshore", "Duskwood", "Hillsbrad Foothills", "Razorfen Downs",
            "Scarlet Monastery", "Silverpine Forest", "Tirisfal Glades", "Wetlands",
        },
    },

    {
        name    = "Kingsblood",
        item    = 3356,
        icon    = "inv_misc_herb_03",
        colors  = { 125, 150, 175, 225 },
        terrain = "Found in open plains, meadows and forest clearings",
        zones   = {
            "Arathi Highlands", "Ashenvale", "Desolace", "Duskwood",
            "Hillsbrad Foothills", "Stranglethorn Vale", "The Barrens",
            "Thousand Needles", "Wetlands",
        },
    },

    {
        name    = "Liferoot",
        item    = 3357,
        icon    = "inv_misc_root_02",
        colors  = { 150, 175, 200, 250 },
        terrain = "Found near water sources, riverbanks and lake shores",
        zones   = {
            "Alterac Mountains", "Arathi Highlands", "Ashenvale", "Desolace",
            "Dustwallow Marsh", "Hillsbrad Foothills", "Stonetalon Mountains",
            "Stranglethorn Vale", "Swamp of Sorrows", "Wetlands",
        },
    },

    {
        name    = "Fadeleaf",
        item    = 3818,
        icon    = "inv_misc_herb_12",
        colors  = { 160, 185, 210, 260 },
        terrain = "Found in dense forest floors and deep shaded undergrowth",
        zones   = {
            "Alterac Mountains", "Arathi Highlands", "Duskwood",
            "Feralas", "Stranglethorn Vale", "Swamp of Sorrows",
        },
    },

    {
        name    = "Goldthorn",
        item    = 3821,
        icon    = "inv_misc_herb_15",
        colors  = { 170, 195, 220, 270 },
        terrain = "Found on hillsides and near cliff faces in mid-level zones",
        zones   = {
            "Alterac Mountains", "Arathi Highlands", "Badlands",
            "Feralas", "Hillsbrad Foothills", "Stranglethorn Vale",
            "Swamp of Sorrows",
        },
    },

    {
        name    = "Khadgar's Whisker",
        item    = 3358,
        icon    = "inv_misc_herb_08",
        colors  = { 185, 210, 235, 285 },
        terrain = "Found in dense forest and darkened shaded areas",
        zones   = {
            "Azshara", "Blasted Lands", "Feralas", "Stranglethorn Vale",
            "Swamp of Sorrows", "Western Plaguelands",
        },
    },

    {
        name    = "Wintersbite",
        item    = 3819,
        icon    = "inv_misc_flower_03",
        colors  = { 195, 220, 245, 295 },
        terrain = "Found in snowy mountain terrain",
        zones   = {
            "Alterac Mountains",
        },
    },

    {
        name    = "Firebloom",
        item    = 4625,
        icon    = "inv_misc_herb_19",
        colors  = { 205, 230, 255, 305 },
        terrain = "Found in volcanic, fire-scorched and arid rocky terrain",
        zones   = {
            "Blasted Lands", "Burning Steppes", "Searing Gorge", "Tanaris",
        },
    },

    {
        name    = "Purple Lotus",
        item    = 8831,
        icon    = "inv_misc_herb_17",
        colors  = { 210, 235, 255, 305 },
        terrain = "Found in desert, jungle and open terrain of high-level zones",
        note    = "Can drop Wildvine",
        zones   = {
            "Azshara", "Feralas", "Felwood", "Stranglethorn Vale",
            "Tanaris", "The Hinterlands", "Un'Goro Crater",
        },
    },

    {
        name    = "Arthas' Tears",
        item    = 8836,
        icon    = "inv_misc_herb_13",
        colors  = { 220, 245, 270, 320 },
        terrain = "Found in blight-affected and plague-corrupted terrain",
        zones   = {
            "Eastern Plaguelands", "Felwood", "Western Plaguelands",
        },
    },

    {
        name    = "Sungrass",
        item    = 8838,
        icon    = "inv_misc_herb_18",
        colors  = { 230, 255, 280, 330 },
        terrain = "Found in open elevated terrain with sun exposure",
        zones   = {
            "Azshara", "Eastern Plaguelands", "Felwood", "Feralas",
            "The Hinterlands", "Thousand Needles", "Un'Goro Crater",
        },
    },

    {
        name    = "Blindweed",
        item    = 8839,
        icon    = "inv_misc_herb_14",
        colors  = { 235, 260, 285, 335 },
        terrain = "Found near water, in swampy and marshy terrain",
        zones   = {
            "Azshara", "Dustwallow Marsh", "Feralas",
            "Swamp of Sorrows", "Un'Goro Crater",
        },
    },

    {
        name    = "Ghost Mushroom",
        item    = 8845,
        icon    = "inv_mushroom_08",
        colors  = { 245, 270, 295, 345 },
        terrain = "Found in caves and underground passages only",
        zones   = {
            "Maraudon", "The Hinterlands", "Un'Goro Crater",
        },
    },

    {
        name    = "Gromsblood",
        item    = 8846,
        icon    = "inv_misc_herb_16",
        colors  = { 250, 275, 300, 350 },
        terrain = "Found in demon-corrupted and fel-tainted terrain",
        zones   = {
            "Blasted Lands", "Desolace", "Felwood",
        },
    },

    {
        name    = "Golden Sansam",
        item    = 13463,
        icon    = "inv_misc_herb_dreamfoil",
        colors  = { 260, 285, 310, 360 },
        terrain = "Found in open terrain of high-level zones",
        zones   = {
            "Azshara", "Eastern Plaguelands", "Felwood",
            "Silithus", "The Hinterlands", "Un'Goro Crater",
        },
    },

    {
        name    = "Dreamfoil",
        item    = 13464,
        icon    = "inv_misc_herb_sansamroot",
        colors  = { 270, 295, 320, 370 },
        terrain = "Found in open fields and varied terrain of high-level zones",
        zones   = {
            "Azshara", "Blasted Lands", "Eastern Plaguelands",
            "Silithus", "Un'Goro Crater", "Winterspring",
        },
    },

    {
        name    = "Mountain Silversage",
        item    = 13465,
        icon    = "inv_misc_herb_mountainsilversage",
        colors  = { 280, 305, 330, 380 },
        terrain = "Found on rocky slopes, mountain ridges and high elevations",
        zones   = {
            "Azshara", "Burning Steppes", "Eastern Plaguelands",
            "Silithus", "The Hinterlands", "Un'Goro Crater", "Winterspring",
        },
    },

    {
        name    = "Plaguebloom",
        item    = 13466,
        icon    = "inv_misc_herb_plaguebloom",
        colors  = { 285, 310, 335, 385 },
        terrain = "Found in heavily plague-ravaged and corrupted terrain",
        zones   = {
            "Eastern Plaguelands", "Felwood", "Western Plaguelands",
        },
    },

    {
        name    = "Icecap",
        item    = 13467,
        icon    = "inv_misc_herb_icecap",
        colors  = { 290, 315, 340, 390 },
        terrain = "Found in frozen, icy and snow-covered terrain",
        zones   = {
            "Winterspring",
        },
    },

    {
        name    = "Black Lotus",
        item    = 13468,
        icon    = "inv_misc_herb_blacklotus",
        colors  = { 300, 325, 350, 400 },
        terrain = "Extremely rare spawn, heavily contested",
        note    = "Max 1 per zone; 10–45 min respawn",
        zones   = {
            "Burning Steppes", "Eastern Plaguelands",
            "Silithus", "Winterspring",
        },
    },

}

ACC_Data.HerbalismSkill = {
    { rank = "Apprentice", req_skill = 0,   req_level = 1,  skill_max = 75  },
    { rank = "Journeyman", req_skill = 50,  req_level = 10, skill_max = 150 },
    { rank = "Expert",     req_skill = 125, req_level = 20, skill_max = 225 },
    { rank = "Artisan",    req_skill = 200, req_level = 35, skill_max = 300 },
}

ACC_Data.HerbalismTrainers = {
    { name = "Malorne Bladeleaf",  zone = "Teldrassil",          area = "Dolanaar",               faction = "alliance", max_rank = "journeyman" },
    { name = "Herbalist Pomeroy",  zone = "Elwynn Forest",       area = "Goldshire",              faction = "alliance", max_rank = "journeyman" },
    { name = "Shylamiir",          zone = "Stormwind City",      area = "Trade District",         faction = "alliance", max_rank = "expert"     },
    { name = "Brant Jasperbloom",  zone = "Ironforge",           area = "The Commons",            faction = "alliance", max_rank = "expert"     },
    { name = "Flora Silverwind",   zone = "Darnassus",           area = "Craftsmen's Terrace",    faction = "alliance", max_rank = "expert"     },
    { name = "Harlown Darkweave",  zone = "Ashenvale",           area = "Maestra's Post",         faction = "alliance", max_rank = "expert"     },
    { name = "Alma Jainrose",      zone = "Hillsbrad Foothills", area = "Southshore",             faction = "alliance", max_rank = "expert"     },
    { name = "Muireann Derran",    zone = "Feralas",             area = "Feathermoon Stronghold", faction = "alliance", max_rank = "artisan"    },
    { name = "Jandi",              zone = "Orgrimmar",           area = "The Drag",               faction = "horde",    max_rank = "expert"     },
    { name = "Komin Winterhoof",   zone = "Thunder Bluff",       area = "High Rise",              faction = "horde",    max_rank = "expert"     },
    { name = "Bena Winterhoof",    zone = "Thunder Bluff",       area = "High Rise",              faction = "horde",    max_rank = "journeyman" },
    { name = "Reyna Stonebranch",  zone = "Undercity",           area = "Magic Quarter",          faction = "horde",    max_rank = "expert"     },
    { name = "Angrun",             zone = "Stranglethorn Vale",  area = "Grom'gol Base Camp",     faction = "horde",    max_rank = "expert"     },
    { name = "Mishiki",            zone = "Orgrimmar",           area = "The Drag",               faction = "horde",    max_rank = "artisan"    },
}

ACC_Data.HerbalismTraining = {

    {
        name     = "Journeyman Herbalist",
        spellId  = 2373,
        skill    = 50,
        trainers = {
            { name = "Malorne Bladeleaf", zone = "Teldrassil",          faction = "alliance" },
            { name = "Herbalist Pomeroy", zone = "Elwynn Forest",       faction = "alliance" },
            { name = "Shylamiir",         zone = "Stormwind City",      faction = "alliance" },
            { name = "Brant Jasperbloom", zone = "Ironforge",           faction = "alliance" },
            { name = "Flora Silverwind",  zone = "Darnassus",           faction = "alliance" },
            { name = "Harlown Darkweave", zone = "Ashenvale",           faction = "alliance" },
            { name = "Alma Jainrose",     zone = "Hillsbrad Foothills", faction = "alliance" },
            { name = "Jandi",             zone = "Orgrimmar",           faction = "horde"    },
            { name = "Komin Winterhoof",  zone = "Thunder Bluff",       faction = "horde"    },
            { name = "Bena Winterhoof",   zone = "Thunder Bluff",       faction = "horde"    },
            { name = "Reyna Stonebranch", zone = "Undercity",           faction = "horde"    },
            { name = "Angrun",            zone = "Stranglethorn Vale",  faction = "horde"    },
        },
    },

    {
        name     = "Expert Herbalist",
        spellId  = 3571,
        skill    = 125,
        trainers = {
            { name = "Shylamiir",         zone = "Stormwind City",      faction = "alliance" },
            { name = "Brant Jasperbloom", zone = "Ironforge",           faction = "alliance" },
            { name = "Flora Silverwind",  zone = "Darnassus",           faction = "alliance" },
            { name = "Harlown Darkweave", zone = "Ashenvale",           faction = "alliance" },
            { name = "Alma Jainrose",     zone = "Hillsbrad Foothills", faction = "alliance" },
            { name = "Jandi",             zone = "Orgrimmar",           faction = "horde"    },
            { name = "Komin Winterhoof",  zone = "Thunder Bluff",       faction = "horde"    },
            { name = "Reyna Stonebranch", zone = "Undercity",           faction = "horde"    },
            { name = "Angrun",            zone = "Stranglethorn Vale",  faction = "horde"    },
        },
    },

    {
        name     = "Artisan Herbalist",
        spellId  = 11994,
        skill    = 200,
        trainers = {
            { name = "Muireann Derran", zone = "Feralas",    faction = "alliance" },
            { name = "Mishiki",         zone = "Orgrimmar",  faction = "horde"    },
        },
    },

}
