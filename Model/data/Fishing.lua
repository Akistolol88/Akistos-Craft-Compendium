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
        name    = "Apprentice Fishing",
        spellId = 7620,
        skill   = 1,
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
        name    = "Journeyman Fishing",
        spellId = 7734,
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
        name = "Darkwood Fishing Pole", itemId = 6366, fishingBonus = 15,
        sources = { { type = "note", text = "Fished in level 10-25 zones" } },
    },
    {
        name = "Blump Family Fishing Pole", itemId = 12225, fishingBonus = 3,
        sources = { { type = "quest", quests = {
            { id = 1141, name = "The Family and the Fishing Pole", level = 14, faction = "alliance" },
        } } },
    },
    {
        name = "Strong Fishing Pole", itemId = 6365, fishingBonus = 5,
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
    {
        name = "Arcanite Fishing Pole", itemId = 19970, fishingBonus = 35,
        sources = { { type = "quest", quests = {
            { id = 8193, name = "Master Angler", level = 60 },
        } } },
    },
}

-- FishingZones fields:
--   name        zone/city/dungeon/raid name
--   minCast     minimum fishing skill to cast (avoids most "fish got away")
--   guaranteed  minimum fishing skill for a guaranteed catch (never "fish got away")
--   note        optional clarification (e.g. specific sub-area)
--   icon        optional icon name (without "Interface\\Icons\\") used as the row icon in the browser

ACC_Data.FishingZones = {
    -- ── Tier 1: minCast 1, guaranteed 96 ─────────────────────────────────────
    -- Cities (no pools)
    { name = "Darnassus",      minCast = 1, guaranteed = 96, icon = "spell_frost_wisp"              },  -- Night Elf wisp
    { name = "Ironforge",      minCast = 1, guaranteed = 96, icon = "spell_arcane_teleportironforge"  },  -- Mage Teleport: Ironforge
    { name = "Orgrimmar",      minCast = 1, guaranteed = 96, icon = "spell_arcane_teleportorgrimmar" },  -- Warchief's Blessing
    { name = "Stormwind City", minCast = 1, guaranteed = 96, icon = "spell_arcane_teleportstormwind"   },  -- Mage Teleport: Stormwind
    { name = "Thunder Bluff",  minCast = 1, guaranteed = 96, icon = "achievement_character_tauren_male" },  -- Tauren
    { name = "Undercity",      minCast = 1, guaranteed = 96, icon = "inv_misc_head_elf_02"  },  -- Sylvanas Dark Ranger
    -- Zones
    { name = "Darkshore",      minCast = 1, guaranteed = 96, icon = "spell_frost_wisp",                -- Night Elf wisp
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"       },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"        },
          { name = "Sagefish School",        fish = "Raw Sagefish"           },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk"   },
      },
    },
    { name = "Dun Morogh",        minCast = 1, guaranteed = 96, icon = "ability_mount_mountainram"       },  -- Dwarf ram mount
    { name = "Durotar",           minCast = 1, guaranteed = 96, icon = "spell_arcane_teleportorgrimmar" },  -- Warchief's Blessing
    { name = "Elwynn Forest",     minCast = 1, guaranteed = 96, icon = "spell_arcane_teleportstormwind"   },  -- Human homeland / Stormwind
    { name = "Loch Modan",        minCast = 1, guaranteed = 96, icon = "ability_mount_mountainram",       -- Dwarf ram mount
      pools = {
          { name = "Sagefish School", fish = "Raw Sagefish" },
      },
    },
    { name = "Mulgore",           minCast = 1, guaranteed = 96, icon = "ability_hunter_pet_tallstrider"   },  -- Tallstrider (Mulgore)
    { name = "Silverpine Forest", minCast = 1, guaranteed = 96, icon = "ability_creature_cursed_01",     -- Worgen curse
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Teldrassil",        minCast = 1, guaranteed = 96, icon = "spell_frost_wisp"              },  -- Night Elf wisp
    { name = "The Barrens",       minCast = 1, guaranteed = 96, icon = "spell_arcane_teleportorgrimmar",  -- Warchief's Blessing
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "School of Deviate Fish", fish = "Deviate Fish",         note = "Oases only" },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Tirisfal Glades",   minCast = 1, guaranteed = 96, icon = "spell_arcane_teleportundercity"   },  -- Forsaken homeland / Undercity
    { name = "Westfall",          minCast = 1, guaranteed = 96, icon = "inv_misc_coin_01",               -- Gold coin / farmland wealth
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk" },
      },
    },
    -- Dungeons
    { name = "Blackfathom Deeps", minCast = 1, guaranteed = 96, icon = "spell_frost_summonwaterelemental" },  -- Water elemental
    { name = "The Deadmines",     minCast = 1, guaranteed = 96, icon = "inv_misc_bandana_01"              },  -- Defias bandana
    { name = "Wailing Caverns",   minCast = 1, guaranteed = 96, icon = "ability_hunter_pet_windserpent"  },  -- Wind serpent (Wailing Caverns)

    -- ── Tier 2: minCast 55, guaranteed 150 ───────────────────────────────────
    { name = "Ashenvale",           minCast = 55, guaranteed = 150, icon = "inv_misc_head_dragon_green",  -- Emerald dragon world boss
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Schooner Wreckage Pool", fish = "Watertight Trunk"     },
      },
    },
    { name = "Duskwood",            minCast = 55, guaranteed = 150, icon = "inv_misc_head_dragon_green",  -- Emerald dragon world boss
      pools = {
          { name = "Sagefish School",      fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool", fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Hillsbrad Foothills", minCast = 55, guaranteed = 150, icon = "inv_wand_09",                 -- Helcular's Rod
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Schooner Wreckage Pool", fish = "Watertight Trunk"     },
      },
    },
    { name = "Redridge Mountains",  minCast = 55, guaranteed = 150, icon = "inv_misc_pelt_wolf_ruin_03",   -- Gnoll/wolf pelt (Redridge gnolls)
      pools = {
          { name = "Sagefish School",      fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool", fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Stonetalon Mountains", minCast = 55, guaranteed = 150, icon = "inv_feather_12",              -- Harpy feather (Blood Feather harpies)
      pools = {
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish"                       },
          { name = "Oil Spill (Cragpool Lake)", fish = "Firefin Snapper", note = "Windshear Crag"   },
          { name = "Schooner Wreckage Pool",    fish = "Watertight Trunk"                           },
      },
    },
    { name = "Wetlands",            minCast = 55, guaranteed = 150, icon = "spell_nature_abolishmagic",   -- Swamp / nature magic
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Schooner Wreckage Pool", fish = "Watertight Trunk"     },
      },
    },

    -- ── Tier 3: minCast 130, guaranteed 225 ──────────────────────────────────
    { name = "Alterac Mountains", minCast = 130, guaranteed = 225, icon = "inv_misc_flower_03",      -- Wintersbite herb
      pools = {
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
      },
    },
    { name = "Arathi Highlands",  minCast = 130, guaranteed = 225, icon = "inv_shield_06",               -- Stromgarde / warrior shield
      pools = {
          { name = "Firefin Snapper School",  fish = "Firefin Snapper"                           },
          { name = "Oily Blackmouth School",  fish = "Oily Blackmouth"                            },
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish"                       },
          { name = "Schooner Wreckage Pool",  fish = "Watertight Trunk", note = "Faldir's Cove"   },
      },
    },
    { name = "Desolace",          minCast = 130, guaranteed = 225, icon = "inv_misc_head_centaur_01",  -- Centaur
      pools = {
          { name = "Firefin Snapper School",    fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School",    fish = "Oily Blackmouth"      },
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish" },
          { name = "Waterlogged Wreckage Pool", fish = "Iron Bound Trunk"     },
      },
    },
    { name = "Dustwallow Marsh",  minCast = 130, guaranteed = 225, icon = "inv_misc_head_dragon_black",  -- Onyxia / black dragon
      pools = {
          { name = "Firefin Snapper School",    fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School",    fish = "Oily Blackmouth"      },
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish" },
          { name = "Waterlogged Wreckage Pool", fish = "Iron Bound Trunk"     },
      },
    },
    { name = "Stranglethorn Vale", minCast = 130, guaranteed = 225, icon = "inv_misc_head_tiger_01",  -- King Bangalash (white tiger)
      pools = {
          { name = "Mixed Ocean School",      fish = "Firefin Snapper + Oily Blackmouth" },
          { name = "Sagefish School",         fish = "Raw Sagefish"                      },
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish"              },
          { name = "Bloodsail Wreckage Pool", fish = "Iron Bound Trunk"                  },
      },
    },
    { name = "Swamp of Sorrows",   minCast = 130, guaranteed = 225, icon = "inv_misc_herb_14",              -- Blindweed
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"    },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"     },
          { name = "Stonescale Eel Swarm",   fish = "Stonescale Eel"      },
          { name = "Floating Wreckage Pool", fish = "Mithril Bound Trunk" },
      },
    },
    { name = "Thousand Needles",   minCast = 130, guaranteed = 225, icon = "inv_misc_head_tauren_01",     -- Tauren
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"    },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"     },
          { name = "Stonescale Eel Swarm",   fish = "Stonescale Eel"      },
          { name = "Floating Wreckage Pool", fish = "Mithril Bound Trunk" },
      },
    },
    -- Dungeons
    { name = "Scarlet Monastery", minCast = 130, guaranteed = 225, icon = "spell_holy_holybolt"             },  -- Holy Light / Scarlet Crusade

    -- ── Tier 4: minCast 205, guaranteed 300 ──────────────────────────────────
    { name = "Azshara",                           minCast = 205, guaranteed = 300, icon = "inv_misc_head_dragon_blue",  -- Azuregos blue dragon
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"      },
          { name = "Sagefish School",        fish = "Raw Sagefish"         },
          { name = "Floating Debris Pool",   fish = "Tightly Sealed Trunk" },
      },
    },
    { name = "Felwood",                           minCast = 205, guaranteed = 300, icon = "inv_fabric_felrag"           },  -- Felcloth
    { name = "Feralas",                           minCast = 205, guaranteed = 300, icon = "inv_misc_head_dragon_green",  -- Emerald dragon world boss
      pools = {
          { name = "Firefin Snapper School",    fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School",    fish = "Oily Blackmouth"      },
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish" },
          { name = "Waterlogged Wreckage Pool", fish = "Iron Bound Trunk"     },
      },
    },
    { name = "Moonglade",                         minCast = 205, guaranteed = 300, icon = "spell_arcane_teleportmoonglade",  -- Teleport: Moonglade druid spell
      pools = {
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
      },
    },
    { name = "Stranglethorn Vale (Jaguero Isle)", minCast = 205, guaranteed = 300, icon = "ability_hunter_pet_gorilla"  },  -- Gorilla (Jaguero Isle)
    { name = "Tanaris",                           minCast = 205, guaranteed = 300, icon = "inv_misc_head_dragon_bronze",  -- Brood Affliction: Bronze / Nozdormu
      pools = {
          { name = "Firefin Snapper School", fish = "Firefin Snapper"    },
          { name = "Oily Blackmouth School", fish = "Oily Blackmouth"     },
          { name = "Stonescale Eel Swarm",   fish = "Stonescale Eel"      },
          { name = "Floating Wreckage Pool", fish = "Mithril Bound Trunk" },
      },
    },
    { name = "The Hinterlands",                   minCast = 205, guaranteed = 300, icon = "inv_misc_head_dragon_green",  -- Emerald dragon world boss
      pools = {
          { name = "Firefin Snapper School",  fish = "Firefin Snapper"     },
          { name = "Oily Blackmouth School",  fish = "Oily Blackmouth"      },
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
      },
    },
    { name = "Un'Goro Crater",                    minCast = 205, guaranteed = 300, icon = "ability_mount_raptor",       -- Swift Razzashi Raptor / dinosaur
      pools = {
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
      },
    },
    { name = "Western Plaguelands",               minCast = 205, guaranteed = 300, icon = "inv_misc_herb_plaguebloom",  -- Plaguebloom herb (Plaguelands exclusive)
      pools = {
          { name = "Greater Sagefish School",   fish = "Raw Greater Sagefish" },
          { name = "Waterlogged Wreckage Pool", fish = "Iron Bound Trunk"     },
      },
    },
    -- Dungeons
    { name = "Maraudon",     minCast = 205, guaranteed = 300, icon = "inv_staff_16"                  },  -- Scepter of Celebras attunement
    { name = "Sunken Temple", minCast = 205, guaranteed = 300, icon = "inv_misc_head_dragon_green"  },  -- Green dragonkin (Shade of Eranikus)

    -- ── Tier 5: minCast 330, guaranteed 425 ──────────────────────────────────
    { name = "Azshara (Bay of Storms)", minCast = 330, guaranteed = 425, icon = "inv_misc_fish_11"             },  -- Stonescale Eel
    { name = "Deadwind Pass",           minCast = 330, guaranteed = 425, icon = "inv_misc_bone_elfskull_01"   },  -- Skull of Impending Doom / dark ominous
    { name = "Eastern Plaguelands",     minCast = 330, guaranteed = 425, icon = "achievement_dungeon_naxxramas_10man",  -- Naxxramas
      pools = {
          { name = "Greater Sagefish School", fish = "Raw Greater Sagefish" },
          { name = "Floating Wreckage Pool",  fish = "Mithril Bound Trunk"  },
      },
    },
    { name = "Feralas (Jademir Lake)", minCast = 330, guaranteed = 425, icon = "inv_misc_head_dragon_green" },  -- Emerald dragon world boss
    { name = "Silithus",               minCast = 330, guaranteed = 425, icon = "spell_nature_insectswarm"   },  -- Insect Swarm / silithid bugs
    { name = "Winterspring",           minCast = 330, guaranteed = 425, icon = "inv_potion_92"              },  -- ⚠️ Winterfall Firewater (verify in-game)
    -- Dungeons
    { name = "Scholomance", minCast = 330, guaranteed = 425, icon = "inv_misc_book_01"                 },  -- Dark magic / necromancy school
    { name = "Stratholme",  minCast = 330, guaranteed = 425, icon = "inv_misc_gem_pearl_03"         },  -- Righteous Orb
    -- Raids
    { name = "Zul'Gurub",   minCast = 330, guaranteed = 425, icon = "ability_mount_jungletiger"   },  -- Swift Zulian Tiger
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
--   season        { start="MM-DD", stop="MM-DD", label="Name (dates)", color="rrggbb" } or nil
--                 color drives the season-name text; date range always renders orange
--   zones         recommended farming zones (best catch rate)
--   zoneRates     catch-rate % per zone from Wowhead Classic ERA data
--   note          soft time preference or clarification (shown yellow; not a hard restriction)

ACC_Data.FishingCatches = {

    -- ── minSkill 1, avoidGetaway 25 ──────────────────────────────────────────
    {
        name = "Raw Brilliant Smallfish", itemId = 6291,
        icon = "inv_misc_fish_08",
        minSkill = 1, avoidGetaway = 25, waterType = "inland",
        zones = {
            "Dun Morogh", "Mulgore", "Elwynn Forest", "Tirisfal Glades",
            "Teldrassil", "Durotar", "Darnassus", "Orgrimmar",
            "Stormwind City", "Thunder Bluff", "Undercity", "The Barrens",
            "Darkshore", "Blackfathom Deeps", "The Deadmines", "Wailing Caverns",
        },
        zoneRates = {
            ["Dun Morogh"] = 60.0, ["Mulgore"] = 60.0, ["Elwynn Forest"] = 59.0,
            ["Tirisfal Glades"] = 45.0, ["Teldrassil"] = 26.0, ["Durotar"] = 22.0,
            ["Darnassus"] = 17.0, ["Orgrimmar"] = 17.0, ["Stormwind City"] = 17.0,
            ["Thunder Bluff"] = 17.0, ["Undercity"] = 12.0, ["The Barrens"] = 5.0,
            ["Darkshore"] = 3.0,
        },
    },
    {
        name = "Raw Slitherskin Mackerel", itemId = 6303,
        icon = "inv_misc_fish_24",
        minSkill = 1, avoidGetaway = 25, waterType = "coastal",
        zones = {
            "Durotar", "Teldrassil", "Westfall", "Darkshore",
            "Silverpine Forest", "The Barrens",
        },
        zoneRates = {
            ["Durotar"] = 60.0, ["Teldrassil"] = 56.0, ["Westfall"] = 14.0,
            ["Darkshore"] = 13.0, ["Silverpine Forest"] = 12.0, ["The Barrens"] = 5.0,
        },
    },

    -- ── minSkill 1, avoidGetaway 75 ──────────────────────────────────────────
    {
        name = "Raw Longjaw Mud Snapper", itemId = 6289,
        icon = "inv_misc_fish_32",
        minSkill = 1, avoidGetaway = 75, waterType = "inland",
        zones = {
            "Darnassus", "Orgrimmar", "Stormwind City", "Thunder Bluff",
            "Undercity", "Dun Morogh", "Mulgore", "Elwynn Forest",
            "Redridge Mountains", "Loch Modan", "Tirisfal Glades", "Stonetalon Mountains",
            "Ashenvale", "The Barrens", "Teldrassil", "Durotar",
            "Darkshore", "Hillsbrad Foothills", "Blackfathom Deeps", "The Deadmines",
            "Wailing Caverns",
        },
        zoneRates = {
            ["Darnassus"] = 60.0, ["Orgrimmar"] = 60.0, ["Stormwind City"] = 60.0,
            ["Thunder Bluff"] = 60.0, ["Undercity"] = 42.0, ["Dun Morogh"] = 38.0,
            ["Mulgore"] = 38.0, ["Elwynn Forest"] = 37.0, ["Redridge Mountains"] = 35.0,
            ["Loch Modan"] = 30.0, ["Tirisfal Glades"] = 29.0, ["Stonetalon Mountains"] = 27.0,
            ["Ashenvale"] = 21.0, ["The Barrens"] = 18.0, ["Teldrassil"] = 16.0,
            ["Durotar"] = 15.0, ["Darkshore"] = 10.0, ["Hillsbrad Foothills"] = 7.0,
        },
    },
    {
        name = "Raw Rainbow Fin Albacore", itemId = 6361,
        icon = "inv_misc_fish_25",
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
        icon = "inv_misc_monsterhead_01",
        minSkill = 1, avoidGetaway = 75, waterType = "inland",
        pool = "School of Deviate Fish",
        zones = { "The Barrens" },
        zoneRates = { ["The Barrens"] = 27.0 },
        note = "Oases only: Forgotten Pools, Stagnant Oasis, Lushwater Oasis",
    },
    {
        name = "Oily Blackmouth", itemId = 6358,
        icon = "inv_misc_monsterhead_04",
        minSkill = 1, avoidGetaway = 75, waterType = "coastal",
        pool = "Oily Blackmouth School",
        zones = {
            "Westfall", "Silverpine Forest", "Wetlands", "The Barrens",
            "Darkshore", "Hillsbrad Foothills", "Stranglethorn Vale", "Desolace",
            "Dustwallow Marsh", "Felwood", "Moonglade", "Swamp of Sorrows",
            "Western Plaguelands", "Feralas", "Ashenvale", "Tanaris",
            "The Hinterlands", "Azshara",
        },
        zoneRates = {
            ["Westfall"] = 41.0, ["Silverpine Forest"] = 36.0, ["Wetlands"] = 24.0,
            ["The Barrens"] = 18.0, ["Darkshore"] = 16.0, ["Hillsbrad Foothills"] = 16.0,
            ["Stranglethorn Vale"] = 16.0, ["Desolace"] = 11.0, ["Dustwallow Marsh"] = 10.0,
            ["Felwood"] = 10.0, ["Moonglade"] = 10.0, ["Swamp of Sorrows"] = 10.0,
            ["Western Plaguelands"] = 10.0, ["Feralas"] = 9.0, ["Ashenvale"] = 8.0,
            ["Tanaris"] = 8.0, ["The Hinterlands"] = 5.0, ["Azshara"] = 1.7,
        },
    },
    {
        name = "Raw Sagefish", itemId = 21071,
        icon = "inv_misc_fish_20",
        minSkill = 1, avoidGetaway = 75, waterType = "inland",
        pool = "Sagefish School",
        zones = { "Hillsbrad Foothills", "Loch Modan", "Stonetalon Mountains", "Ashenvale" },
        zoneRates = {
            ["Hillsbrad Foothills"] = 25.0, ["Loch Modan"] = 21.0, ["Stonetalon Mountains"] = 7.0,
            ["Ashenvale"] = 6.0,
        },
    },
    {
        name = "Raw Loch Frenzy", itemId = 6317,
        icon = "inv_misc_fish_03",
        minSkill = 1, avoidGetaway = 75, waterType = "inland",
        zones = { "Loch Modan" },
        zoneRates = { ["Loch Modan"] = 22.0 },
        note = "Loch Modan only",
    },

    -- ── minSkill 55, avoidGetaway 150 ─────────────────────────────────────────
    {
        name = "Firefin Snapper", itemId = 6359,
        icon = "inv_misc_monsterhead_01",
        minSkill = 55, avoidGetaway = 150, waterType = "coastal",
        pool = "Firefin Snapper School",
        zones = {
            "Stranglethorn Vale", "Wetlands", "Desolace", "Tanaris",
            "Hillsbrad Foothills", "Dustwallow Marsh", "Swamp of Sorrows", "Stonetalon Mountains",
            "Feralas", "The Hinterlands", "Ashenvale", "Azshara",
        },
        zoneRates = {
            ["Stranglethorn Vale"] = 18.0, ["Wetlands"] = 17.0, ["Desolace"] = 15.0,
            ["Tanaris"] = 14.0, ["Hillsbrad Foothills"] = 12.0, ["Dustwallow Marsh"] = 11.0,
            ["Swamp of Sorrows"] = 10.0, ["Stonetalon Mountains"] = 9.0, ["Feralas"] = 5.0,
            ["The Hinterlands"] = 5.0, ["Ashenvale"] = 3.0, ["Azshara"] = 3.0,
        },
        note = "In Stonetalon found inland in Oil Spills at Cragpool Lake",
    },
    {
        name = "Raw Bristle Whisker Catfish", itemId = 6308,
        icon = "inv_misc_fish_30",
        minSkill = 55, avoidGetaway = 150, waterType = "inland",
        zones = {
            "Redridge Mountains", "Stonetalon Mountains", "Ashenvale", "Arathi Highlands",
            "Darnassus", "Orgrimmar", "Stormwind City", "Thunder Bluff",
            "Undercity", "Desolace", "Dustwallow Marsh", "Hillsbrad Foothills",
            "Alterac Mountains", "The Barrens", "Darkshore", "Stranglethorn Vale",
            "Scarlet Monastery",
        },
        zoneRates = {
            ["Redridge Mountains"] = 64.0, ["Stonetalon Mountains"] = 49.0, ["Ashenvale"] = 39.0,
            ["Arathi Highlands"] = 26.0, ["Darnassus"] = 22.0, ["Orgrimmar"] = 22.0,
            ["Stormwind City"] = 22.0, ["Thunder Bluff"] = 22.0, ["Undercity"] = 15.0,
            ["Desolace"] = 14.0, ["Dustwallow Marsh"] = 13.0, ["Hillsbrad Foothills"] = 13.0,
            ["Alterac Mountains"] = 12.0, ["The Barrens"] = 6.0, ["Darkshore"] = 4.0,
            ["Stranglethorn Vale"] = 1.5,
        },
    },

    -- ── minSkill 130, avoidGetaway 225 ────────────────────────────────────────
    {
        name = "Raw Greater Sagefish", itemId = 21153,
        icon = "inv_misc_fish_21",
        minSkill = 130, avoidGetaway = 225, waterType = "inland",
        pool = "Greater Sagefish School",
        zones = { "Alterac Mountains", "Stranglethorn Vale" },
        zoneRates = { ["Alterac Mountains"] = 50.0, ["Stranglethorn Vale"] = 5.0 },
    },
    {
        name = "Raw Mithril Head Trout", itemId = 8365,
        icon = "inv_misc_fish_02",
        minSkill = 130, avoidGetaway = 225, waterType = "inland",
        zones = {
            "Arathi Highlands", "Desolace", "Dustwallow Marsh", "Alterac Mountains",
            "Felwood", "Moonglade", "Western Plaguelands", "Feralas",
            "The Hinterlands", "Stranglethorn Vale", "Maraudon", "Scarlet Monastery",
            "Sunken Temple",
        },
        zoneRates = {
            ["Arathi Highlands"] = 46.0, ["Desolace"] = 27.0, ["Dustwallow Marsh"] = 24.0,
            ["Alterac Mountains"] = 23.0, ["Felwood"] = 10.0, ["Moonglade"] = 10.0,
            ["Western Plaguelands"] = 10.0, ["Feralas"] = 6.0, ["The Hinterlands"] = 5.0,
            ["Stranglethorn Vale"] = 3.0,
        },
    },
    {
        name = "Raw Rockscale Cod", itemId = 6362,
        icon = "inv_misc_fish_04",
        minSkill = 130, avoidGetaway = 225, waterType = "coastal",
        zones = {
            "Swamp of Sorrows", "Dustwallow Marsh", "Desolace", "Stranglethorn Vale",
            "Tanaris", "The Hinterlands", "Azshara", "Feralas",
        },
        zoneRates = {
            ["Swamp of Sorrows"] = 49.0, ["Dustwallow Marsh"] = 27.0, ["Desolace"] = 18.0,
            ["Stranglethorn Vale"] = 18.0, ["Tanaris"] = 7.0, ["The Hinterlands"] = 5.0,
            ["Azshara"] = 2.0, ["Feralas"] = 2.0,
        },
    },

    -- ── minSkill 205, avoidGetaway 300 ────────────────────────────────────────
    {
        name = "Raw Glossy Mightfish", itemId = 13754,
        icon = "inv_misc_monsterhead_03",
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        note = "Best 00:00–06:00 server time (18% rate); drops to ~4% midday",
        zones = { "Tanaris", "The Hinterlands", "Azshara", "Feralas" },
        zoneRates = {
            ["Tanaris"] = 6.0, ["The Hinterlands"] = 6.0, ["Azshara"] = 2.0,
            ["Feralas"] = 2.0,
        },
    },
    {
        name = "Raw Redgill", itemId = 13758,
        icon = "inv_misc_fish_06",
        minSkill = 205, avoidGetaway = 300, waterType = "inland",
        zones = {
            "Felwood", "Moonglade", "Un'Goro Crater", "Western Plaguelands",
            "Feralas", "The Hinterlands", "Azshara", "Maraudon",
            "Sunken Temple",
        },
        zoneRates = {
            ["Felwood"] = 51.0, ["Moonglade"] = 50.0, ["Un'Goro Crater"] = 50.0,
            ["Western Plaguelands"] = 50.0, ["Feralas"] = 32.0, ["The Hinterlands"] = 24.0,
            ["Azshara"] = 4.0,
        },
    },
    {
        name = "Raw Spotted Yellowtail", itemId = 4603,
        icon = "inv_misc_fish_01",
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        zones = {
            "Tanaris", "The Hinterlands", "Swamp of Sorrows", "Azshara",
            "Dustwallow Marsh", "Feralas", "Stranglethorn Vale", "Desolace",
        },
        zoneRates = {
            ["Tanaris"] = 27.0, ["The Hinterlands"] = 21.0, ["Swamp of Sorrows"] = 18.0,
            ["Azshara"] = 11.0, ["Dustwallow Marsh"] = 10.0, ["Feralas"] = 9.0,
            ["Stranglethorn Vale"] = 7.0, ["Desolace"] = 6.0,
        },
    },
    {
        name = "Stonescale Eel", itemId = 13422,
        icon = "inv_misc_fish_11",
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        note = "Best 00:00–06:00 server time (18% rate); drops to ~6% midday",
        pool = "Stonescale Eel Swarm",
        zones = {
            "Tanaris", "Azshara", "Feralas", "Stranglethorn Vale",
            "The Hinterlands",
        },
        zoneRates = {
            ["Tanaris"] = 14.0, ["Azshara"] = 12.0, ["Feralas"] = 5.0,
            ["Stranglethorn Vale"] = 5.0, ["The Hinterlands"] = 5.0,
        },
    },
    {
        name = "Raw Nightfin Snapper", itemId = 13759,
        icon = "inv_misc_fish_23",
        minSkill = 205, avoidGetaway = 300, waterType = "inland",
        timeOfDay = "night",
        zones = {
            "Moonglade", "Un'Goro Crater", "Western Plaguelands", "Winterspring",
            "Deadwind Pass", "Eastern Plaguelands", "Felwood", "Feralas",
            "The Hinterlands", "Azshara",
        },
        zoneRates = {
            ["Moonglade"] = 22.0, ["Un'Goro Crater"] = 22.0, ["Western Plaguelands"] = 20.0,
            ["Winterspring"] = 20.0, ["Deadwind Pass"] = 19.0, ["Eastern Plaguelands"] = 19.0,
            ["Felwood"] = 19.0, ["Feralas"] = 12.0, ["The Hinterlands"] = 10.0,
            ["Azshara"] = 1.4,
        },
        note = "Best 00:00–06:00 server time; cannot catch 12:00–18:00 server time",
    },
    {
        name = "Raw Sunscale Salmon", itemId = 13760,
        icon = "inv_misc_fish_19",
        minSkill = 205, avoidGetaway = 300, waterType = "inland",
        timeOfDay = "day",
        zones = {
            "Eastern Plaguelands", "Winterspring", "Western Plaguelands", "Feralas",
            "Moonglade", "The Hinterlands",
        },
        zoneRates = {
            ["Eastern Plaguelands"] = 11.0, ["Winterspring"] = 11.0, ["Western Plaguelands"] = 8.0,
            ["Feralas"] = 6.0, ["Moonglade"] = 6.0, ["The Hinterlands"] = 3.0,
        },
        note = "Cannot catch 00:00–06:00 server time; best 12:00–18:00",
    },
    {
        name = "Winter Squid", itemId = 13755,
        icon = "inv_misc_fish_13",
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        season = { start = "09-22", stop = "03-20", label = "Autumn & Winter (Sep 22 – Mar 20)", color = "ffffff" },
        zones = { "Azshara", "Tanaris", "The Hinterlands", "Feralas" },
        zoneRates = {
            ["Azshara"] = 14.0, ["Tanaris"] = 5.0, ["The Hinterlands"] = 3.0,
            ["Feralas"] = 1.7,
        },
        note = "Cannot catch 00:00–06:00 server time (except Azshara Bay of Storms)",
    },
    {
        name = "Raw Summer Bass", itemId = 13756,
        icon = "inv_misc_fish_03",
        minSkill = 205, avoidGetaway = 300, waterType = "coastal",
        timeOfDay = "day",
        season = { start = "03-20", stop = "09-21", label = "Spring & Summer (Mar 20 – Sep 21)", color = "00cc44" },
        zones = { "The Hinterlands", "Tanaris", "Azshara" },
        zoneRates = { ["The Hinterlands"] = 2.0, ["Tanaris"] = 1.6, ["Azshara"] = 1.1 },
        note = "Cannot catch 00:00–06:00 server time (except Azshara Bay of Storms)",
    },

    -- ── minSkill 330, avoidGetaway 425 ────────────────────────────────────────
    {
        name = "Zulian Mudskunk", itemId = 19975,
        minSkill = 330, avoidGetaway = 425, waterType = "inland",
        pool = "Zulian Mudskunk Pool",
        zones = { "Zul'Gurub" },
        note = "Used for summoning Gahz'Ranka (5 needed)",
    },
    {
        name = "Raw Whitescale Salmon", itemId = 13889,
        icon = "inv_misc_fish_20",
        minSkill = 330, avoidGetaway = 425, waterType = "inland",
        zones = {
            "Deadwind Pass", "Winterspring", "Eastern Plaguelands", "Zul'Gurub",
            "Scholomance", "Stratholme",
        },
        zoneRates = { ["Deadwind Pass"] = 40.0, ["Winterspring"] = 39.0, ["Eastern Plaguelands"] = 37.0 },
    },
    {
        name = "Darkclaw Lobster", itemId = 13888,
        icon = "inv_misc_fish_14",
        minSkill = 330, avoidGetaway = 425, waterType = "coastal",
        zones = { "Azshara" },
        zoneRates = { ["Azshara"] = 26.0 },
    },
    {
        name = "Large Raw Mightfish", itemId = 13893,
        icon = "inv_misc_monsterhead_02",
        minSkill = 330, avoidGetaway = 425, waterType = "coastal",
        zones = { "Azshara" },
        zoneRates = { ["Azshara"] = 5.0 },
    },
}
