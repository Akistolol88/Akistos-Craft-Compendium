-- Main.lua — addon entry point.
-- Runs after all data, DataManager, Tracker, and UI files have loaded.
-- Responsibilities: register the /acc slash command and trigger browser frame construction.

-- SLASH_ACC1 is the global variable WoW reads to register the "/acc" slash command.
-- The "1" suffix allows multiple aliases (SLASH_ACC2 = "/compendium" etc.) if needed later.
SLASH_ACC1 = "/acc"

-- browserInit() builds all frames at load time so they exist before the player ever types /acc.
-- Doing it here (rather than inside the slash handler) means the first /acc has no setup delay.
ACC.browserInit()

-- SlashCmdList["ACC"] is the function WoW calls when the player types /acc.
-- Supports "/acc minimap" to restore a hidden minimap button; bare "/acc" opens the browser.
SlashCmdList["ACC"] = function(msg)
    if msg == "minimap" then
        ACC.showMinimapButton()
    else
        ACC.showBrowser()
    end
end
