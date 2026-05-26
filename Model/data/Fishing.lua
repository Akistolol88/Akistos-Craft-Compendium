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
    -- Cities (no pools)
    { name = "Darnassus",      minCast = 1, guaranteed = 96 },
    { name = "Ironforge",      minCast = 1, guaranteed = 96 },
    { name = "Orgrimmar",      minCast = 1, guaranteed = 96 },
    { name = "Stormwind City", minCast = 1, guaranteed = 96 },
    { name = "Thunder Bluff",  minCast = 1, guaranteed = 96 },
    { name = "Undercity",      minCast = 1, guaranteed = 96 },
    -- Zones
    { name = "Darkshore",      minCast = 1, guaranteed = 96,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"       },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"        },
          { name = "Sagefish School",        fish = "Raw Sagefish"           },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk"   },
      },
    },
    { name = "Dun Morogh",        minCast = 1, guaranteed = 96 },
    { name = "Durotar",           minCast = 1, guaranteed = 96 },
    { name = "Elwynn Forest",     minCast = 1, guaranteed = 96 },
    { name = "Loch Modan",        minCast = 1, guaranteed = 96,
      pools = {
          { name = "Sagefish School", fish = "Raw Sagefish" },
      },
    },
    { name = "Mulgore",           minCast = 1, guaranteed = 96 },
    { name = "Silverpine Forest", minCast = 1, guaranteed = 96,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Teldrassil",        minCast = 1, guaranteed = 96 },
    { name = "The Barrens",       minCast = 1, guaranteed = 96,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "School of Deviate Fish", fish = "Deviate Fish",         note = "Oases only" },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Tirisfal Glades",   minCast = 1, guaranteed = 96 },
    { name = "Westfall",          minCast = 1, guaranteed = 96,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk" },
      },
    },
    -- Dungeons
    { name = "Blackfathom Deeps", minCast = 1, guaranteed = 96 },
    { name = "The Deadmines",     minCast = 1, guaranteed = 96 },
    { name = "Wailing Caverns",   minCast = 1, guaranteed = 96 },

    -- ── Tier 2: minCast 55, guaranteed 150 ───────────────────────────────────
    { name = "Ashenvale",           minCast = 55, guaranteed = 150,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Schooner Wreckage Pool", fish = "Watertight Trunk"     },
      },
    },
    { name = "Duskwood",            minCast = 55, guaranteed = 150,
      pools = {
          { name = "Sagefish School",      fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool", fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Hillsbrad Foothills", minCast = 55, guaranteed = 150,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Schooner Wreckage Pool", fish = "Watertight Trunk"     },
      },
    },
    { name = "Redridge Mountains",  minCast = 55, guaranteed = 150,
      pools = {
          { name = "Sagefish School",      fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool", fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Stonetalon Mountains", minCast = 55, guaranteed = 150,
      pools = {
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish"                       },
          { name = "Oil Spill (Cragpool Lake)", fish = "Firefin Snapper", note = "Windshear Crag"   },
          { name = "Schooner Wreckage Pool",    fish = "Watertight Trunk"                           },
      },
    },
    { name = "Wetlands",            minCast = 55, guaranteed = 150,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Schooner Wreckage Pool", fish = "Watertight Trunk"     },
      },
    },

    -- ── Tier 3: minCast 130, guaranteed 225 ──────────────────────────────────
    { name = "Alterac Mountains", minCast = 130, guaranteed = 225,
      pools = {
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
      },
    },
    { name = "Arathi Highlands",  minCast = 130, guaranteed = 225,
      pools = {
          { name = "Firefin Snapper School",  fish = "Firefin Snapper"                           },
          { name = "Oily Blackmouth School",  fish = "Oily Blackmouth"                            },
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish"                       },
          { name = "Schooner Wreckage Pool",  fish = "Watertight Trunk", note = "Faldir's Cove"   },
      },
    },
    { name = "Desolace",          minCast = 130, guaranteed = 225,
      pools = {
          { name = "Firefin Snapper School",    fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School",    fish = "Oily Blackmouth"      },
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish" },
          { name = "Waterlogged Wreckage Pool", fish = "Iron Bound Trunk"     },
      },
    },
    { name = "Dustwallow Marsh",  minCast = 130, guaranteed = 225,
      pools = {
          { name = "Firefin Snapper School",    fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School",    fish = "Oily Blackmouth"      },
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish" },
          { name = "Waterlogged Wreckage Pool", fish = "Iron Bound Trunk"     },
      },
    },
    { name = "Stranglethorn Vale", minCast = 130, guaranteed = 225,
      pools = {
          { name = "Mixed Ocean School",      fish = "Firefin Snapper + Oily Blackmouth" },
          { name = "Sagefish School",         fish = "Raw Sagefish"                      },
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish"              },
          { name = "Bloodsail Wreckage Pool", fish = "Iron Bound Trunk"                  },
      },
    },
    { name = "Swamp of Sorrows",   minCast = 130, guaranteed = 225,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"    },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"     },
          { name = "Stonescale Eel Swarm",   fish = "Stonescale Eel"      },
          { name = "Floating Wreckage Pool", fish = "Mithril Bound Trunk" },
      },
    },
    { name = "Thousand Needles",   minCast = 130, guaranteed = 225,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"    },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"     },
          { name = "Stonescale Eel Swarm",   fish = "Stonescale Eel"      },
          { name = "Floating Wreckage Pool", fish = "Mithril Bound Trunk" },
      },
    },
    -- Dungeons
    { name = "Scarlet Monastery", minCast = 130, guaranteed = 225 },

    -- ── Tier 4: minCast 205, guaranteed 300 ──────────────────────────────────
    { name = "Azshara",                           minCast = 205, guaranteed = 300,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Felwood",                           minCast = 205, guaranteed = 300 },
    { name = "Feralas",                           minCast = 205, guaranteed = 300,
      pools = {
          { name = "Firefin Snapper School",    fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School",    fish = "Oily Blackmouth"      },
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish" },
          { name = "Waterlogged Wreckage Pool", fish = "Iron Bound Trunk"     },
      },
    },
    { name = "Moonglade",                         minCast = 205, guaranteed = 300,
      pools = {
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
      },
    },
    { name = "Stranglethorn Vale (Jaguero Isle)", minCast = 205, guaranteed = 300 },
    { name = "Tanaris",                           minCast = 205, guaranteed = 300,
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"    },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"     },
          { name = "Stonescale Eel Swarm",   fish = "Stonescale Eel"      },
          { name = "Floating Wreckage Pool", fish = "Mithril Bound Trunk" },
      },
    },
    { name = "The Hinterlands",                   minCast = 205, guaranteed = 300,
      pools = {
          { name = "Firefin Snapper School",  fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School",  fish = "Oily Blackmouth"      },
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
      },
    },
    { name = "Un'Goro Crater",                    minCast = 205, guaranteed = 300,
      pools = {
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
      },
    },
    { name = "Western Plaguelands",               minCast = 205, guaranteed = 300,
      pools = {
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish" },
          { name = "Waterlogged Wreckage Pool", fish = "Iron Bound Trunk"     },
      },
    },
    -- Dungeons
    { name = "Maraudon",  minCast = 205, guaranteed = 300 },
    { name = "Sunken Temple", minCast = 205, guaranteed = 300 },

    -- ── Tier 5: minCast 330, guaranteed 425 ──────────────────────────────────
    { name = "Azshara (Bay of Storms)", minCast = 330, guaranteed = 425 },
    { name = "Deadwind Pass",           minCast = 330, guaranteed = 425 },
    { name = "Eastern Plaguelands",     minCast = 330, guaranteed = 425,
      pools = {
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
          { name = "Floating Wreckage Pool",  fish = "Mithril Bound Trunk"  },
      },
    },
    { name = "Feralas (Jademir Lake)", minCast = 330, guaranteed = 425 },
    { name = "Silithus",               minCast = 330, guaranteed = 425 },
    { name = "Winterspring",           minCast = 330, guaranteed = 425 },
    -- Dungeons
    { name = "Scholomance", minCast = 330, guaranteed = 425 },
    { name = "Stratholme",  minCast = 330, guaranteed = 425 },
    -- Raids
    { name = "Zul'Gurub",   minCast = 330, guaranteed = 425 },
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

-- FishingCatches fields:
--   name          display name
--   itemId        item ID (icon resolution + shift-click)
--   minSkill      minimum fishing skill to catch this fish in any zone
--   avoidGetaway  skill needed to never get "fish got away" in the best farming zones
--   waterType     "coastal" | "inland" | "both"
--   pool          pool name if primarily caught from pools (nil = open water)
--   timeOfDay     "night" | "day" | nil  (nil = catchable any time)
--   season        { start="MM-DD", stop="MM-DD", label="..." } or nil
--   zones         recommended farming zones (best catch rate)
--   note          optional clarification

ACC_Data.FishingCatches = {

    -- ── minSkill 1, avoidGetaway 25 ──────────────────────────────────────────
    {
        name = "Raw Brilliant Smallfish", itemId = 6291,
        minSkill = 1, avoidGetaway = 25, waterType = "inland",
        zones = {
            "Dun Morogh", "Mulgore", "Elwynn Forest", "Tirisfal Glades",
            "Teldrassil", "Durotar", "Duskwood", "Darnassus",
            "Orgrimmar", "Stormwind City", "Thunder Bluff", "Undercity",
            "Loch Modan", "The Barrens", "Darkshore", "Silverpine Forest",
            "Westfall", "Blackfathom Deeps", "The Deadmines", "Wailing Caverns",
        },
        zoneRates = {
            ["Dun Morogh"] = 60.0, ["Mulgore"] = 60.0, ["Elwynn Forest"] = 59.0,
            ["Tirisfal Glades"] = 45.0, ["Teldrassil"] = 26.0, ["Durotar"] = 22.0,
            ["Duskwood"] = 20.0, ["Darnassus"] = 17.0, ["Orgrimmar"] = 17.0,
            ["Stormwind City"] = 17.0, ["Thunder Bluff"] = 17.0, ["Undercity"] = 12.0,
            ["Loch Modan"] = 9.0, ["The Barrens"] = 5.0, ["Darkshore"] = 3.0,
            ["Silverpine Forest"] = 1.3, ["Westfall"] = 1.2,
        },
    },
    {
        name = "Raw Slitherskin Mackerel", itemId = 6303,
        minSkill = 1, avoidGetaway = 25, waterType = "coastal",
        zones = {
            "Durotar", "Teldrassil", "Westfall", "Darkshore",
            "Silverpine Forest", "The Barrens", "Tirisfal Glades",
        },
        zoneRates = {
            ["Durotar"] = 60.0, ["Teldrassil"] = 56.0, ["Westfall"] = 14.0,
            ["Darkshore"] = 13.0, ["Silverpine Forest"] = 12.0, ["The Barrens"] = 5.0,
            ["Tirisfal Glades"] = 1.3,
        },
    },

    -- ── minSkill 1, avoidGetaway 75 ──────────────────────────────────────────
    {
        name = "Raw Longjaw Mud Snapper", itemId = 6289,
        minSkill = 1, avoidGetaway = 75, waterType = "inland",
        zones = {
            "Darnassus", "Orgrimmar", "Stormwind City", "Thunder Bluff",
            "Undercity", "Dun Morogh", "Mulgore", "Elwynn Forest",
            "Redridge Mountains", "Duskwood", "Loch Modan", "Tirisfal Glades",
            "Stonetalon Mountains", "Ashenvale", "The Barrens", "Teldrassil",
            "Durotar", "Darkshore", "Hillsbrad Foothills", "Silverpine Forest",
            "Westfall", "Wetlands", "Blackfathom Deeps", "The Deadmines",
            "Wailing Caverns",
        },
        zoneRates = {
            ["Darnassus"] = 60.0, ["Orgrimmar"] = 60.0, ["Stormwind City"] = 60.0,
            ["Thunder Bluff"] = 60.0, ["Undercity"] = 42.0, ["Dun Morogh"] = 38.0,
            ["Mulgore"] = 38.0, ["Elwynn Forest"] = 37.0, ["Redridge Mountains"] = 35.0,
            ["Duskwood"] = 30.0, ["Loch Modan"] = 30.0, ["Tirisfal Glades"] = 29.0,
            ["Stonetalon Mountains"] = 27.0, ["Ashenvale"] = 21.0, ["The Barrens"] = 18.0,
            ["Teldrassil"] = 16.0, ["Durotar"] = 15.0, ["Darkshore"] = 10.0,
            ["Hillsbrad Foothills"] = 7.0, ["Silverpine Forest"] = 5.0, ["Westfall"] = 4.0,
            ["Wetlands"] = 1.0,
        },
    },
    {
        name = "Raw Rainbow Fin Albacore", itemId = 6361,
        minSkill = 1, avoidGetaway = 75, waterType = "coastal",
        zones = {
            "Wetlands", "Westfall", "Ashenvale", "Darkshore",
            "Silverpine Forest", "Hillsbrad Foothills", "The Barrens",
        },
        zoneRates = {
            ["Wetlands"] = 49.0, ["Westfall"] = 20.0, ["Ashenvale"] = 19.0,
            ["Darkshore"] = 19.0, ["Silverpine Forest"] = 19.0, ["Hillsbrad Foothills"] = 12.0,
            ["The Barrens"] = 8.0,
        },
    },
    {
        name = "Deviate Fish", itemId = 6522,
        minSkill = 1, avoidGetaway = 75, waterType = "inland",
        pool = "School of Deviate Fish",
        zones = { "The Barrens", "Undercity" },
        zoneRates = { ["The Barrens"] = 27.0, ["Undercity"] = 9.0 },
        note = "Oases only: Forgotten Pools, Stagnant Oasis, Lushwater Oasis",
    },
    {
        name = "Oily Blackmouth", itemId = 6358,
        minSkill = 1, avoidGetaway = 75, waterType = "coastal",
        pool = "Oily Blackmouth School",
        zones = {
            "Westfall", "Silverpine Forest", "Wetlands", "The Barrens",
            "Darkshore", "Hillsbrad Foothills", "Stranglethorn Vale", "Desolace",
            "Dustwallow Marsh", "Felwood", "Moonglade", "Swamp of Sorrows",
            "Un'Goro Crater", "Western Plaguelands", "Feralas", "Ashenvale",
            "Tanaris", "Arathi Highlands", "The Hinterlands", "Azshara",
        },
        zoneRates = {
            ["Westfall"] = 41.0, ["Silverpine Forest"] = 36.0, ["Wetlands"] = 24.0,
            ["The Barrens"] = 18.0, ["Darkshore"] = 16.0, ["Hillsbrad Foothills"] = 16.0,
            ["Stranglethorn Vale"] = 16.0, ["Desolace"] = 11.0, ["Dustwallow Marsh"] = 10.0,
            ["Felwood"] = 10.0, ["Moonglade"] = 10.0, ["Swamp of Sorrows"] = 10.0,
            ["Un'Goro Crater"] = 10.0, ["Western Plaguelands"] = 10.0, ["Feralas"] = 9.0,
            ["Ashenvale"] = 8.0, ["Tanaris"] = 8.0, ["Arathi Highlands"] = 5.0,
            ["The Hinterlands"] = 5.0, ["Azshara"] = 1.7,
        },
    },
    {
        name = "Raw Sagefish", itemId = 21071,
        minSkill = 1, avoidGetaway = 75, waterType = "inland",
        pool = "Sagefish School",
        zones = {
            "Hillsbrad Foothills", "Loch Modan", "Stonetalon Mountains", "Ashenvale",
            "Silverpine Forest",
        },
        zoneRates = {
            ["Hillsbrad Foothills"] = 25.0, ["Loch Modan"] = 21.0, ["Stonetalon Mountains"] = 7.0,
            ["Ashenvale"] = 6.0, ["Silverpine Forest"] = 5.0,
        },
    },
    {
        name = "Raw Loch Frenzy", itemId = 6317,
        minSkill = 1, avoidGetaway = 75, waterType = "inland",
        zones = { "Loch Modan" },
        zoneRates = { ["Loch Modan"] = 22.0 },
        note = "Loch Modan only",
    },

    -- ── minSkill 55, avoidGetaway 150 ─────────────────────────────────────────
    {
        name = "Firefin Snapper", itemId = 6359,
        minSkill = 55, avoidGetaway = 150, waterType = "coastal",
        pool = "Firefin Snapper School",
        zones = {
            "Stranglethorn Vale", "Wetlands", "Desolace", "Tanaris",
            "Hillsbrad Foothills", "Dustwallow Marsh", "Swamp of Sorrows", "Stonetalon Mountains",
            "Arathi Highlands", "Feralas", "The Hinterlands", "Ashenvale",
            "Azshara",
        },
        zoneRates = {
            ["Stranglethorn Vale"] = 18.0, ["Wetlands"] = 17.0, ["Desolace"] = 15.0,
            ["Tanaris"] = 14.0, ["Hillsbrad Foothills"] = 12.0, ["Dustwallow Marsh"] = 11.0,
            ["Swamp of Sorrows"] = 10.0, ["Stonetalon Mountains"] = 9.0, ["Arathi Highlands"] = 6.0,
            ["Feralas"] = 5.0, ["The Hinterlands"] = 5.0, ["Ashenvale"] = 3.0,
            ["Azshara"] = 3.0,
        },
        note = "In Stonetalon found inland in Oil Spills at Cragpool Lake",
    },
    {
        name = "Raw Bristle Whisker Catfish", itemId = 6308,
        minSkill = 55, avoidGetaway = 150, waterType = "inland",
        zones = {
            "Redridge Mountains", "Stonetalon Mountains", "Duskwood", "Ashenvale",
            "Thousand Needles", "Arathi Highlands", "Darnassus", "Orgrimmar",
            "Stormwind City", "Thunder Bluff", "Undercity", "Desolace",
            "Dustwallow Marsh", "Hillsbrad Foothills", "Alterac Mountains", "Loch Modan",
            "The Barrens", "Darkshore", "Swamp of Sorrows", "Silverpine Forest",
            "Wetlands", "Westfall", "Stranglethorn Vale", "Scarlet Monastery",
        },
        zoneRates = {
            ["Redridge Mountains"] = 64.0, ["Stonetalon Mountains"] = 49.0, ["Duskwood"] = 47.0,
            ["Ashenvale"] = 39.0, ["Thousand Needles"] = 35.0, ["Arathi Highlands"] = 26.0,
            ["Darnassus"] = 22.0, ["Orgrimmar"] = 22.0, ["Stormwind City"] = 22.0,
            ["Thunder Bluff"] = 22.0, ["Undercity"] = 15.0, ["Desolace"] = 14.0,
            ["Dustwallow Marsh"] = 13.0, ["Hillsbrad Foothills"] = 13.0, ["Alterac Mountains"] = 12.0,
            ["Loch Modan"] = 12.0, ["The Barrens"] = 6.0, ["Darkshore"] = 4.0,
            ["Swamp of Sorrows"] = 4.0, ["Silverpine Forest"] = 1.9, ["Wetlands"] = 1.8,
            ["Westfall"] = 1.7, ["Stranglethorn Vale"] = 1.5,
        },
    },

    -- ── minSkill 130, avoidGetaway 225 ────────────────────────────────────────
    {
        name = "Raw Greater Sagefish", itemId = 21153,
        minSkill = 130, avoidGetaway = 225, waterType = "inland",
        pool = "Greater Sagefish School",
        zones = { "Alterac Mountains", "Stranglethorn Vale" },
        zoneRates = { ["Alterac Mountains"] = 50.0, ["Stranglethorn Vale"] = 5.0 },
    },
    {
        name = "Raw Mithril Head Trout", itemId = 8365,
        minSkill = 130, avoidGetaway = 225, waterType = "inland",
        zones = {
            "Thousand Needles", "Arathi Highlands", "Desolace", "Dustwallow Marsh",
            "Alterac Mountains", "Felwood", "Moonglade", "Un'Goro Crater",
            "Western Plaguelands", "Swamp of Sorrows", "Feralas", "The Hinterlands",
            "Stranglethorn Vale", "Tirisfal Glades", "Maraudon", "Scarlet Monastery",
            "Sunken Temple",
        },
        zoneRates = {
            ["Thousand Needles"] = 63.0, ["Arathi Highlands"] = 46.0, ["Desolace"] = 27.0,
            ["Dustwallow Marsh"] = 24.0, ["Alterac Mountains"] = 23.0, ["Felwood"] = 10.0,
            ["Moonglade"] = 10.0, ["Un'Goro Crater"] = 10.0, ["Western Plaguelands"] = 10.0,
            ["Swamp of Sorrows"] = 8.0, ["Feralas"] = 6.0, ["The Hinterlands"] = 5.0,
            ["Stranglethorn Vale"] = 3.0, ["Tirisfal Glades"] = 1.2,
        },
    },
    {
        name = "Raw Rockscale Cod", itemId = 6362,
        minSkill = 130, avoidGetaway = 225, waterType = "coastal",
        zones = {
            "Swamp of Sorrows", "Dustwallow Marsh", "Desolace", "Stranglethorn Vale",
            "Arathi Highlands", "Tanaris", "The Hinterlands", "Tirisfal Glades",
            "Azshara", "Feralas",
        },
        zoneRates = {
            ["Swamp of Sorrows"] = 49.0, ["Dustwallow Marsh"] = 27.0, ["Desolace"] = 18.0,
            ["Stranglethorn Vale"] = 18.0, ["Arathi Highlands"] = 9.0, ["Tanaris"] = 7.0,
            ["The Hinterlands"] = 5.0, ["Tirisfal Glades"] = 5.0, ["Azshara"] = 2.0,
            ["Feralas"] = 2.0,
        },
    },

    -- ── minSkill 205, avoidGetaway 300 ────────────────────────────────────────
    {
        name = "Raw Glossy Mightfish", itemId = 13754,
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        zones = { "Tanaris", "The Hinterlands", "Azshara", "Feralas" },
        zoneRates = {
            ["Tanaris"] = 6.0, ["The Hinterlands"] = 6.0, ["Azshara"] = 2.0,
            ["Feralas"] = 2.0,
        },
    },
    {
        name = "Raw Redgill", itemId = 13758,
        minSkill = 205, avoidGetaway = 300, waterType = "inland",
        zones = {
            "Felwood", "Moonglade", "Un'Goro Crater", "Western Plaguelands",
            "Feralas", "The Hinterlands", "Eastern Plaguelands", "Deadwind Pass",
            "Winterspring", "Azshara", "Silithus", "Desolace",
            "Maraudon", "Sunken Temple",
        },
        zoneRates = {
            ["Felwood"] = 51.0, ["Moonglade"] = 50.0, ["Un'Goro Crater"] = 50.0,
            ["Western Plaguelands"] = 50.0, ["Feralas"] = 32.0, ["The Hinterlands"] = 24.0,
            ["Eastern Plaguelands"] = 7.0, ["Deadwind Pass"] = 5.0, ["Winterspring"] = 5.0,
            ["Azshara"] = 4.0, ["Silithus"] = 4.0, ["Desolace"] = 1.0,
        },
    },
    {
        name = "Raw Spotted Yellowtail", itemId = 4603,
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        zones = {
            "Tanaris", "The Hinterlands", "Swamp of Sorrows", "Azshara",
            "Dustwallow Marsh", "Feralas", "Stranglethorn Vale", "Desolace",
            "Arathi Highlands", "Eastern Plaguelands",
        },
        zoneRates = {
            ["Tanaris"] = 27.0, ["The Hinterlands"] = 21.0, ["Swamp of Sorrows"] = 18.0,
            ["Azshara"] = 11.0, ["Dustwallow Marsh"] = 10.0, ["Feralas"] = 9.0,
            ["Stranglethorn Vale"] = 7.0, ["Desolace"] = 6.0, ["Arathi Highlands"] = 3.0,
            ["Eastern Plaguelands"] = 3.0,
        },
    },
    {
        name = "Stonescale Eel", itemId = 13422,
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        pool = "Stonescale Eel Swarm",
        zones = {
            "Tanaris", "Azshara", "Eastern Plaguelands", "Feralas",
            "Stranglethorn Vale", "The Hinterlands",
        },
        zoneRates = {
            ["Tanaris"] = 14.0, ["Azshara"] = 12.0, ["Eastern Plaguelands"] = 11.0,
            ["Feralas"] = 5.0, ["Stranglethorn Vale"] = 5.0, ["The Hinterlands"] = 5.0,
        },
    },
    {
        name = "Raw Nightfin Snapper", itemId = 13759,
        minSkill = 205, avoidGetaway = 300, waterType = "inland",
        timeOfDay = "night",
        zones = {
            "Moonglade", "Un'Goro Crater", "Western Plaguelands", "Winterspring",
            "Deadwind Pass", "Eastern Plaguelands", "Felwood", "Feralas",
            "The Hinterlands", "Silithus", "Duskwood", "Azshara",
        },
        zoneRates = {
            ["Moonglade"] = 22.0, ["Un'Goro Crater"] = 22.0, ["Western Plaguelands"] = 20.0,
            ["Winterspring"] = 20.0, ["Deadwind Pass"] = 19.0, ["Eastern Plaguelands"] = 19.0,
            ["Felwood"] = 19.0, ["Feralas"] = 12.0, ["The Hinterlands"] = 10.0,
            ["Silithus"] = 6.0, ["Duskwood"] = 2.0, ["Azshara"] = 1.4,
        },
        note = "Best 00:00–06:00 server time; cannot catch 12:00–18:00 server time",
    },
    {
        name = "Raw Sunscale Salmon", itemId = 13760,
        minSkill = 205, avoidGetaway = 300, waterType = "inland",
        timeOfDay = "day",
        zones = {
            "Silithus", "Deadwind Pass", "Eastern Plaguelands", "Winterspring",
            "Felwood", "Western Plaguelands", "Feralas", "Moonglade",
            "Un'Goro Crater", "Blasted Lands", "The Hinterlands", "Duskwood",
        },
        zoneRates = {
            ["Silithus"] = 22.0, ["Deadwind Pass"] = 11.0, ["Eastern Plaguelands"] = 11.0,
            ["Winterspring"] = 11.0, ["Felwood"] = 9.0, ["Western Plaguelands"] = 8.0,
            ["Feralas"] = 6.0, ["Moonglade"] = 6.0, ["Un'Goro Crater"] = 6.0,
            ["Blasted Lands"] = 3.0, ["The Hinterlands"] = 3.0, ["Duskwood"] = 2.0,
        },
        note = "Cannot catch 00:00–06:00 server time; best 12:00–18:00",
    },
    {
        name = "Winter Squid", itemId = 13755,
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        season = { start = "09-22", stop = "03-20", label = "Sep 22 – Mar 20" },
        zones = { "Azshara", "Tanaris", "The Hinterlands", "Feralas" },
        zoneRates = {
            ["Azshara"] = 14.0, ["Tanaris"] = 5.0, ["The Hinterlands"] = 3.0,
            ["Feralas"] = 1.7,
        },
        note = "Cannot catch 00:00–06:00 server time (except Azshara Bay of Storms)",
    },
    {
        name = "Raw Summer Bass", itemId = 13756,
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        season = { start = "03-20", stop = "09-21", label = "Mar 20 – Sep 21" },
        zones = { "Eastern Plaguelands", "The Hinterlands", "Tanaris", "Azshara" },
        zoneRates = {
            ["Eastern Plaguelands"] = 20.0, ["The Hinterlands"] = 2.0, ["Tanaris"] = 1.6,
            ["Azshara"] = 1.1,
        },
        note = "Cannot catch 00:00–06:00 server time (except Azshara Bay of Storms)",
    },

    -- ── minSkill 330, avoidGetaway 425 ────────────────────────────────────────
    {
        name = "Zulian Mudskunk", itemId = 19975,
        minSkill = 330, avoidGetaway = 425, waterType = "inland",
        pool = "Zulian Mudskunk Pool",
        zones = { "Zul'Gurub" },
        note = "5 fish needed to summon Gahz'Ranka",
    },
    {
        name = "Raw Whitescale Salmon", itemId = 13889,
        minSkill = 330, avoidGetaway = 425, waterType = "inland",
        zones = {
            "Deadwind Pass", "Winterspring", "Eastern Plaguelands", "Silithus",
            "Duskwood", "Blasted Lands", "Zul'Gurub", "Scholomance",
            "Stratholme",
        },
        zoneRates = {
            ["Deadwind Pass"] = 40.0, ["Winterspring"] = 39.0, ["Eastern Plaguelands"] = 37.0,
            ["Silithus"] = 37.0, ["Duskwood"] = 5.0, ["Blasted Lands"] = 3.0,
        },
    },
    {
        name = "Darkclaw Lobster", itemId = 13888,
        minSkill = 330, avoidGetaway = 425, waterType = "coastal",
        zones = { "Eastern Plaguelands", "Azshara" },
        zoneRates = { ["Eastern Plaguelands"] = 45.0, ["Azshara"] = 26.0 },
    },
    {
        name = "Large Raw Mightfish", itemId = 13893,
        minSkill = 330, avoidGetaway = 425, waterType = "coastal",
        zones = { "Eastern Plaguelands", "Azshara" },
        zoneRates = { ["Eastern Plaguelands"] = 8.0, ["Azshara"] = 5.0 },
    },
}
