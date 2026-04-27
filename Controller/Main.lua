-- Register "/acc" as the slash command that opens the browser.
-- SLASH_ACC1 is the variable WoW reads to know what text triggers SlashCmdList["ACC"].
SLASH_ACC1 = "/acc"

-- browserInit() builds all the frames at load time so they're ready when the player types /acc.
browserInit()

SlashCmdList["ACC"] = function()
    showBrowser()
end
