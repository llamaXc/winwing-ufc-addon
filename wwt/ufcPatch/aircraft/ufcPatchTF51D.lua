local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchTF51D = {}

function ufcPatchTF51D.generateUFCData()

    local MainPanel = GetDevice(0)
    local VHFRadio = GetDevice(24)

    local VHFFreq = VHFRadio:get_frequency()


        --Altimeter
        local barodigits = {
            math.floor(MainPanel:get_argument_value(96) * 100000)
        }

        local AltitudeString = ""
        for index, value in ipairs(barodigits) do
            local barodigitToAppend = value
            if value >= 9999 then
                barodigitToAppend = 9999
            end
            AltitudeString = tostring(value)
            if value < 10 then
            AltitudeString = "000"..value
            elseif value >= 1000 then
            AltitudeString = ""..value
            elseif (value >= 100 and value <= 999) then
            AltitudeString = "0"..value
            elseif (value >= 10 and value <= 99) then
            AltitudeString = "00"..value
            end
        end

        --Heading
        local Headingdigits = {math.floor(MainPanel:get_argument_value(12) * 360)}

        local HeadingString = ""
        for index, value in ipairs(Headingdigits) do
            local HeadingdigitToAppend = value
            if value >= 360 then
                HeadingdigitToAppend = 0
            end
            HeadingString = tostring(value)
            if value < 10 then
                HeadingString = "00"..value.."T"
            elseif value >= 100 then
                HeadingString = ""..value.."T"
            elseif value >= 10 then
                HeadingString = "0"..value.."T"
            end
        end

        --SCR-522A VHF
        local VHFdigits = {math.floor(VHFFreq / 1000)}

        local VHFString = ""
        for index, value in ipairs(VHFdigits) do
            local VHFdigitToAppend = value
            if value >= 157000 then
                VHFdigitToAppend = 157000
            end
            VHFString = VHFString..VHFdigitToAppend
        end

        --Send info to UFC components
        return ufcUtils.buildSimAppProUFCPayload({
            scratchPadNumbers=VHFString, --Freq of Slectected Radio
            option1=AltitudeString,
            option2=HeadingString,
            option3="XXXX",
            option4="XXXX",
            option5="XXXX",
            com1="5",
            com2="1",
            scratchPadString1="V",
            scratchPadString2="H"
        })
end

return ufcPatchTF51D --v1.0 by ANDR0ID