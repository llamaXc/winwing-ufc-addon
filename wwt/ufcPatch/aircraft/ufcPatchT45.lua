local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchT45 = {}

function ufcPatchT45.generateUFCData()

local MainPanel = GetDevice(0)
local Radio1 = GetDevice(1)
local Radio2 = GetDevice(2)
local MasterArm = GetDevice(0):get_argument_value(114)
local RadioPTT = GetDevice(0):get_argument_value(294)
local IC_PTT = GetDevice(0):get_argument_value(295)

local Radio1Freq = Radio1:get_frequency()
local Radio2Freq = Radio2:get_frequency()

	--Radar Altitude FC3
	local FC3RadarAlt = {
	math.floor((LoGetAltitudeAboveGroundLevel())*3.28)-5 --Covert meters to feet & account for airframe offset 
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
	local Fueldigits = {math.floor((LoGetEngineInfo().fuel_internal)*2903)} --Coverts % fuel to pounds 

    local FuelString = ""
    for index, value in ipairs(Fueldigits) do
        local FueldigitToAppend = value
        if value >= 3000 then
            FueldigitToAppend = 3000
        end
        FuelString = FuelString..FueldigitToAppend
    end
	
	--Airspeed
	local Airspeeddigits = {math.floor(LoGetIndicatedAirSpeed()*1.943)}  --Convert Meters per Second to Knots

    local AirspeedString = ""
    for index, value in ipairs(Airspeeddigits) do
        local AirspeeddigitToAppend = value
        if value >= 700 then
            AirspeeddigitToAppend = 700
        end
        AirspeedString = AirspeedString..AirspeeddigitToAppend
    end
	
	--Radio 1 ARC 182
	local VHFdigits1 = {math.floor(Radio1Freq / 1000)}
	
    local VHFString1 = ""
    for index, value in ipairs(VHFdigits1) do
        local VHFdigit1ToAppend = value
        if value >= 400000 then
            VHFdigit1ToAppend = 400000
        end
        VHFString1 = VHFString1..VHFdigit1ToAppend	
    end
	
	--Radio 2 ARC 182
	local VHFdigits2 = {math.floor(Radio2Freq / 1000)}
	
    local VHFString2 = ""
    for index, value in ipairs(VHFdigits2) do
        local VHFdigit2ToAppend = value
        if value >= 400000 then
            VHFdigit2ToAppend = 400000
        end
        VHFString2 = VHFString2..VHFdigit2ToAppend	
    end

	--FREQ Data
	if IC_PTT == 1 then 
	VHFString = "0000"
	Pad1 = "I"
	Pad2 = "C"
	elseif RadioPTT == 1 then 
	VHFString = VHFString1
	Pad1 = "V" 
	Pad2 = "H"
	elseif RadioPTT == -1 then 
	VHFString = VHFString2
	Pad1 = "V" 
	Pad2 = "H"
	end

	--Master Arm 
	if MasterArm == 1 then 
	MasterArmString = "ARMD"
	elseif MasterArm == 0 then 
	MasterArmString = "SAFE"
	end 

	--Send info to UFC components 
    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=VHFString, --Freq of Slectected Radio 
        option1=FC3RadarAltitudeString,  
		option2=HeadingString, 
		option3=FuelString,   
		option4=AirspeedString,   
        option5=MasterArmString, 
		com1="T", 
		com2="45", 
		scratchPadString1=Pad1, 
		scratchPadString2=Pad2	 
    })
end

return ufcPatchT45 --v1.0 by ANDR0ID 