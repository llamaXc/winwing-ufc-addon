local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchHerc = {}

function ufcPatchHerc.generateUFCData()

local MainPanel = GetDevice(0)
local UHFRadio = GetDevice(18) 
local UHFFreq = UHFRadio:get_frequency()

	--Radar Altitude FC3
	local FC3RadarAlt = {
	math.floor(((LoGetAltitudeAboveGroundLevel()))*3.28)-14 --Covert meters to feet & account for airframe offset 
	}

    local FC3RadarAltitudeString = ""
    for index, value in ipairs(FC3RadarAlt) do
        local FC3RadarAltitudeStringToAppend = value
		if value <= 0.9 then 
			FC3RadarAltitudeStringToAppend = 0      
		elseif value >= 99999 then
            FC3RadarAltitudeStringToAppend = 99999
        end
        FC3RadarAltitudeString = tostring(value)
		if value >= 10000 then 
		FC3RadarAltitudeString = math.floor(value/1000).."K"
		elseif value < 10 then 
		FC3RadarAltitudeString = "000"..value
		elseif value >= 1000 then 
		FC3RadarAltitudeString = ""..value
		elseif (value >= 100 and value <= 999) then 
		FC3RadarAltitudeString = "0"..value
		elseif (value >= 10 and value <= 99) then
		FC3RadarAltitudeString = "00"..value
		end 
    end
	
	--Heading (Magnetic) 
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
	
	--Fuel (Total)	
	local Fueldigits = {math.floor((LoGetEngineInfo().fuel_internal)*44002)}

    local FuelString = ""
    for index, value in ipairs(Fueldigits) do
        local FueldigitToAppend = value
        if value >= 44002 then
            FueldigitToAppend = 44002
        end

		FuelSting = tostring(value)
		if value >= 10000 then 
			FuelString = math.floor(value/1000).."K"
		elseif value < 10000 then 
			FuelString = value
		end
    end
	
	--Airspeed
	local Airspeeddigits = {math.floor(LoGetIndicatedAirSpeed()*1.943)}  --Convert Meters per Second to Knots

    local AirspeedString = ""
    for index, value in ipairs(Airspeeddigits) do
        local AirspeeddigitToAppend = value
        if value >= 9999 then
            AirspeeddigitToAppend = 9999
        end
        AirspeedString = AirspeedString..AirspeeddigitToAppend
    end

	--Countermeassures 
	local Flaredigits = {math.floor(LoGetSnares().flare)}
	
	local FlareString = ""
	for index, value in ipairs(Flaredigits) do 
		local FlaredigitsToAppend = value 
		if value >= 99 then 
			FlaredigitsToAppend = 99
		end 
		FlareString = FlareString..FlaredigitsToAppend
	end
	
	local Chaffdigits = {math.floor(LoGetSnares().chaff)}
	
	local ChaffString = ""
	for index, value in ipairs(Chaffdigits) do 
		local ChaffdigitsToAppend = value 
		if value >= 99 then 
			ChaffdigitsToAppend = 99
		end 
		ChaffString = ChaffString..ChaffdigitsToAppend
	end
	
	--AN/ARC 164 UHF
	local UHFdigits = {math.floor(UHFFreq / 1000)}
	
    local UHFString = ""
    for index, value in ipairs(UHFdigits) do
        local UHFdigitToAppend = value
        if value >= 399975 then
            UHFdigitToAppend = 399975
        end
        UHFString = UHFString..UHFdigitToAppend	
    end

	--Send info to UFC components 
    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=UHFString, --UHF Radio Freq 
        option1=FC3RadarAltitudeString,  -- Radar Alt
		option2=HeadingString, --Magnetic Heading
		option3=FuelString,  --Total Fuel (Pounds) 
		option4=AirspeedString, --True Airspeed (Knots)    
        option5="C130", 
		com1=FlareString, --Flare Counter
		com2=ChaffString, --Chaff Counter
		scratchPadString1="U", 
		scratchPadString2="H"	 
    })
end

return ufcPatchHerc --v1.0 by ANDR0ID 