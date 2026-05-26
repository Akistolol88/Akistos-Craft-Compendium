-- RecipeDetailHelpers.lua — item link / icon resolvers shared across RecipeDetail layout files.
-- Must be loaded before RecipeDetailSources, RecipeDetailZone, and RecipeDetail.

local QUALITY_COLOR = {
    [0] = "ff9d9d9d", [1] = "ffffffff", [2] = "ff1eff00",
    [3] = "ff0070dd", [4] = "ffa335ee", [5] = "ffff8000",
}

-- Constructs a clickable item hyperlink from pipeline data when the client cache lacks the item.
function ACC.makeItemLink(id, name, quality)
    local color = QUALITY_COLOR[quality] or QUALITY_COLOR[1]
    return "|c" .. color .. "|Hitem:" .. id .. ":0:0:0:0:0:0:0|h[" .. name .. "]|h|r"
end

-- Priority: live GetItemInfo link → pipeline name fallback → bare item ID.
function ACC.resolveItemLink(id, pipelineName, pipelineQuality)
    local _, link = GetItemInfo(id)
    if link then return link end
    if pipelineName then return ACC.makeItemLink(id, pipelineName, pipelineQuality) end
    return "|cffffff00[" .. id .. "]|r"
end

-- Priority: pipeline icon → live GetItemInfo texture → question mark.
function ACC.resolveItemIcon(id, pipelineIcon)
    if pipelineIcon then return "Interface\\Icons\\" .. pipelineIcon end
    local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(id)
    return tex or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Inserts a hyperlink into the active chat input; falls back to printing in the chat frame.
function ACC.insertLink(link)
    DEFAULT_CHAT_FRAME:AddMessage(link)
    ChatEdit_InsertLink(link)
end
