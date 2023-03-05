local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchHOKUM = {}

function ufcPatchHOKUM.generateUFCData()
    local MainPanel = GetDevice(0)

    local HOKUMPVI = ufcUtils.getDCSListIndication(5)
    local HOKUMWPNS = ufcUtils.getDCSListIndication(6)
    local HOKUMUV26 = ufcUtils.getDCSListIndication(7)
    local HUD = ufcUtils.getDCSListIndication(1)

    -- Indicated Airspeed
    local airspeed = math.floor(MainPanel:get_argument_value(51) * 350)
    if airspeed < 100 then
        airspeed = string.format("S %02d", airspeed)
    else
        airspeed = string.format("S%d", airspeed)
    end

    -- Variometer
    local variometerRate = math.floor(MainPanel:get_argument_value(24) * 30)
    local symbol = ""
    local rateString = ""
    if variometerRate < 0 then
        symbol = "-"
        rateString = string.format("%02d", math.abs(variometerRate))
    elseif variometerRate > 0 then
        rateString = string.format(" %02d", variometerRate)
    end

    -- Barometric altitude
    local baltTxt = HUD.txt_BALT
    local raltTxt = HUD.txt_RALT

	local displayAltitude = "0"
    if raltTxt ~= nil then
        displayAltitude = raltTxt
    elseif baltTxt ~= nil then
        -- Remove the + shown on balt hud
        displayAltitude = baltTxt:gsub("+", "")
    end

    log.write("WWT", log.INFO, "Display alt: "..displayAltitude)

    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers = HOKUMPVI.txt_VIT,
        option1 = HOKUMPVI.txt_NIT,
        scratchPadString1 = HOKUMPVI.txt_OIT_PPM,
        scratchPadString2 = HOKUMPVI.txt_OIT_NOT,
        option2 = displayAltitude,	
        option3 = "V" .. symbol .. rateString,
        option4 = airspeed,
        option5 = HOKUMUV26.txt_digits,
        com1 = HOKUMWPNS.txt_weap_count,
        com2 = HOKUMWPNS.txt_cannon_count
    })
end

return ufcPatchHOKUM