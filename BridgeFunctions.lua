local OCB = OSICrutchBridge

local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local function ConvertTexture(texture)
    if (StartsWith(texture, "/")) then
        texture = texture:sub(2) -- Remove first /
    end

    if (StartsWith(texture:lower(), "odysupporticons")) then
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge: no texture replacement available for " .. texture .. "; using poop instead.")
        return "CrutchAlerts/assets/poop.dds"
    end
    return texture
end

---------------------------------------------------------------------
function OCB.OSI.GetIconSize()
    return 128 -- TODO: setting?
end

---------------------------------------------------------------------
function OCB.OSI.CreatePositionIcon(x, y, z, texture, size, color, offset, callback)
    if (callback) then
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge doesn't support callback in CreatePositionIcon! Continuing...|r")
    end

    texture = ConvertTexture(texture)
    color = color or CrutchAlerts.Constants.WHITE
    offset = offset or 0

    local key = CrutchAlerts.Drawing.CreateWorldTexture(
        texture,
        x, y + offset, z,
        size / 200, size / 200,
        color,
        false, -- useDepthBuffer
        true) -- faceCamera

    return key -- TODO: OSI returns a table, but hopefully no addons besides QRH use that?
end

function OCB.OSI.DiscardPositionIcon(icon)
    -- It actually just takes the key
    if (type(icon) ~= "string") then
        CrutchAlerts.dbgOther("|cFF0000OSI-Crutch Bridge expects a key string for DiscardPositionIcon|r")
        return
    end
    CrutchAlerts.Drawing.RemoveWorldTexture(icon)
end

---------------------------------------------------------------------
local BRIDGE_UNIQUE_NAME = "OSICrutchBridge"
local BRIDGE_PRIORITY = 400

local function GetUnitTagForName(displayName)
    local unitTag
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        local name = GetUnitDisplayName(tag)
        if (name and name:lower() == displayName:lower()) then
            unitTag = tag
            break
        end
    end
    return unitTag
end

-- offset is not used
function OCB.OSI.SetMechanicIconForUnit(displayName, texture, size, color, offset, callback)
    if (callback) then
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge doesn't support callback in CreatePositionIcon! Continuing...|r")
    end

    texture = ConvertTexture(texture)
    color = color or CrutchAlerts.Constants.WHITE

    local unitTag = GetUnitTagForName(displayName)
    if (unitTag) then
        CrutchAlerts.SetAttachedIconForUnit(
            unitTag,
            BRIDGE_UNIQUE_NAME,
            BRIDGE_PRIORITY,
            texture,
            size,
            color)
    else
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge couldn't remove mechanic icon for " .. displayName .. "|r")
    end
end

function OCB.OSI.RemoveMechanicIconForUnit(displayName)
    local unitTag = GetUnitTagForName(displayName)
    if (unitTag) then
        CrutchAlerts.RemoveAttachedIconForUnit(unitTag, BRIDGE_UNIQUE_NAME)
    else
        CrutchAlerts.dbgOther("|cFFFF00OSI-Crutch Bridge couldn't remove mechanic icon for " .. displayName .. "|r")
    end
end

function OCB.OSI.ResetMechanicIcons()
    CrutchAlerts.RemoveAllAttachedIcons(BRIDGE_UNIQUE_NAME)
end