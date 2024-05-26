local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchPHANTOM = {}

function ufcPatchPHANTOM.generateUFCData()

    local MainPanel = GetDevice(0)
    local PILOT_RADIO_REPEATER = ufcUtils.getDCSListIndication(9) --UHF RADIO CHANNEL
	
	local AltValue = math.floor((LoGetAltitudeAboveSeaLevel() * 3.281) / 10) * 10
    local BAltString = string.format("%02dK%d", math.floor(AltValue / 1000), math.floor((AltValue % 1000) / 100))
    local RAltValue = math.floor((LoGetAltitudeAboveGroundLevel() * 3.281) / 10) * 10
    local RAltString = "R" .. string.format('%.0f', RAltValue)
    local Altitudes = (RAltValue > 999) and BAltString or RAltString
		
	-- TAS by gauge
	local TAS_ones = GetDevice(0):get_argument_value(109)
    local TAS_tens = GetDevice(0):get_argument_value(110)
    local TAS_hundreds = GetDevice(0):get_argument_value(111)
    local TAS = "T" .. TAS_hundreds * 1000 + TAS_tens * 100 + TAS_ones * 10
	
	-- IAS
	local IAS = string.format('%d', math.floor(LoGetIndicatedAirSpeed() * 1.943844))
	local TAS = string.format('%d', math.floor(LoGetTrueAirSpeed() * 1.943844))
	local SPEED = "I" .. IAS
	local TRUESPEED = "T" .. TAS
	
	
-- TACAN
    local Pilot_TACAN_Chan_Ones = MainPanel:get_argument_value(643)
    local Pilot_TACAN_Chan_Tens = MainPanel:get_argument_value(644)
    local Pilot_TACAN_Chan_Hundreds = MainPanel:get_argument_value(645)
    local PILOT_TACAN_XY_DIAL = MainPanel:get_argument_value(656) > 0.5 and "Y" or "X"

    local _, tens_decimal = math.modf(Pilot_TACAN_Chan_Tens)
    if tens_decimal > 0.91 then tens_decimal = 0 end

    local PILOT_TACAN = string.format("%.0f%.0f%.0f%s",
        Pilot_TACAN_Chan_Hundreds * 10, tens_decimal * 10, Pilot_TACAN_Chan_Ones * 10, PILOT_TACAN_XY_DIAL)
 
 
	-- Angle of Attack
	local AOA = string.format("%.1f", MainPanel:get_argument_value(70) * 30)
	local ANGLE = "A" .. AOA
	
	-- Pitch Angle
	local PITCH = string.format("%03d", MainPanel:get_argument_value(615) * -180)
	
	-- AOA and PITCH for scratchPadNumbers
	local SCRATCH = PITCH .. " " .. AOA
		
	-- BEARING Thanks Andr0id
    local Headingdigits =  {math.floor(LoGetMagneticYaw()* (180/math.pi))} 
	local HeadingString = ""
    for index, value in ipairs(Headingdigits) do
        local HeadingdigitToAppend = value
        if value >= 360 then
            HeadingdigitToAppend = 0
        end
        HeadingString = tostring(value) 
		if value == -7 then --These strings needed as there is a "negative heading bug" with LoGet
			HeadingString = "353M"
		elseif value == -6 then 
			HeadingString = "354M"
		elseif value == -5 then 
			HeadingString = "355M" 
		elseif value == -4 then 
			HeadingString = "356M"
		elseif value == -3 then 
			HeadingString = "357M"
		elseif value == -2 then 
			HeadingString = "358M"
		elseif value == -1 then 
			HeadingString = "359M"
		elseif value < 10 then 
			HeadingString = "00"..value.."M" 
		elseif value >= 100 then 
			HeadingString = ""..value.."M" 
		elseif value >= 10 then 
			HeadingString = "0"..value.."M"
		end
    end	
	
	local Fuelpercentage = string.format("%03d", math.floor(LoGetEngineInfo().fuel_internal * 100))

    local Flaredigits = math.min(99, LoGetSnares().flare)
    local Chaffdigits = math.min(99, LoGetSnares().chaff)
    local SNARES

    if Flaredigits == 0 and Chaffdigits > 0 then
        SNARES = Chaffdigits
    elseif Chaffdigits == 0 and Flaredigits > 0 then
        SNARES = Flaredigits
    elseif Flaredigits == 0 and Chaffdigits == 0 then
        SNARES = "00"
    else
        SNARES = math.min(Flaredigits, Chaffdigits)
    end
	
	-- Split the radio frequency into two digits
    local freq = tonumber(PILOT_RADIO_REPEATER.freq_foreground)
    local scratchPadString1, scratchPadString2 = "0", "0"
    if freq then
        scratchPadString1 = string.format("%01d", math.floor(freq / 10))
        scratchPadString2 = string.format("%01d", freq % 10)
    end
	
	
	
		return ufcUtils.buildSimAppProUFCPayload({
        option1 = PILOT_TACAN or "TACN",
        option2 = SPEED or " IAS",
        option3 = Altitudes or "ALTS",
        option4 = "B" .. HeadingString or " HDG",
        option5 = "F" .. Fuelpercentage or "FUEL",
        scratchPadNumbers = SCRATCH or "123",
        scratchPadString1 = scratchPadString1 or "C",
        scratchPadString2 = scratchPadString2 or "H",
        com1 = Flaredigits or "F",
        com2 = Chaffdigits or "C",
        selectedWindows = {}
    })
end

return ufcPatchPHANTOM