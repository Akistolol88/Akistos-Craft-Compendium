-- Fishing.lua — training tiers and tournament rewards for WoW Classic (1.12).
--
-- FishingTraining fields:
--   name       display name shown in the browser
--   spellId    spell ID (training entries only)
--   skill      skill points required
--   _train     true → trainer entry; shows trainer list on hover/click
--   _book      true → book entry; shows vendor list on hover/click
--   _quest     true → quest entry; shows quest giver on hover/click
--
-- FishingTournament fields:
--   name       item name
--   itemId     item ID (used for icon resolution and shift-click linking)
--   questName  quest that rewards this item
--   questId    quest ID
--   questLevel quest level
--
-- Expert Fishing is learned from the book "Expert Fishing - The Bass and You" (item 16083),
-- sold by Old Man Heming in Booty Bay.
--
-- Artisan Fishing is learned from Nat Pagle via the quest "Nat Pagle, Angler Extreme"
-- (quest 6607, requires level 45 and skill 225).
--
-- The Stranglethorn Fishing Extravaganza runs every Sunday. Three rare fish can be turned in
-- at any time for a reward. The overall tournament winner receives a choice of Arcanite Fishing
-- Pole or Hook of the Master Angler via the "Master Angler" quest.

ACC_Data = ACC_Data or {}

ACC_Data.FishingTraining = {
    {
        name    = "Journeyman Fishing",
        spellId = 8988,
        skill   = 50,
        _train  = true,
        trainers = {
            -- Alliance only
            { name = "Astaia",             zone = "Darnassus",           faction = "alliance" },
            { name = "Grimnur Stonebrand", zone = "Ironforge",           faction = "alliance" },
            { name = "Lee Brown",          zone = "Elwynn Forest",       faction = "alliance" },
            { name = "Matthew Hooper",     zone = "Redridge Mountains",  faction = "alliance" },
            { name = "Paxton Ganter",      zone = "Dun Morogh",          faction = "alliance" },
            -- Horde only
            { name = "Armand Cromwell",    zone = "Undercity",           faction = "horde"    },
            { name = "Kah Mistrunner",     zone = "Thunder Bluff",       faction = "horde"    },
            { name = "Katoom the Angler",  zone = "The Hinterlands",     faction = "horde"    },
            { name = "Lau'Tiki",           zone = "Durotar",             faction = "horde"    },
            { name = "Lumak",              zone = "Orgrimmar",           faction = "horde"    },
            { name = "Uthan Stillwater",   zone = "Mulgore",             faction = "horde"    },
            -- Neutral (reacts to both)
            { name = "Androl Oakhand",     zone = "Teldrassil"           },
            { name = "Arnold Leland",      zone = "Stormwind City"       },
            { name = "Brannock",           zone = "Feralas"              },
            { name = "Clyde Kellen",       zone = "Tirisfal Glades"      },
            { name = "Donald Rabonne",     zone = "Hillsbrad Foothills"  },
            { name = "Harold Riggs",       zone = "Wetlands"             },
            { name = "Kil'Hiwana",         zone = "Ashenvale"            },
            { name = "Lui'Mala",           zone = "Desolace"             },
            { name = "Myizz Luckycatch",   zone = "Stranglethorn Vale"   },
            { name = "Warg Deepwater",     zone = "Loch Modan"           },
        },
    },
    {
        name       = "Expert Fishing",
        skill      = 125,
        _book      = true,
        bookName   = "Expert Fishing - The Bass and You",
        bookItemId = 16083,
        vendors    = {
            { name = "Old Man Heming", zone = "Stranglethorn Vale", area = "Booty Bay" },
        },
    },
    {
        name        = "Artisan Fishing",
        skill       = 225,
        _quest      = true,
        questName   = "Nat Pagle, Angler Extreme",
        questId     = 6607,
        questLevel  = 45,
        questGivers = {
            { name = "Nat Pagle", zone = "Dustwallow Marsh", area = "Nat Pagle's Stead" },
        },
        questFish = {
            { name = "Feralas Ahi",               zone = "Feralas",           coords = "62, 51",  area = "Verdantis River, SE of Dire Maul"           },
            { name = "Misty Reed Mahi Mahi",       zone = "Swamp of Sorrows",  coords = "90, 72",  area = "Misty Reef Strand"                           },
            { name = "Sar'theris Striker",         zone = "Desolace",          coords = "25, 77",  area = "Sar'theris Strand, S of Shadowprey Village"  },
            { name = "Savage Coast Blue Sailfin",  zone = "Stranglethorn Vale",coords = "33, 32",  area = "Savage Coast, S of Grom'gol Base Camp"       },
        },
        note = "Not in special pools — drop your bobber in the area. May take several casts.",
    },
}

-- FishingPoles / FishingLures / FishingTournament fields:
--   name         item name
--   itemId       item ID (for icon resolution and shift-click linking)
--   displayGroup controls sort order within the category
--   sources      acquisition sources in the same format as regular recipe sources:
--                  { type="quest",     quests=[{id,name,level,faction}] }
--                  { type="vendor",    vendors=[{name,zone,faction}] }
--                  { type="container", containers=[{name,zone,rate,count,total}] }
--                  { type="craft",     prof="Engineering" }
--                  { type="note",      text="..." }   ← plain text fallback

-- fishingBonus: the +Fishing skill the equipped pole provides.
-- Used for sorting (lowest to highest) and displayed in the skill column as "+X".

ACC_Data.FishingPoles = {
    {
        name = "Fishing Pole", itemId = 6256, fishingBonus = 0,
        sources = { { type = "vendor", vendors = { { name = "Fishing supply vendors", zone = "Most zones" } } } },
    },
    {
        name = "Darkwood Fishing Pole", itemId = 6366, fishingBonus = 5,
        sources = { { type = "note", text = "Fished in level 10-25 zones" } },
    },
    {
        name = "Blump Family Fishing Pole", itemId = 12225, fishingBonus = 5,
        sources = { { type = "quest", quests = {
            { id = 1141, name = "The Family and the Fishing Pole", level = 14, faction = "alliance" },
        } } },
    },
    {
        name = "Strong Fishing Pole", itemId = 6365, fishingBonus = 20,
        sources = { { type = "vendor", vendors = { { name = "Fishing supply vendors", zone = "Most zones" } } } },
    },
    {
        name = "Big Iron Fishing Pole", itemId = 6367, fishingBonus = 20,
        sources = { { type = "container", containers = {
            { name = "Shellfish Trap", zone = "Desolace", rate = 0.29, count = 1, total = 346 },
        } } },
    },
    {
        name = "Nat Pagle's Extreme Angler FC-5000", itemId = 19022, fishingBonus = 25,
        sources = { { type = "quest", quests = {
            { id = 7815, name = "Snapjaws, Mon!", level = 50, faction = "horde" },
        } } },
    },
}

-- FishingZones fields:
--   name        zone/city/dungeon/raid name
--   minCast     minimum fishing skill to cast (avoids most "fish got away")
--   guaranteed  minimum fishing skill for a guaranteed catch (never "fish got away")
--   note        optional clarification (e.g. specific sub-area)

ACC_Data.FishingZones = {
    -- ── Tier 1: minCast 1, guaranteed 96 ─────────────────────────────────────
    -- Cities
    { name = "Darnassus",          minCast = 1,   guaranteed = 96  },
    { name = "Ironforge",          minCast = 1,   guaranteed = 96  },
    { name = "Orgrimmar",          minCast = 1,   guaranteed = 96  },
    { name = "Stormwind City",     minCast = 1,   guaranteed = 96  },
    { name = "Thunder Bluff",      minCast = 1,   guaranteed = 96  },
    { name = "Undercity",          minCast = 1,   guaranteed = 96  },
    -- Zones
    { name = "Darkshore",          minCast = 1,   guaranteed = 96  },
    { name = "Dun Morogh",         minCast = 1,   guaranteed = 96  },
    { name = "Durotar",            minCast = 1,   guaranteed = 96  },
    { name = "Elwynn Forest",      minCast = 1,   guaranteed = 96  },
    { name = "Loch Modan",         minCast = 1,   guaranteed = 96  },
    { name = "Mulgore",            minCast = 1,   guaranteed = 96  },
    { name = "Silverpine Forest",  minCast = 1,   guaranteed = 96  },
    { name = "Teldrassil",         minCast = 1,   guaranteed = 96  },
    { name = "The Barrens",        minCast = 1,   guaranteed = 96  },
    { name = "Tirisfal Glades",    minCast = 1,   guaranteed = 96  },
    { name = "Westfall",           minCast = 1,   guaranteed = 96  },
    -- Dungeons
    { name = "Blackfathom Deeps",  minCast = 1,   guaranteed = 96  },
    { name = "The Deadmines",      minCast = 1,   guaranteed = 96  },
    { name = "Wailing Caverns",    minCast = 1,   guaranteed = 96  },

    -- ── Tier 2: minCast 55, guaranteed 150 ───────────────────────────────────
    { name = "Ashenvale",          minCast = 55,  guaranteed = 150 },
    { name = "Duskwood",           minCast = 55,  guaranteed = 150 },
    { name = "Hillsbrad Foothills",minCast = 55,  guaranteed = 150 },
    { name = "Redridge Mountains", minCast = 55,  guaranteed = 150 },
    { name = "Stonetalon Mountains",minCast = 55, guaranteed = 150 },
    { name = "Wetlands",           minCast = 55,  guaranteed = 150 },

    -- ── Tier 3: minCast 130, guaranteed 225 ──────────────────────────────────
    { name = "Alterac Mountains",  minCast = 130, guaranteed = 225 },
    { name = "Arathi Highlands",   minCast = 130, guaranteed = 225 },
    { name = "Desolace",           minCast = 130, guaranteed = 225 },
    { name = "Dustwallow Marsh",   minCast = 130, guaranteed = 225 },
    { name = "Stranglethorn Vale", minCast = 130, guaranteed = 225 },
    { name = "Swamp of Sorrows",   minCast = 130, guaranteed = 225 },
    { name = "Thousand Needles",   minCast = 130, guaranteed = 225 },
    -- Dungeons
    { name = "Scarlet Monastery",  minCast = 130, guaranteed = 225 },

    -- ── Tier 4: minCast 205, guaranteed 300 ──────────────────────────────────
    { name = "Azshara",                           minCast = 205, guaranteed = 300 },
    { name = "Felwood",                           minCast = 205, guaranteed = 300 },
    { name = "Feralas",                           minCast = 205, guaranteed = 300 },
    { name = "Moonglade",                         minCast = 205, guaranteed = 300 },
    { name = "Stranglethorn Vale (Jaguero Isle)", minCast = 205, guaranteed = 300 },
    { name = "Tanaris",                           minCast = 205, guaranteed = 300 },
    { name = "The Hinterlands",                   minCast = 205, guaranteed = 300 },
    { name = "Un'Goro Crater",                    minCast = 205, guaranteed = 300 },
    { name = "Western Plaguelands",               minCast = 205, guaranteed = 300 },
    -- Dungeons
    { name = "Maraudon",                          minCast = 205, guaranteed = 300 },
    { name = "Sunken Temple",                     minCast = 205, guaranteed = 300 },

    -- ── Tier 5: minCast 330, guaranteed 425 ──────────────────────────────────
    { name = "Azshara (Bay of Storms)",     minCast = 330, guaranteed = 425 },
    { name = "Burning Steppes",             minCast = 330, guaranteed = 425 },
    { name = "Deadwind Pass",               minCast = 330, guaranteed = 425 },
    { name = "Eastern Plaguelands",         minCast = 330, guaranteed = 425 },
    { name = "Feralas (Jademir Lake)",      minCast = 330, guaranteed = 425 },
    { name = "Silithus",                    minCast = 330, guaranteed = 425 },
    { name = "Winterspring",                minCast = 330, guaranteed = 425 },
    -- Dungeons
    { name = "Scholomance",                 minCast = 330, guaranteed = 425 },
    { name = "Stratholme",                  minCast = 330, guaranteed = 425 },
    -- Raids
    { name = "Zul'Gurub",                   minCast = 330, guaranteed = 425 },
}

ACC_Data.FishingLures = {
    {
        name = "Shiny Bauble", itemId = 6529, displayGroup = 1,
        sources = { { type = "vendor", vendors = { { name = "Fishing supply vendors", zone = "Most zones" } } } },
    },
    {
        name = "Nightcrawlers", itemId = 6530, displayGroup = 1,
        sources = {
            { type = "vendor", vendors = { { name = "Fishing supply vendors", zone = "Most zones" } } },
            { type = "note",   text = "Also drops from undead creatures" },
        },
    },
    {
        name = "Bright Baubles", itemId = 6532, displayGroup = 1,
        sources = { { type = "vendor", vendors = { { name = "Fishing supply vendors", zone = "Most zones" } } } },
    },
    {
        name = "Aquadynamic Fish Attractor", itemId = 6533, displayGroup = 1,
        sources = {
            { type = "craft",  prof = "Engineering" },
            { type = "vendor", vendors = { { name = "Fishing supply vendors", zone = "Most zones" } } },
        },
    },
}

ACC_Data.FishingTournament = {
    -- Rare fish turn-ins (any Sunday during the Stranglethorn Fishing Extravaganza)
    {
        name = "Nat Pagle's Extreme Anglin' Boots", itemId = 19969, displayGroup = 1,
        sources = { { type = "quest", quests = { { id = 8225, name = "Rare Fish - Brownell's Blue Striped Racer", level = 60 } } } },
    },
    {
        name = "High Test Eternium Fishing Line", itemId = 19971, displayGroup = 1,
        sources = { { type = "quest", quests = { { id = 8224, name = "Rare Fish - Dezian Queenfish", level = 60 } } } },
    },
    {
        name = "Lucky Fishing Hat", itemId = 19972, displayGroup = 1,
        sources = { { type = "quest", quests = { { id = 8221, name = "Rare Fish - Keefer's Angelfish", level = 60 } } } },
    },
    -- First-place winner rewards (choice of one via the Master Angler quest)
    {
        name = "Arcanite Fishing Pole", itemId = 19970, displayGroup = 2,
        sources = { { type = "quest", quests = { { id = 8193, name = "Master Angler", level = 60 } } } },
    },
    {
        name = "Hook of the Master Angler", itemId = 19979, displayGroup = 2,
        sources = { { type = "quest", quests = { { id = 8193, name = "Master Angler", level = 60 } } } },
    },
}
