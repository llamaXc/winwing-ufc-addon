local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchHuey = {}

function ufcPatchHuey.generateUFCData()

    -- Access the UH1 Main panel from DCS
    local MainPanel = GetDevice(0)

    -- Got these argument values from: <DCS_INSTALL>\Mods\aircraft\Uh-1H\Cockpit\Scripts\mainpanel_init.lua
    local digits = {
        math.floor(MainPanel:get_argument_value(468) * 10),
        math.floor(MainPanel:get_argument_value(469) * 10),
        math.floor(MainPanel:get_argument_value(470) * 10),
        math.floor(MainPanel:get_argument_value(471) * 10)
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