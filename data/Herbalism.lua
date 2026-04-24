-- Herbalism node data for WoW Classic (1.12)
-- colors = { orange_start, yellow_start, green_start, grey_start }
-- terrain = spawn surface / environment description
-- zones   = all zones where the herb spawns

ACC_Data = ACC_Data or {}
ACC_Data.Herbalism = {

    {
        name    = "Peacebloom",
        item    = 2447,
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
        colors  = { 15, 39, 64, 114 },
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
        colors  = { 50, 74, 99, 149 },
        terrain = "Found in open fields and scrubland",
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
        colors  = { 70, 94, 119, 169 },
        terrain = "Found in wooded and hilly terrain, forest undergrowth",
        zones   = {
            "Arathi Highlands", "Ashenvale", "Darkshore", "Duskwood",
            "Hillsbrad Foothills", "Redridge Mountains", "Silverpine Forest",
            "Stonetalon Mountains", "Stranglethorn Vale", "Wetlands",
        },
    },

    {
        name    = "Swiftthistle",
        item    = 2452,
        colors  = { 70, 94, 119, 169 },
        terrain = "Rare spawn sharing node locations with Mageroyal and Briarthorn",
        zones   = {
            "Arathi Highlands", "Ashenvale", "Darkshore", "Duskwood",
            "Hillsbrad Foothills", "Redridge Mountains", "Stranglethorn Vale",
            "Wetlands",
        },
    },

    {
        name    = "Stranglekelp",
        item    = 3820,
        colors  = { 85, 109, 134, 184 },
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
        colors  = { 100, 124, 149, 199 },
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
        colors  = { 115, 139, 164, 214 },
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
        colors  = { 120, 144, 169, 219 },
        terrain = "Found near graveyards, crypts and undead-inhabited areas",
        zones   = {
            "Darkshore", "Duskwood", "Hillsbrad Foothills",
            "Silverpine Forest", "Tirisfal Glades", "Wetlands",
        },
    },

    {
        name    = "Kingsblood",
        item    = 3356,
        colors  = { 125, 149, 174, 224 },
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
        colors  = { 150, 174, 199, 249 },
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
        colors  = { 150, 174, 199, 249 },
        terrain = "Found in dense forest floors and deep shaded undergrowth",
        zones   = {
            "Alterac Mountains", "Arathi Highlands", "Duskwood",
            "Feralas", "Stranglethorn Vale", "Swamp of Sorrows",
        },
    },

    {
        name    = "Goldthorn",
        item    = 3821,
        colors  = { 170, 194, 219, 269 },
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
        colors  = { 185, 209, 234, 284 },
        terrain = "Found in dense forest and darkened shaded areas",
        zones   = {
            "Azshara", "Blasted Lands", "Feralas", "Stranglethorn Vale",
            "Swamp of Sorrows", "Western Plaguelands",
        },
    },

    {
        name    = "Wintersbite",
        item    = 3819,
        colors  = { 195, 219, 244, 294 },
        terrain = "Found in snowy mountain terrain",
        zones   = {
            "Alterac Mountains",
        },
    },

    {
        name    = "Firebloom",
        item    = 4625,
        colors  = { 205, 229, 254, 304 },
        terrain = "Found in volcanic, fire-scorched and arid rocky terrain",
        zones   = {
            "Blasted Lands", "Burning Steppes", "Searing Gorge", "Tanaris",
        },
    },

    {
        name    = "Purple Lotus",
        item    = 8831,
        colors  = { 210, 234, 259, 309 },
        terrain = "Found in desert, jungle and open terrain of high-level zones",
        zones   = {
            "Azshara", "Feralas", "Felwood", "Tanaris", "Un'Goro Crater",
        },
    },

    {
        name    = "Arthas' Tears",
        item    = 8836,
        colors  = { 220, 244, 269, 319 },
        terrain = "Found in blight-affected and plague-corrupted terrain",
        zones   = {
            "Eastern Plaguelands", "Western Plaguelands",
        },
    },

    {
        name    = "Sungrass",
        item    = 8838,
        colors  = { 230, 254, 279, 329 },
        terrain = "Found in open elevated terrain with sun exposure",
        zones   = {
            "Azshara", "Eastern Plaguelands", "Felwood", "Feralas",
            "The Hinterlands", "Thousand Needles", "Un'Goro Crater",
        },
    },

    {
        name    = "Blindweed",
        item    = 8839,
        colors  = { 235, 259, 284, 334 },
        terrain = "Found near water, in swampy and marshy terrain",
        zones   = {
            "Azshara", "Dustwallow Marsh", "Feralas",
            "Swamp of Sorrows", "Un'Goro Crater",
        },
    },

    {
        name    = "Ghost Mushroom",
        item    = 8845,
        colors  = { 245, 269, 294, 344 },
        terrain = "Found in caves and underground passages only",
        zones   = {
            "Maraudon", "The Hinterlands", "Un'Goro Crater",
        },
    },

    {
        name    = "Gromsblood",
        item    = 8846,
        colors  = { 250, 274, 299, 349 },
        terrain = "Found in demon-corrupted and fel-tainted terrain",
        zones   = {
            "Blasted Lands", "Desolace", "Felwood",
        },
    },

    {
        name    = "Golden Sansam",
        item    = 13463,
        colors  = { 260, 284, 309, 359 },
        terrain = "Found in open terrain of high-level zones",
        zones   = {
            "Azshara", "Eastern Plaguelands", "Felwood",
            "Silithus", "The Hinterlands", "Un'Goro Crater",
        },
    },

    {
        name    = "Dreamfoil",
        item    = 13464,
        colors  = { 270, 294, 319, 369 },
        terrain = "Found in open fields and varied terrain of high-level zones",
        zones   = {
            "Azshara", "Blasted Lands", "Eastern Plaguelands",
            "Silithus", "Un'Goro Crater", "Winterspring",
        },
    },

    {
        name    = "Mountain Silversage",
        item    = 13465,
        colors  = { 280, 304, 329, 379 },
        terrain = "Found on rocky slopes, mountain ridges and high elevations",
        zones   = {
            "Azshara", "Burning Steppes", "Eastern Plaguelands",
            "Silithus", "The Hinterlands", "Un'Goro Crater", "Winterspring",
        },
    },

    {
        name    = "Plaguebloom",
        item    = 13466,
        colors  = { 285, 309, 334, 384 },
        terrain = "Found in heavily plague-ravaged and corrupted terrain",
        zones   = {
            "Eastern Plaguelands", "Felwood", "Western Plaguelands",
        },
    },

    {
        name    = "Icecap",
        item    = 13467,
        colors  = { 290, 314, 339, 389 },
        terrain = "Found in frozen, icy and snow-covered terrain",
        zones   = {
            "Winterspring",
        },
    },

    {
        name    = "Black Lotus",
        item    = 13468,
        colors  = { 300, 324, 349, 399 },
        terrain = "Extremely rare spawn, heavily contested — typically 1-3 nodes per zone",
        zones   = {
            "Blasted Lands", "Burning Steppes", "Eastern Plaguelands",
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
