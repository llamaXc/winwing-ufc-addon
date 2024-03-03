ufcPatchUtils={}

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

    for index, windowPosition in ipairs(selectedWindows) do
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

local buildSimAppProComPayload = function(comString)
    -- SimApp treats 10-20 sepcial. "`0" == 10
    local comNumber = tonumber(comString)
    local comResultString = comString
    if type(comNumber) == "number" then
        if comNumber >= 10 and comNumber < 20 then comResultString = "`"..(comNumber % 10) end
    end
    return comResultString
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
    local cuedWindowsPayload = buildSimAppProCuedWindowPayload(simAppProUFCDataMap.selectedWindows)
    local com1StringValue = buildSimAppProComPayload(simAppProUFCDataMap.com1)
    local com2StringValue = buildSimAppProComPayload(simAppProUFCDataMap.com2)
    local com1 = buildSimAppProUFCCommand("UFC_Comm1Display", cleanText(com1StringValue))
    local com2 = buildSimAppProUFCCommand("UFC_Comm2Display", cleanText(com2StringValue))
    return option1..option2..option3..option4..option5..com1..com2..scratchDigits..scratchLeftString..scrathRightString..cuedWindowsPayload
end

--ANDR0ID Added 
	--Genaric Functions Which Can Be Called Accross Multiple Profiles 
	
	--Radar Altitude in Feet (Will be off due to various airframe offsets) 
function ufcPatchUtils.GenaricRadarAltitudeFeet()
	local FC3RadarAltFeet = {
	math.floor(((LoGetAltitudeAboveGroundLevel()))*3.28)-0 --Covert meters to feet & account for airframe offset 
	}
    local FC3RadarAltitudeStringFeet = ""
    for index, value in ipairs(FC3RadarAltFeet) do
        local FC3RadarAltitudeStringFeetToAppend = value
		if value <= 0.9 then 
			FC3RadarAltitudeStringFeetToAppend = 0      
		elseif value >= 99999 then
            FC3RadarAltitudeStringFeetToAppend = 99999
        end
        FC3RadarAltitudeStringFeet = tostring(value)
		if value >= 10000 then 
		FC3RadarAltitudeStringFeet = math.floor(value/1000).."K"
		elseif value < 10 then 
		FC3RadarAltitudeStringFeet = "000"..value
		elseif value >= 1000 then 
		FC3RadarAltitudeStringFeet = ""..value
		elseif (value >= 100 and value <= 999) then 
		FC3RadarAltitudeStringFeet = "0"..value
		elseif (value >= 10 and value <= 99) then
		FC3RadarAltitudeStringFeet = "00"..value
		end 
    end
	return FC3RadarAltitudeStringFeet
end	

	--Radar Altitude in Meters (Will be off due to various airframe offsets) 
function ufcPatchUtils.GenaricRadarAltitudeMeters()
	local FC3RadarAltMeters = {
	math.floor(((LoGetAltitudeAboveGroundLevel())))
	}
    local FC3RadarAltitudeStringMeters = ""
    for index, value in ipairs(FC3RadarAltMeters) do
        local FC3RadarAltitudeStringMetersToAppend = value
		if value <= 0.9 then 
			FC3RadarAltitudeStringMetersToAppend = 0      
		elseif value >= 99999 then
            FC3RadarAltitudeStringMetersToAppend = 99999
        end
        FC3RadarAltitudeStringMeters = tostring(value)
		if value >= 10000 then 
		FC3RadarAltitudeStringMeters = math.floor(value/1000).."K"
		elseif value < 10 then 
		FC3RadarAltitudeStringMeters = "000"..value
		elseif value >= 1000 then 
		FC3RadarAltitudeStringMeters = ""..value
		elseif (value >= 100 and value <= 999) then 
		FC3RadarAltitudeStringMeters = "0"..value
		elseif (value >= 10 and value <= 99) then
		FC3RadarAltitudeStringMeters = "00"..value
		end 
    end
	return FC3RadarAltitudeStringMeters
end	

	--Barometric Altitude in Feet (Will be off due to various airframe offsets) 
function ufcPatchUtils.GenaricBaroAltitudeFeet()
	local FC3BaroAltFeet = {
	math.floor(((LoGetAltitudeAboveSeaLevel()))*3.28)-0 --Covert meters to feet & account for airframe offset 
	}
    local FC3BaroAltitudeStringFeet = ""
    for index, value in ipairs(FC3BaroAltFeet) do
        local FC3BaroAltitudeStringFeetToAppend = value
		if value <= 0.9 then 
			FC3BaroAltitudeStringFeetToAppend = 0      
		elseif value >= 99999 then
            FC3BaroAltitudeStringFeetToAppend = 99999
        end
        FC3BaroAltitudeStringFeet = tostring(value)
		if value >= 10000 then 
		FC3BaroAltitudeStringFeet = math.floor(value/1000).."K"
		elseif value < 10 then 
		FC3BaroAltitudeStringFeet = "000"..value
		elseif value >= 1000 then 
		FC3BaroAltitudeStringFeet = ""..value
		elseif (value >= 100 and value <= 999) then 
		FC3BaroAltitudeStringFeet = "0"..value
		elseif (value >= 10 and value <= 99) then
		FC3BaroAltitudeStringFeet = "00"..value
		end 
    end
	return FC3BaroAltitudeStringFeet
end	

	--Barometric Altitude in Meters (Will be off due to various airframe offsets)
function ufcPatchUtils.GenaricBaroAltitudeMeters()
	local FC3BaroAltMeters = {
	math.floor(((LoGetAltitudeAboveSeaLevel())))
	}
    local FC3BaroAltitudeStringMeters = ""
    for index, value in ipairs(FC3BaroAltMeters) do
        local FC3BaroAltitudeStringMetersToAppend = value
		if value <= 0.9 then 
			FC3BaroAltitudeStringMetersToAppend = 0      
		elseif value >= 99999 then
            FC3BaroAltitudeStringMetersToAppend = 99999
        end
        FC3BaroAltitudeStringMeters = tostring(value)
		if value >= 10000 then 
		FC3BaroAltitudeStringMeters = math.floor(value/1000).."K"
		elseif value < 10 then 
		FC3BaroAltitudeStringMeters = "000"..value
		elseif value >= 1000 then 
		FC3BaroAltitudeStringMeters = ""..value
		elseif (value >= 100 and value <= 999) then 
		FC3BaroAltitudeStringMeters = "0"..value
		elseif (value >= 10 and value <= 99) then
		FC3BaroAltitudeStringMeters = "00"..value
		end 
    end
	return FC3BaroAltitudeStringMeters
end

	--Airspeed Knots
function ufcPatchUtils.AirspeedKnots()
	local AirspeeddigitsKts = {math.floor(LoGetIndicatedAirSpeed()*1.943)}  --Convert Meters per Second to Knots

    local AirspeedStringKts = ""
    for index, value in ipairs(AirspeeddigitsKts) do
        local AirspeeddigitKtsToAppend = value
        if value >= 9999 then
            AirspeeddigitToAppend = 9999
        end
        AirspeedStringKts = AirspeedStringKts..AirspeeddigitKtsToAppend
    end
	return AirspeedStringKts
end
	
		--Airspeed MPS
function ufcPatchUtils.AirspeedMPS()
	local AirspeeddigitsMPS = {math.floor(LoGetIndicatedAirSpeed())}  --Meters per Second

    local AirspeedStringMPS = ""
    for index, value in ipairs(AirspeeddigitsMPS) do
        local AirspeeddigitMPSToAppend = value
        if value >= 9999 then
            AirspeeddigitToAppend = 9999
        end
        AirspeedStringMPS = AirspeedStringMPS..AirspeeddigitMPSToAppend
    end
	return AirspeedStringMPS
end

	--Heading (Magnetic) 
function ufcPatchUtils.MagHeading()
    local Headingdigits =  {math.floor(LoGetMagneticYaw()* (180/math.pi))} 
	
	local HeadingString = ""
    for index, value in ipairs(Headingdigits) do
        local HeadingdigitToAppend = value
        if value >= 360 then
            HeadingdigitToAppend = 0
        end
        HeadingString = tostring(value) 
		if value == -7 then 
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
	return HeadingString
end

	--Fuel (Total)	
function ufcPatchUtils.TotalFuel()
	local Fueldigits = {math.floor((LoGetEngineInfo().fuel_internal)*100)} --How this displays varies by airframe... should be percentage, but may be signifincalty wrong (ie kg, etc)
	
    local FuelString = ""
    for index, value in ipairs(Fueldigits) do
        local FueldigitToAppend = value
        if value >= 9999 then --Value may need editing depending on airframe
            FueldigitToAppend = 9999
        end

		FuelSting = tostring(value)
		if value >= 10000 then 
			FuelString = math.floor(value/1000).."K"
		elseif value < 10000 then 
			FuelString = value
		end
    end
	return FuelSting
end

	--Vertical Velocity 
--Feet per Min 
function ufcPatchUtils.VerticalV_FPM()
	local VerticalSpeed = {math.floor(LoGetVerticalVelocity()*196.85)}  --Feet per Min

    local VerticalFPM = ""
    for index, value in ipairs(VerticalSpeed) do
        local VerticalFPMtoAppend = value
        if value >= 9999 then
            VerticalFPMtoAppend  = 9999
		elseif value <= -9999 then 
			VerticalFPMtoAppend = -9999
        end
        VerticalFPM = tostring(value)
		if value <= -1000 then 
		VerticalFPM = "-"..math.abs(value)
		elseif (value > -1000 and value <= -100) then 
		VerticalFPM = "-0"..math.abs(value)
		elseif (value > -100 and value <= -10) then 
		VerticalFPM = "-00"..math.abs(value)
		elseif value < 0 then 
		VerticalFPM = "-000"..math.abs(value)
		elseif value < 10 then 
		VerticalFPM = "000"..value
		elseif value >= 1000 then 
		VerticalFPM = ""..value
		elseif (value >= 100 and value <= 999) then 
		VerticalFPM = "0"..value
		elseif (value >= 10 and value <= 99) then
		VerticalFPM = "00"..value
		end 
    end
	return VerticalFPM
end
--Meters per Second
function ufcPatchUtils.VerticalV_MPS()
	local AirspeeddigitsMPS = {math.floor(LoGetVerticalVelocity())}  --Meters per Second

    local VerticalMPS = ""
    for index, value in ipairs(AirspeeddigitsMPS) do
        local VerticalMPStoAppend = value
        if value >= 9999 then
            VerticalMPStoAppend = 9999
		elseif value <= -9999 then 
			VerticalMPStoAppend = -9999
        end
        VerticalMPS = tostring(value)
		if value <= -1000 then 
		VerticalMPS = "-"..math.abs(value)
		elseif (value > -1000 and value <= -100) then 
		VerticalMPS = "-0"..math.abs(value)
		elseif (value > -100 and value <= -10) then 
		VerticalMPS = "-00"..math.abs(value)
		elseif value < 0 then 
		VerticalMPS = "-000"..math.abs(value)
		elseif value < 10 then 
		VerticalMPS = "000"..value
		elseif value >= 1000 then 
		VerticalMPS = ""..value
		elseif (value >= 100 and value <= 999) then 
		VerticalMPS = "0"..value
		elseif (value >= 10 and value <= 99) then
		VerticalMPS = "00"..value
		end 
    end
	return VerticalMPS
end

	--Countermeassures (Limited to 99 based of the assumption they will be displayed on Com1/2 which can only display two digits)
function ufcPatchUtils.flares() 
	local Flaredigits = {math.floor(LoGetSnares().flare)}
	
	local FlareString = ""
	for index, value in ipairs(Flaredigits) do 
		local FlaredigitsToAppend = value 
		if value >= 99 then 
			FlaredigitsToAppend = 99
		end 
		FlareString = FlareString..FlaredigitsToAppend
	end
	return FlareString
end

function ufcPatchUtils.chaff()
	local Chaffdigits = {math.floor(LoGetSnares().chaff)}
	
	local ChaffString = ""
	for index, value in ipairs(Chaffdigits) do 
		local ChaffdigitsToAppend = value 
		if value >= 99 then 
			ChaffdigitsToAppend = 99
		end 
		ChaffString = ChaffString..ChaffdigitsToAppend
	end
	return ChaffString
end 
--End ANDR0ID Added --Updated 01MAR24

return ufcPatchUtils