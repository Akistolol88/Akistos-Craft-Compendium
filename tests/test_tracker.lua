-- Tests for ACC_Tracker.IsKnown and ACC_Tracker.WhoKnows.
-- Run with: lua tests/test_tracker.lua  (or: npm test)

-- ACC globals normally provided by other files loaded before Tracker.lua in the .toc.
ACC = {}
ACC_DataManager = { recipeById = {}, itemToSpell = {} }
ACC_AccountData = nil

-- WoW API stubs — Tracker.lua calls these at load time; they do nothing outside the client.
function CreateFrame()
    return {
        RegisterEvent = function() end,
        SetScript = function() end,
        Show = function() end,
        Hide = function() end
    }
end

function hooksecurefunc() end
GameTooltip    = { HookScript = function() end }
ItemRefTooltip = { HookScript = function() end }

dofile("Model/core/Tracker.lua")

luaunit = require("tests.luaunit")

TestTracker = {}

-- IsKnown returns true when the current character knows the recipe, false otherwise.
function TestTracker.testIsKnown()
    ACC_DataManager.recipeById[17573] = { name = "Greater Arcane Elixir" }
    ACC_Tracker._setTestState("portwaterguy", { ["Greater Arcane Elixir"] = true})
    luaunit.assertEquals(ACC_Tracker.IsKnown(17573), true)
    ACC_Tracker._setTestState("portwaterguy", {})
    luaunit.assertEquals(ACC_Tracker.IsKnown(17573), false)
end

-- WhoKnows returns all characters that know the recipe, with the current character first.
function TestTracker.testWhoKnows()
    ACC_DataManager.recipeById[17573] = { name = "Greater Arcane Elixir"}
    ACC_AccountData = {
        characters = {
            ["portwaterguy"] = { ["Greater Arcane Elixir"] = true},
            ["wipeguy"]      = { ["Greater Arcane Elixir"] = true},
            ["newguy"]       = { ["Greater Arcane Elixir"] = false},
        }
    }
    ACC_Tracker._setTestState("portwaterguy", { ["Greater Arcane Elixir"] = true })
    luaunit.assertEquals(ACC_Tracker.WhoKnows(17573), {"portwaterguy", "wipeguy"})
end

os.exit(luaunit.LuaUnit.run())
