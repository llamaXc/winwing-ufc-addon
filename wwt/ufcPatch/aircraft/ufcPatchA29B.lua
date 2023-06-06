local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchA29B = {}

function ufcPatchA29B.generateUFCData()

local MainPanel = GetDevice(0)

local Comm1_Button = GetDevice(0):get_argument_value(451)
local Comm2_Button = GetDevice(0):get_argument_value(452)
local AG_Button = GetDevice(0):get_argument_value(454)
local Nav_Button = GetDevice(0):get_argument_value(455)
local AA_Button = GetDevice(0):get_argument_value(456)
local MasterArm = GetDevice(0):get_argument_value(781)

	--Radar Altitude FC3
	local FC3RadarAlt = {
	math.floor((LoGetAltitudeAboveGroundLevel())*3.28)-6 --Covert meters to feet & account for airframe offset 
	}

    local FC3RadarAltitudeString = ""
    for index, value in ipairs(FC3RadarAlt) do
        local FC3RadarAltitudeStringToAppend = value
		if value <= 0.9 then 
			FC3RadarAltitudeStringToAppend = 0      
		elseif value >= 9999 then
            FC3RadarAltitudeStringToAppend = 9999
        end
        FC3RadarAltitudeString = tostring(value)
		if value < 10 then 
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
	local Fueldigits = {math.floor((LoGetEngineInfo().fuel_internal)*1)} --Kg?

    local FuelString = ""
    for index, value in ipairs(Fueldigits) do
        local FueldigitToAppend = value
        if value >= 500 then
            FueldigitToAppend = 500
        end
        FuelString = FuelString..FueldigitToAppend
    end
	
	--Airspeed
	local Airspeeddigits = {math.floor(LoGetIndicatedAirSpeed()*1.943)}  --Convert Meters per Second to Knots, only shows airspeed above 50 knots

    local AirspeedString = ""
    for index, value in ipairs(Airspeeddigits) do
        local AirspeeddigitToAppend = value
        if value >= 700 then
            AirspeeddigitToAppend = 700
        end
        AirspeedString = AirspeedString..AirspeeddigitToAppend
    end

	--Master Arm 
	if MasterArm == 1 then 
	MasterArmString = "ARMD"
	elseif MasterArm == 0 then 
	MasterArmString = "SAFE"
	elseif MasterArm == -1 then 
	MasterArmString ="SIM" 
	end 
	
	--Countermeassures 
	local Flaredigits = LoGetSnares().flare
	local Chaffdigits = LoGetSnares().chaff

	--Mode String 
	if Nav_Button == 1 then 
		Pad1 ="N"
		Pad2 ="V" 
	elseif AA_Button == 1 then 
		Pad1 = "A"
		Pad2 = "A" 
	elseif AG_Button == 1 then 
		Pad1 = "A"
		Pad2 = "G"
	end 

	--Send info to UFC components 
    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers="   29  ",
        option1=FC3RadarAltitudeString,  
		option2=HeadingString, 
		option3=FuelString,   
		option4=AirspeedString,   
        option5=MasterArmString, 
		com1=Flaredigits, 
		com2=Chaffdigits, 
		scratchPadString1=Pad1, 
		scratchPadString2=Pad2	 
    })
end

return ufcPatchA29B --v1.0 by ANDR0ID 