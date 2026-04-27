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
