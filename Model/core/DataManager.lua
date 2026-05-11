-- DataManager.lua — read-only data index layer.
-- Consumes the raw ACC_Data tables written by the data files and exposes clean
-- accessor functions to the UI. Nothing here writes to SavedVariables.
--
-- ACC_DataManager: indexes all recipe data at load time for fast UI lookups.
-- ACC_Data tables are populated by the data files loaded before this in the .toc.

ACC_DataManager = {}

-- recipeById[spellId] = recipe
-- Built once at load so any recipe can be found in O(1) instead of searching the full list each time.
ACC_DataManager.recipeById = {}

-- professionGroups drives the dropdown UI — three groups with titles and separators between them.
ACC_DataManager.professionGroups = {
    { title = "Professions",  professions = {
        "Alchemy",
        "Blacksmithing",
        "Engineering",
        "Enchanting",
        "Leatherworking",
        "Tailoring" } },
    { title = "Resource Gathering",    professions = {
        "Herbalism",
        "Mining",
        "Skinning" } },
    { title = "Secondary Professions", professions = {
        "Cooking",
        "First Aid",
        "Fishing" } },
}

function GetProfessionGroups()
    return ACC_DataManager.professionGroups
end

-- Build recipeById in one pass over all professions at load time.
for profName, recipes in pairs(ACC_Data) do
    for i, recipe in ipairs(recipes) do
        if recipe.spellId then
            ACC_DataManager.recipeById[recipe.spellId] = recipe
        end
    end
end

-- NOTE: proffessions field is currently unset; GetProfessionGroups() is the live accessor.
function GetProffessions()
    return ACC_DataManager.proffessions
end

-- ACC_Data[profName] is the raw table written by each data file (e.g. ACC_Data["Alchemy"]).
function GetRecipes(profName)
    return ACC_Data[profName]
end

function GetRecipeById(spellId)
    return ACC_DataManager.recipeById[spellId]
end

-- Walks all recipe data and calls GetItemInfo for every unique item ID in batches.
-- This primes the client cache so icons and names are available without hover delays.
function PrefetchItemCache()
    local seen  = {}
    local queue = {}
    for _, recipes in pairs(ACC_Data) do
        for _, recipe in ipairs(recipes) do
            if recipe.creates and recipe.creates.id and not seen[recipe.creates.id] then
                seen[recipe.creates.id] = true
                queue[#queue + 1] = recipe.creates.id
            end
            if recipe.recipeItemId and not seen[recipe.recipeItemId] then
                seen[recipe.recipeItemId] = true
                queue[#queue + 1] = recipe.recipeItemId
            end
            for _, reagent in ipairs(recipe.reagents or {}) do
                if reagent.id and not seen[reagent.id] then
                    seen[reagent.id] = true
                    queue[#queue + 1] = reagent.id
                end
            end
        end
    end

    -- Process 10 items per frame tick to avoid freezing the client on large queues.
    -- Once the queue is drained, the OnUpdate script removes itself so no overhead remains.
    local index = 1
    local loader = CreateFrame("Frame")
    loader:SetScript("OnUpdate", function()
        for _ = 1, 10 do
            if queue[index] then
                GetItemInfo(queue[index])
                index = index + 1
            else
                loader:SetScript("OnUpdate", nil)
                return
            end
        end
    end)
end
