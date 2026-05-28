-- BrowserSelectProfession.lua — per-profession recipeList builders.
-- Each function appends entries to the list table passed in.
-- Called by ACC.selectProfession in Browser.lua.

-- ─── Gathering / secondary professions ───────────────────────────────────────

function ACC.buildMiningList(list)
    for _, vein in ipairs(ACC_Data.Mining or {}) do
        list[#list + 1] = {
            name           = vein.name,
            skill          = vein.colors[1],
            colors         = vein.colors,
            displayGroup   = vein.displayGroup,
            category       = "Veins",
            recipeItemIcon = vein.icon,
            _vein          = vein,
        }
    end
    for _, smelt in ipairs(ACC_Data.MiningSmelt or {}) do
        list[#list + 1] = {
            name           = smelt.name,
            spellId        = smelt.spellId,
            skill          = smelt.skill,
            colors         = smelt.colors,
            category       = "Smelting",
            creates        = smelt.creates,
            recipeItemIcon = smelt.creates and smelt.creates.icon,
            _smelt         = smelt,
        }
    end
    for _, train in ipairs(ACC_Data.MiningTraining or {}) do
        list[#list + 1] = {
            name         = train.name,
            spellId      = train.spellId,
            skill        = train.skill,
            category     = "Misc",
            displayGroup = 100,
            _train       = true,
            _trainYellow = true,
            trainers     = train.trainers or {},
        }
    end
end

function ACC.buildHerbalismList(list)
    for _, herb in ipairs(ACC_Data.Herbalism or {}) do
        list[#list + 1] = {
            name           = herb.name,
            skill          = herb.colors[1],
            colors         = herb.colors,
            category       = "Herbs",
            displayGroup   = herb.displayGroup,
            recipeItemId   = herb.item,
            recipeItemIcon = herb.icon,
            _herb          = herb,
        }
    end
    for _, train in ipairs(ACC_Data.HerbalismTraining or {}) do
        list[#list + 1] = {
            name         = train.name,
            spellId      = train.spellId,
            skill        = train.skill,
            category     = "Misc",
            displayGroup = 100,
            _train       = true,
            _trainYellow = true,
            trainers     = train.trainers or {},
        }
    end
end

function ACC.buildSkinningList(list)
    for _, train in ipairs(ACC_Data.SkinningTraining or {}) do
        list[#list + 1] = {
            name         = train.name,
            spellId      = train.spellId,
            skill        = train.skill,
            category     = "Misc",
            displayGroup = 100,
            _train       = true,
            _trainYellow = true,
            trainers     = train.trainers or {},
        }
    end
    for i, entry in ipairs(ACC_Data.SkinningFormula or {}) do
        list[#list + 1] = {
            name         = entry.name,
            skill        = entry.skill,
            category     = "Formula",
            displayGroup = entry.displayGroup or i,
            _formula     = entry._formula    or nil,
            _skill_calc  = entry._skill_calc or nil,
            _skill_band  = entry._skill_band or nil,
        }
    end
end

function ACC.buildFishingList(list)
    for _, train in ipairs(ACC_Data.FishingTraining or {}) do
        if train._book then
            list[#list + 1] = {
                name         = train.name,
                skill        = train.skill,
                category     = "Misc",
                displayGroup = 100,
                _book        = true,
                bookName     = train.bookName,
                bookItemId   = train.bookItemId,
                vendors      = train.vendors or {},
            }
        elseif train._quest then
            list[#list + 1] = {
                name         = train.name,
                skill        = train.skill,
                category     = "Misc",
                displayGroup = 100,
                _quest       = true,
                questName    = train.questName,
                questId      = train.questId,
                questLevel   = train.questLevel,
                questGivers  = train.questGivers or {},
                questFish    = train.questFish,
                note         = train.note,
            }
        else
            list[#list + 1] = {
                name         = train.name,
                spellId      = train.spellId,
                skill        = train.skill,
                category     = "Misc",
                displayGroup = 100,
                _train       = true,
                _trainYellow = true,
                trainers     = train.trainers or {},
            }
        end
    end
    for _, reward in ipairs(ACC_Data.FishingTournament or {}) do
        list[#list + 1] = {
            name         = reward.name,
            recipeItemId = reward.itemId,
            category     = "Tournament",
            displayGroup = reward.displayGroup,
            _fishingItem = true,
            sources      = reward.sources or {},
        }
    end
    for _, catch in ipairs(ACC_Data.FishingCatches or {}) do
        list[#list + 1] = {
            name           = catch.name,
            recipeItemId   = catch.itemId,
            recipeItemIcon = catch.icon,  -- pre-loaded from data so GetItemInfo is not needed on first render
            skill          = catch.minSkill,
            displayGroup   = catch.minSkill,
            category       = "Fish",
            _fish          = true,
            _catch         = catch,
        }
    end
    local ZONE_CONTINENT = {
        -- 1 = Kalimdor
        ["Darnassus"]                         = 1, ["Orgrimmar"]               = 1,
        ["Thunder Bluff"]                     = 1, ["Darkshore"]               = 1,
        ["Durotar"]                           = 1, ["Mulgore"]                 = 1,
        ["Teldrassil"]                        = 1, ["The Barrens"]             = 1,
        ["Ashenvale"]                         = 1, ["Stonetalon Mountains"]    = 1,
        ["Desolace"]                          = 1, ["Dustwallow Marsh"]        = 1,
        ["Thousand Needles"]                  = 1, ["Azshara"]                 = 1,
        ["Felwood"]                           = 1, ["Feralas"]                 = 1,
        ["Moonglade"]                         = 1, ["Tanaris"]                 = 1,
        ["Un'Goro Crater"]                    = 1, ["Azshara (Bay of Storms)"] = 1,
        ["Feralas (Jademir Lake)"]            = 1, ["Silithus"]                = 1,
        ["Winterspring"]                      = 1,
        -- 2 = Eastern Kingdoms
        ["Ironforge"]                         = 2, ["Stormwind City"]          = 2,
        ["Undercity"]                         = 2, ["Dun Morogh"]              = 2,
        ["Elwynn Forest"]                     = 2, ["Loch Modan"]              = 2,
        ["Silverpine Forest"]                 = 2, ["Tirisfal Glades"]         = 2,
        ["Westfall"]                          = 2, ["Duskwood"]                = 2,
        ["Hillsbrad Foothills"]               = 2, ["Redridge Mountains"]      = 2,
        ["Wetlands"]                          = 2, ["Alterac Mountains"]       = 2,
        ["Arathi Highlands"]                  = 2, ["Stranglethorn Vale"]      = 2,
        ["Stranglethorn Vale (Jaguero Isle)"] = 2, ["Swamp of Sorrows"]        = 2,
        ["The Hinterlands"]                   = 2, ["Western Plaguelands"]     = 2,
        ["Deadwind Pass"]                     = 2, ["Eastern Plaguelands"]     = 2,
        -- 3 = Instances (all, regardless of continent — grouped together on the EK page)
        ["Blackfathom Deeps"]                 = 3, ["The Deadmines"]           = 3,
        ["Wailing Caverns"]                   = 3, ["Scarlet Monastery"]       = 3,
        ["Maraudon"]                          = 3, ["Sunken Temple"]           = 3,
        ["Scholomance"]                       = 3, ["Stratholme"]              = 3,
        ["Zul'Gurub"]                         = 3,
    }
    local CONTINENT_LABEL = { [1] = "Kalimdor", [2] = "Eastern Kingdoms", [3] = "Instances" }
    for _, zone in ipairs(ACC_Data.FishingZones or {}) do
        local cont = ZONE_CONTINENT[zone.name] or 2
        list[#list + 1] = {
            name          = zone.name,
            skill         = zone.minCast,
            displayGroup  = cont,
            zoneGroup     = CONTINENT_LABEL[cont],
            startsNewPage = cont == 2,  -- Eastern Kingdoms begins on page 2
            category      = "Zones",
            _zone         = true,
            minCast       = zone.minCast,
            guaranteed    = zone.guaranteed,
            recipeItemIcon = zone.icon,  -- optional per-zone flavor icon defined in Fishing.lua
            pools         = zone.pools,  -- passed through so layoutZone can render clickable pool-fish rows
        }
    end
    for _, pole in ipairs(ACC_Data.FishingPoles or {}) do
        local bonus = pole.fishingBonus or 0
        list[#list + 1] = {
            name         = pole.name,
            recipeItemId = pole.itemId,
            skill        = bonus,
            skillLabel   = bonus > 0 and ("+" .. bonus) or nil,
            displayGroup = bonus,
            category     = "Poles",
            _fishingItem = true,
            sources      = pole.sources or {},
        }
    end
    for _, lure in ipairs(ACC_Data.FishingLures or {}) do
        list[#list + 1] = {
            name         = lure.name,
            recipeItemId = lure.itemId,
            category     = "Lures",
            displayGroup = lure.displayGroup,
            _fishingItem = true,
            sources      = lure.sources or {},
        }
    end
    -- Pre-warm the item cache for every catch so icons and links are ready when
    -- a zone detail panel opens. GetItemInfo queues a server request if the item
    -- is not already cached; the data arrives before the player can click a zone.
    for _, catch in ipairs(ACC_Data.FishingCatches or {}) do
        if catch.itemId then GetItemInfo(catch.itemId) end
    end
end

-- ─── Standard crafting professions ───────────────────────────────────────────

-- pendingByItemId and mainFrame are passed in so this file stays independent of
-- Browser.lua's local upvalues.
function ACC.buildGeneralList(list, profName, pendingByItemId, mainFrame)
    local slotCategory          = ACC_BrowserConfig.slotCategory
    local professionDefaultCategory = ACC_BrowserConfig.professionDefaultCategory
    local isGear = profName == "Tailoring" or profName == "Leatherworking"
               or profName == "Blacksmithing" or profName == "Engineering"
    local defaultCat = professionDefaultCategory[profName]

    local recipeData = ACC_Data[profName] or {}
    for _, recipe in ipairs(recipeData) do
        if recipe.skill ~= 9999 then
            if recipe._book then
                list[#list + 1] = {
                    name         = recipe.name,
                    skill        = recipe.skill,
                    category     = "Misc",
                    displayGroup = 100,
                    _book        = true,
                    bookName     = recipe.bookName,
                    bookItemId   = recipe.bookItemId,
                    vendors      = recipe.vendors or {},
                }
            elseif recipe._quest then
                list[#list + 1] = {
                    name         = recipe.name,
                    skill        = recipe.skill,
                    category     = "Misc",
                    displayGroup = 100,
                    _quest       = true,
                    questName    = recipe.questName,
                    questId      = recipe.questId,
                    questLevel   = recipe.questLevel,
                    questGivers  = recipe.questGivers or {},
                }
            elseif recipe.creates == nil and (not recipe.reagents or #recipe.reagents == 0) then
                -- Rank-up training entry (Journeyman/Expert/Artisan).
                local src = recipe.sources and recipe.sources[1]
                list[#list + 1] = {
                    name         = recipe.name,
                    spellId      = recipe.spellId,
                    skill        = recipe.skill,
                    category     = "Misc",
                    displayGroup = 100,
                    _train       = true,
                    _trainYellow = true,
                    trainers     = (src and src.trainers) or {},
                }
            else
                list[#list + 1] = recipe
            end
        end
    end

    -- Resolve slot categories via GetItemInfo.  When an item is not yet in the client
    -- cache, GetItemInfo returns nil for ALL return values — including the item name.
    -- We use the name as a "is cached?" signal: nil name means pending, not truly Misc.
    for _, recipe in ipairs(list) do
        recipe.resolvedCategory = nil
        if recipe.creates then
            local itemName, _, _, _, _, _, _, _, equipLoc = GetItemInfo(recipe.creates.id)
            if itemName then
                if not recipe.category then
                    recipe.resolvedCategory = slotCategory[equipLoc]
                        or defaultCat
                        or (isGear and "Misc" or nil)
                end
            elseif not recipe.category and (isGear or defaultCat) then
                recipe.resolvedCategory = defaultCat or "Misc"
                pendingByItemId[recipe.creates.id] = recipe
            end
        elseif not recipe.category and defaultCat then
            recipe.resolvedCategory = defaultCat
        end
    end

    if next(pendingByItemId) then
        mainFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    end
end
