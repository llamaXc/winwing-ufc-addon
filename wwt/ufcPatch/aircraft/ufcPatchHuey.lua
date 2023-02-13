local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchHuey = {}

function ufcPatchHuey.generateUFCData()

    -- Access the UH1 Main panel from DCS
    local MainPanel = GetDevice(0)

    -- Got these argument values from: <DCS_INSTALL>\Mods\aircraft\Uh-1H\Cockpit\Scripts\mainpanel_init.lua
    -- DCS get_argument_value returns floats for these values. Example: 7 = .069999999999901. We need to round to get the proper digit
    -- By adding .05 and flooring we get the proper digit shown on the altimeter.
    local digits = {
        math.floor((MainPanel:get_argument_value(468) + 0.05) * 10),
        math.floor((MainPanel:get_argument_value(469)+ 0.05) * 10),
        math.floor((MainPanel:get_argument_value(470)+ 0.05) * 10),
        math.floor((MainPanel:get_argument_value(471)+ 0.05) * 10)
    }

    -- Parse digits and build the radar alt string
    local radarAltitudeString = ""
    for index, value in ipairs(digits) do
        local digitToAppend = value
        if value >= 10 then
            digitToAppend = 0
        end
        radarAltitudeString = radarAltitudeString..digitToAppend
    end

    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=radarAltitudeString,
        option1="FEET",
        option5="UH1H"
    })
end


return ufcPatchHuey