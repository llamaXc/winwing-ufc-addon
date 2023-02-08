ufcPatch={}

ufcPatch.prevUFCPayload = nil
ufcPatch.prevAV88HarrierValues = nil
ufcPatch.useCustomUFC = false

-- UTIL Functions
local buildSimAppProUFCCommand
local getDCSListIndication
local cleanText
local buildSimAppProCuedWindowPayload

-- Empty Payload
local DEFAULT_SIMAPP_PRO_PAYLOAD

function ufcPatch.initializeUFC()
    buildSimAppProUFCCommand = ufcPatch.ufcPatchUtils.buildSimAppProUFCCommand
    getDCSListIndication = ufcPatch.ufcPatchUtils.getDCSListIndication
    cleanText = ufcPatch.ufcPatchUtils.cleanText
    buildSimAppProCuedWindowPayload = ufcPatch.ufcPatchUtils.buildSimAppProCuedWindowPayload

    DEFAULT_SIMAPP_PRO_PAYLOAD = {
        option1 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
        option2 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
        option3 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
        option4 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
        option5 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Letters and digits
        scratchPadNumbers = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 4. Digits only
        scratchPadString1 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 1. Single character only A-Z or 0-9
        scratchPadString2 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String Length 1. Single character only A-Z or 0-9
        com1 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 1. Single character A-Z or integer 0-99 (some oddities above 10)
        com2 = ufcPatch.ufcPatchUtils.SimAppProNullValue, -- String length 1. Single character A-Z or integer 0-99 (some oddities above 10)
        selectedWindows = {} -- Array of strings representing which selected window positions have a :
    }
end

-- Populate the possible fields shown on a WW F18 UFC with custom values and return a comptiable payload for SimApp Pro
local buildSimAppProUFCPayload = function(simAppProUFCDataMap)
    local option1 = buildSimAppProUFCCommand("UFC_OptionDisplay1", simAppProUFCDataMap.option1) 
    local option2 = buildSimAppProUFCCommand("UFC_OptionDisplay2", simAppProUFCDataMap.option2)
    local option3 = buildSimAppProUFCCommand("UFC_OptionDisplay3", simAppProUFCDataMap.option3)
    local option4 = buildSimAppProUFCCommand("UFC_OptionDisplay4", simAppProUFCDataMap.option4)
    local option5 = buildSimAppProUFCCommand("UFC_OptionDisplay5", simAppProUFCDataMap.option5)
    local scratchDigits = buildSimAppProUFCCommand("UFC_ScratchPadNumberDisplay", simAppProUFCDataMap.scratchPadNumbers)
    local scratchLeftString = buildSimAppProUFCCommand("UFC_ScratchPadString1Display", simAppProUFCDataMap.scratchPadString1)
    local scrathRightString = buildSimAppProUFCCommand("UFC_ScratchPadString2Display", simAppProUFCDataMap.scratchPadString2)
    local com1 = buildSimAppProUFCCommand("UFC_Comm1Display", simAppProUFCDataMap.com1)
    local com2 = buildSimAppProUFCCommand("UFC_Comm2Display", simAppProUFCDataMap.com2)

    local cuedWindowsPayload = buildSimAppProCuedWindowPayload(simAppProUFCDataMap.selectedWindows)
    return option1..option2..option3..option4..option5..com1..com2..scratchDigits..scratchLeftString..scrathRightString..cuedWindowsPayload
end

function ufcPatch.generateUFCDataForHuey()
    -- Example of populating WW F18 UFC with test values when flying the Huey
    -- It is possible to add Airspeed, heading, altitude for example. 
    return buildSimAppProUFCPayload({
        option1=cleanText("TEST"),
        option2=cleanText("HUEY"),
        option3=cleanText("DCS"),
        option4=cleanText("UFC"),
        option5=cleanText("1234"),
        scratchPadNumbers=cleanText("2023"),
        scratchPadString1=cleanText("A"),
        scratchPadString2=cleanText("9"),
        com1=cleanText("11"),
        com2=cleanText("W"),
        selectedWindows={"1", "2"}
    })
end

function ufcPatch.generateUFCDataForAV88()

    -- Avoid extra work by checking the base values up front. ODU + UFC == string of DCS Values
    local av88HarrierDCSValues = list_indication(6)..list_indication(5)
    if av88HarrierDCSValues ~= prevAV88HarrierValues then

        -- Update prev values
        prevAV88HarrierValues = av88HarrierDCSValues
    
        -- Query DCS for the current state of ODU and UFC
        local av88HarrierODU = getDCSListIndication(6)
        local av88HarrierUFC = getDCSListIndication(5)

        -- Get the scratch pad values (Example ON  16) for Tacan on channel 16.
        local ufcLeftStrings = cleanText(av88HarrierUFC.ufc_left_position)
        local ufcLeftString1 = string.sub(ufcLeftStrings, 1, 1)
        local ufcLeftString2 = string.sub(ufcLeftStrings, 2, 2)

        -- Cued Windows are any window with a ':' indicating the window is selected
        local selectedWindows = {}
        for _key, _val in pairs(av88HarrierODU) do
            if _val == ":" then 
                local windowPos = string.sub(_key, 12, 12)
                selectedWindowPositionString = tostring(windowPos)
                table.insert(selectedWindows, selectedWindowPositionString)
            end
        end

        -- Generate the required SimApp Pro values to "mock" the F18 UFC with AV88 values
        -- In theory, you could replace these with a custom value from another module, and have them appear on the DCS UFC
        return buildSimAppProUFCPayload({
            option1=cleanText(av88HarrierODU.ODU_Option_1_Text),
            option2=cleanText(av88HarrierODU.ODU_Option_2_Text),
            option3=cleanText(av88HarrierODU.ODU_Option_3_Text),
            option4=cleanText(av88HarrierODU.ODU_Option_4_Text),
            option5=cleanText(av88HarrierODU.ODU_Option_5_Text),
            scratchPadNumbers=cleanText(av88HarrierUFC.ufc_right_position),
            scratchPadString1=(ufcLeftString1),
            scratchPadString2=cleanText(ufcLeftString2),
            com1=cleanText(av88HarrierUFC.ufc_chnl_1_m),
            com2=cleanText(av88HarrierUFC.ufc_chnl_2_m),
            selectedWindows=selectedWindows
        })
    end
end

function ufcPatch.getUFCPayloadByModuleType(moduleName)
    if moduleName == 'AV8BNA' then
        return ufcPatch.generateUFCDataForAV88()
    elseif moduleName == "UH-1H" then
        return ufcPatch.generateUFCDataForHuey()
    end
    return nil
end

return ufcPatch
