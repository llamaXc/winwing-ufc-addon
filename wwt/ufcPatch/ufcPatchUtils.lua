ufcPatchUtils={}

local commonUFCKey = "commonUFCKey"
local SimAppProUFCCuedOptionBase = "UFC_OptionCueing"
local SimAppProDelimeter = '-----------------------------------------'
local SimAppProNewLine = '\n'
local SimAppProNullValue = '\n'

local buildSimAppProUFCCommand = function(key, value)
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
        if not name then
            break
        end
        ret[name] = value
    end
    return ret
end

-- SimApp Pro requires a string or newline if no value is present
local cleanText = function(str)
    if type(str) == "string" then 
        return str
    elseif type(str) =="number" then
        return tostring(str)
    else
        return SimAppProNullValue
    end
end

-- Returns the cued window payload with the selected window showing a ':'
local buildSimAppProCuedWindowPayload = function(selectedWindowsTable)
    local cuedWindows = {}
    local stringPayloadForSimAppPro = ""

    local selectedWindows = selectedWindowsTable
    if selectedWindows == nil then
        selectedWindows = {}
    end 

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
        stringPayloadForSimAppPro = stringPayloadForSimAppPro..buildSimAppProUFCCommand(key, value)
    end

    -- Useable string payload for SimApp Pro
    return stringPayloadForSimAppPro
end


-- Populate the possible fields shown on a WW F18 UFC with custom values and return a comptiable payload for SimApp Pro
-- SimApp Pro Payload = {
--     option1 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
--     option2 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
--     option3 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
--     option4 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
--     option5 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
--     scratchPadNumbers = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Digits only
--     scratchPadString1 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 1. Single character only A-Z or 0-9
--     scratchPadString2 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String Length 1. Single character only A-Z or 0-9
--     com1 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 1. Single character A-Z or integer 0-99 (some oddities above 10)
--     com2 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 1. Single character A-Z or integer 0-99 (some oddities above 10)
--     selectedWindows = {} -- Array of strings representing which selected window positions have a :
-- }
function ufcPatchUtils.buildSimAppProUFCPayload(simAppProUFCDataMap)
    local option1 = buildSimAppProUFCCommand("UFC_OptionDisplay1", cleanText(simAppProUFCDataMap.option1))
    local option2 = buildSimAppProUFCCommand("UFC_OptionDisplay2", cleanText(simAppProUFCDataMap.option2))
    local option3 = buildSimAppProUFCCommand("UFC_OptionDisplay3", cleanText(simAppProUFCDataMap.option3))
    local option4 = buildSimAppProUFCCommand("UFC_OptionDisplay4", cleanText(simAppProUFCDataMap.option4))
    local option5 = buildSimAppProUFCCommand("UFC_OptionDisplay5", cleanText(simAppProUFCDataMap.option5))
    local scratchDigits = buildSimAppProUFCCommand("UFC_ScratchPadNumberDisplay", cleanText(simAppProUFCDataMap.scratchPadNumbers))
    local scratchLeftString = buildSimAppProUFCCommand("UFC_ScratchPadString1Display", cleanText(simAppProUFCDataMap.scratchPadString1))
    local scrathRightString = buildSimAppProUFCCommand("UFC_ScratchPadString2Display", cleanText(simAppProUFCDataMap.scratchPadString2))
    local com1 = buildSimAppProUFCCommand("UFC_Comm1Display", cleanText(simAppProUFCDataMap.com1))
    local com2 = buildSimAppProUFCCommand("UFC_Comm2Display", cleanText(simAppProUFCDataMap.com2))
    local cuedWindowsPayload = buildSimAppProCuedWindowPayload(simAppProUFCDataMap.selectedWindows)
    return option1..option2..option3..option4..option5..com1..com2..scratchDigits..scratchLeftString..scrathRightString..cuedWindowsPayload
end

return ufcPatchUtils