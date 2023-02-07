ufcPatchUtils={}

local commonUFCKey = "commonUFCKey"
local SimAppProUFCCuedOptionBase = "UFC_OptionCueing"
local SimAppProDelimeter = '-----------------------------------------'
local SimAppProNewLine = '\n'
local SimAppProNullValue = '\n'

-- Generate the required SimApp Pro encoded string for UFC values
function ufcPatchUtils.buildSimAppProUFCCommand(key, value)
    return SimAppProDelimeter..SimAppProNewLine..key..SimAppProNewLine..value..SimAppProNewLine
end

-- Accesses list indications in DCS easily
-- Thanks to [FSF]Ian code and Helios Export Script
-- https://github.com/BlueFinBima/DCS-FA18C-UFC/blob/0dcfff946be9f61c8a1ed44b6c10a13e0ccbf30c/DCS/scripts/Helios/AV8B/ExportUFC.lua#L282
function ufcPatchUtils.getDCSListIndication(indicator_id)
    local ret = {}
    local li = list_indication(indicator_id)
    if li == "" then return nil end
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    while true do
    local name, value = m()
    if not name then break end
        ret[name] = value
    end
    return ret
end

-- SimApp Pro requires a string or newline if no value is present
function ufcPatchUtils.cleanText(str)
    if type(str) == "string" then 
        return str
    elseif type(str) =="number" then
        return tostring(str)
    else
        return SimAppProNullValue
    end
end

-- Returns the cued window payload with the selected window showing a ':'
function ufcPatchUtils.buildSimAppProCuedWindowPayload(selectedWindows)

    local cuedWindows = {}
    local stringPayloadForSimAppPro = ""

    -- Populate 5 empty window options
    for i=1, 5 do
        cuedWindows[SimAppProUFCCuedOptionBase..i] = ""
    end
    
    for index,windowPosition in ipairs(selectedWindows) do
        local keyCuedWindow = SimAppProUFCCuedOptionBase..windowPosition
        cuedWindows[keyCuedWindow] = ":"
      end

    -- Loop over windows and generate compatiable SimApp Pro transmission
    for key, value in pairs(cuedWindows) do
        stringPayloadForSimAppPro = stringPayloadForSimAppPro..ufcPatchUtils.buildSimAppProUFCCommand(key, value)
    end

    log.write("WWT", log.INFO, "String windows: "..stringPayloadForSimAppPro)
    -- Useable string payload for SimApp Pro
    return stringPayloadForSimAppPro
end

return ufcPatchUtils