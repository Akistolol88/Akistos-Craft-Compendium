-- Skinning trainer and rank data for WoW Classic (1.12)
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
--   area       specific landmark within that zone
--   faction    "alliance", "horde", or nil (neutral)
--   max_rank   highest rank this trainer can teach

ACC_Data = ACC_Data or {}

ACC_Data.SkinningSkill = {
    { rank = "Apprentice", req_skill = 0,   req_level = 1,  skill_max = 75  },
    { rank = "Journeyman", req_skill = 50,  req_level = 10, skill_max = 150 },
    { rank = "Expert",     req_skill = 125, req_level = 20, skill_max = 225 },
    { rank = "Artisan",    req_skill = 200, req_level = 35, skill_max = 300 },
}

ACC_Data.SkinningTrainers = {
    { name = "Helene Peltskinner",   zone = "Elwynn Forest",  area = "Goldshire",              faction = "alliance", max_rank = "journeyman" },
    { name = "Radnaal Maneweaver",   zone = "Teldrassil",     area = "Dolanaar",               faction = "alliance", max_rank = "journeyman" },
    { name = "Saenorion",            zone = "Stormwind City", area = "Trade District",         faction = "alliance", max_rank = "expert"     },
    { name = "Randal Worth",         zone = "Ironforge",      area = "The Commons",            faction = "alliance", max_rank = "expert"     },
    { name = "Yonn Deepcut",         zone = "Darnassus",      area = "Craftsmen's Terrace",    faction = "alliance", max_rank = "expert"     },
    { name = "Kulleg Stonehorn",     zone = "Feralas",        area = "Feathermoon Stronghold", faction = "alliance", max_rank = "artisan"    },
    { name = "Thuwd",                zone = "Orgrimmar",      area = "The Drag",               faction = "horde",    max_rank = "expert"     },
    { name = "Dranh",                zone = "Thunder Bluff",  area = "Middle Rise",            faction = "horde",    max_rank = "expert"     },
    { name = "Killian Hagey",        zone = "Undercity",      area = "Trade Quarter",          faction = "horde",    max_rank = "expert"     },
    { name = "Una",                  zone = "Thunder Bluff",  area = "Lower Rise",             faction = "horde",    max_rank = "artisan"    },
}
