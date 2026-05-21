-- Skinning.lua — trainer and rank data for WoW Classic (1.12).
--
-- SkinningSkill fields:
--   rank       display name for the training tier
--   req_skill  skill points needed to unlock this rank
--   req_level  character level required
--   skill_max  skill cap granted by this rank
--
-- SkinningTrainers fields:
--   name       NPC name
--   zone       zone the NPC is in
--   faction    "alliance", "horde", or nil (neutral / reacts to both)
--
-- All skinning trainers can teach every rank (Journeyman through Artisan).

ACC_Data = ACC_Data or {}

ACC_Data.SkinningSkill = {
    { rank = "Apprentice", req_skill = 0,   req_level = 1,  skill_max = 75  },
    { rank = "Journeyman", req_skill = 50,  req_level = 10, skill_max = 150 },
    { rank = "Expert",     req_skill = 125, req_level = 20, skill_max = 225 },
    { rank = "Artisan",    req_skill = 200, req_level = 35, skill_max = 300 },
}

ACC_Data.SkinningTrainers = {
    -- Alliance
    { name = "Balthus Stoneflayer",  zone = "Ironforge",          faction = "alliance" },
    { name = "Eladriel",             zone = "Darnassus",          faction = "alliance" },
    { name = "Helene Peltskinner",   zone = "Elwynn Forest",      faction = "alliance" },
    { name = "Jayla",                zone = "Ashenvale",          faction = "alliance" },
    { name = "Maris Granger",        zone = "Stormwind City",     faction = "alliance" },
    { name = "Radnaal Maneweaver",   zone = "Teldrassil",         faction = "alliance" },
    { name = "Wilma Ranthal",        zone = "Redridge Mountains", faction = "alliance" },
    -- Horde
    { name = "Dranh",                zone = "The Barrens",        faction = "horde"    },
    { name = "Killian Hagey",        zone = "Undercity",          faction = "horde"    },
    { name = "Kulleg Stonehorn",     zone = "Feralas",            faction = "horde"    },
    { name = "Malux",                zone = "Desolace",           faction = "horde"    },
    { name = "Mooranta",             zone = "Thunder Bluff",      faction = "horde"    },
    { name = "Thuwd",                zone = "Orgrimmar",          faction = "horde"    },
    { name = "Yonn Deepcut",         zone = "Mulgore",            faction = "horde"    },
    -- Neutral
    { name = "Rand Rhobart",         zone = "Tirisfal Glades"                          },
}

-- SkinningTraining fields:
--   name     display name shown in the browser
--   spellId  spell ID for the rank-up cast
--   skill    skill points required to learn
--   trainers list of {name, zone, faction} — all trainers for every rank

local _allTrainers = {
    -- Alliance
    { name = "Balthus Stoneflayer",  zone = "Ironforge",          faction = "alliance" },
    { name = "Eladriel",             zone = "Darnassus",          faction = "alliance" },
    { name = "Helene Peltskinner",   zone = "Elwynn Forest",      faction = "alliance" },
    { name = "Jayla",                zone = "Ashenvale",          faction = "alliance" },
    { name = "Maris Granger",        zone = "Stormwind City",     faction = "alliance" },
    { name = "Radnaal Maneweaver",   zone = "Teldrassil",         faction = "alliance" },
    { name = "Wilma Ranthal",        zone = "Redridge Mountains", faction = "alliance" },
    -- Horde
    { name = "Dranh",                zone = "The Barrens",        faction = "horde"    },
    { name = "Killian Hagey",        zone = "Undercity",          faction = "horde"    },
    { name = "Kulleg Stonehorn",     zone = "Feralas",            faction = "horde"    },
    { name = "Malux",                zone = "Desolace",           faction = "horde"    },
    { name = "Mooranta",             zone = "Thunder Bluff",      faction = "horde"    },
    { name = "Thuwd",                zone = "Orgrimmar",          faction = "horde"    },
    { name = "Yonn Deepcut",         zone = "Mulgore",            faction = "horde"    },
    -- Neutral
    { name = "Rand Rhobart",         zone = "Tirisfal Glades"                          },
}

ACC_Data.SkinningTraining = {
    { name = "Journeyman Skinning", spellId = 8617,  skill = 50,  trainers = _allTrainers },
    { name = "Expert Skinning",     spellId = 8618,  skill = 125, trainers = _allTrainers },
    { name = "Artisan Skinning",    spellId = 10768, skill = 200, trainers = _allTrainers },
}

-- Formula reference entries shown in the Formula category.
-- _skill_calc marks the entry that Browser.lua replaces with the live calculated result.
ACC_Data.SkinningFormula = {
    { name = "Skill 1-100:  Max mob level = (Skill / 10) + 10", _formula = true },
    { name = "Skill 100+:   Max mob level = Skill / 5",          _formula = true },
    { name = "",                                                  _skill_calc = true },
}
