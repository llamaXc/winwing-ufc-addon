local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchAV88 = {}

local prevAV88HarrierValues

-- -- AV88 Harrier: Shows ODU and UFC values
function ufcPatchAV88.generateUFCData()
    -- Avoid extra work by checking the base values up front. ODU + UFC == string of DCS Values
    -- Good practice to check the DCS value for any change before making the whole UFC Payload message
    local av88HarrierDCSValues = list_indication(6)..list_indication(5)
    if av88HarrierDCSValues ~= prevAV88HarrierValues  then

        -- Update prev values
        prevAV88HarrierValues = av88HarrierDCSValues

        -- Query DCS for the current state of ODU and UFC
        local av88HarrierODU = ufcUtils.getDCSListIndication(6)
        local av88HarrierUFC = ufcUtils.getDCSListIndication(5)

        if av88HarrierODU ~= nil and av88HarrierUFC ~= nil then

            -- Get the scratch pad values (Example ON  16) for Tacan on channel 16.
            local ufcLeftStrings = av88HarrierUFC.ufc_left_position
            if ufcLeftStrings == nil then
                ufcLeftStrings = "  "
            end
            
            local ufcLeftString1 = string.sub(ufcLeftStrings, 1, 1)
            local ufcLeftString2 = string.sub(ufcLeftStrings, 2, 2)

            -- Cued Windows are any window with a ':' indicating the window is selected
            local selectedWindows = {}
            for _key, _val in pairs(av88HarrierODU) do
                if _val == ":" then 
                    local windowPos = string.sub(_key, 12, 12)
                    local selectedWindowPositionString = tostring(windowPos)
                    table.insert(selectedWindows, selectedWindowPositionString)
                end
            end

            -- Generate the required SimApp Pro values to "mock" the F18 UFC with AV88 values
            -- In theory, you could replace these with a custom value from another module, and have them appear on the DCS UFC
            return ufcUtils.buildSimAppProUFCPayload({
                option1=av88HarrierODU.ODU_Option_1_Text,
                option2=av88HarrierODU.ODU_Option_2_Text,
                option3=av88HarrierODU.ODU_Option_3_Text,
                option4=av88HarrierODU.ODU_Option_4_Text,
                option5=av88HarrierODU.ODU_Option_5_Text,
                scratchPadNumbers=av88HarrierUFC.ufc_right_position,
                scratchPadString1=ufcLeftString1,
                scratchPadString2=ufcLeftString2,
                com1=av88HarrierUFC.ufc_chnl_1_m,
                com2=av88HarrierUFC.ufc_chnl_2_m,
                selectedWindows=selectedWindows
            })
        end
    end
end

return ufcPatchAV88