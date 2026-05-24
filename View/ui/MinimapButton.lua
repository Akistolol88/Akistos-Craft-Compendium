-- MinimapButton.lua — clickable minimap button that opens/closes the ACC browser.
-- Draggable around the minimap ring; position persists via ACC_CharacterData.minimapAngle.
-- Right-click shows a menu; restore a hidden button with /acc minimap.

local ACCBtn = CreateFrame("Button", "ACCMinimapButton", Minimap)
ACCBtn:SetWidth(31)
ACCBtn:SetHeight(31)
ACCBtn:SetFrameStrata("MEDIUM")

-- MiniMap-TrackingBorder has its circular hole in the upper-left of the texture, not centered.
-- Anchoring at TOPLEFT (no offset) and sizing 53x53 lets it overflow the button to the right/bottom,
-- matching how LibDBIcon positions it in Classic ERA.
local ACCBtnOverlay = ACCBtn:CreateTexture(nil, "OVERLAY")
ACCBtnOverlay:SetSize(53, 53)
ACCBtnOverlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
ACCBtnOverlay:SetPoint("TOPLEFT")

-- Icon offset (7, -6) from button TOPLEFT aligns it with the circular hole in the overlay.
ACCBtn.icon = ACCBtn:CreateTexture(nil, "ARTWORK")
ACCBtn.icon:SetSize(17, 17)
ACCBtn.icon:SetTexture("Interface\\Icons\\inv_misc_bag_13")
ACCBtn.icon:SetPoint("TOPLEFT", 7, -6)

-- Converts a radian angle to (x, y) on the minimap ring and repositions the button.
local function updateMinimapPosition(angle)
    local radius = 80
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    ACCBtn:ClearAllPoints()
    ACCBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    ACCBtn.angle = angle
end

-- Called by /acc minimap to toggle the button on or off.
function ACC.showMinimapButton()
    if ACCBtn:IsShown() then
        ACCBtn:Hide()
        if ACC_CharacterData then ACC_CharacterData.minimapHidden = true end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffACC:|r Minimap button hidden. Type |cffffffff/acc minimap|r to restore it.")
    else
        ACCBtn:Show()
        if ACC_CharacterData then ACC_CharacterData.minimapHidden = false end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffACC:|r Minimap button restored.")
    end
end

-- SavedVariables are only available after PLAYER_LOGIN, so position and visibility are set here.
local minimapLoader = CreateFrame("Frame")
minimapLoader:RegisterEvent("PLAYER_LOGIN")
minimapLoader:SetScript("OnEvent", function()
    local angle = (ACC_CharacterData and ACC_CharacterData.minimapAngle) or (math.pi * 0.75)
    updateMinimapPosition(angle)
    if ACC_CharacterData and ACC_CharacterData.minimapHidden then
        ACCBtn:Hide()
    end
end)

local ACCBtnMenu = CreateFrame("Frame", "ACCMinimapMenu", UIParent, "UIDropDownMenuTemplate")
UIDropDownMenu_Initialize(ACCBtnMenu, function()
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Akistos Craft Compendium"
    info.isTitle = true
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Hide minimap button"
    info.notCheckable = true
    info.func = function()
        ACCBtn:Hide()
        if ACC_CharacterData then
            ACC_CharacterData.minimapHidden = true
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffACC:|r Minimap button hidden. Type |cffffffff/acc minimap|r to restore it.")
    end
    UIDropDownMenu_AddButton(info)
end, "MENU")

ACCBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
ACCBtn:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
        if UIDROPDOWNMENU_OPEN_MENU == ACCBtnMenu then
            CloseDropDownMenus()
        else
            ToggleDropDownMenu(1, nil, ACCBtnMenu, "cursor", 0, 0)
        end
    elseif ACC_BrowserState.mainFrame:IsShown() then
        ACC.hideBrowser()
    else
        ACC.showBrowser()
    end
end)

ACCBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(ACCBtn, "ANCHOR_LEFT")
    GameTooltip:AddLine("Akistos Craft Compendium")
    GameTooltip:AddLine("Click to open/close", 1, 1, 1)
    GameTooltip:AddLine("Drag to move", 1, 1, 1)
    GameTooltip:Show()
end)

ACCBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

ACCBtn:RegisterForDrag("LeftButton")

ACCBtn:SetScript("OnDragStart", function()
    CloseDropDownMenus()
    ACCBtn.dragging = true
end)

-- GetCursorPosition returns screen pixels; divide by UI scale to match GetCenter() coordinates.
ACCBtn:SetScript("OnUpdate", function()
    if not ACCBtn.dragging then return end
    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    local mapX, mapY = Minimap:GetCenter()
    local angle = math.atan2(cursorY - mapY, cursorX - mapX)
    updateMinimapPosition(angle)
end)

ACCBtn:SetScript("OnDragStop", function()
    ACCBtn.dragging = false
    if ACC_CharacterData then
        ACC_CharacterData.minimapAngle = ACCBtn.angle
    end
end)
