local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchAH6J = {}

function ufcPatchAH6J.generateUFCData()

local MainPanel = GetDevice(0)
local PwrSwpos = MainPanel:get_argument_value(15) --AH-6J Inverter switch 
local MasterArm = MainPanel:get_argument_value(43) 
local RocketArm = MainPanel:get_argument_value(47)
local GunArm = MainPanel:get_argument_value(48) 
local ArmStatus = "SAFE" 

	if PwrSwpos == 1 then

	FC3RadarAltitudeString = (ufcPatchUtils.GenaricRadarAltitudeFeet()-5) --Account for 5ft airframe offset 
	HeadingString = ufcPatchUtils.MagHeading()
	AirspeedString = ufcPatchUtils.AirspeedKnots()
	FuelString = ((ufcPatchUtils.TotalFuel()/100)*798) -- Conversion to lbs
	Vertical = ufcPatchUtils.VerticalV_FPM()
	Vpad = "V"
	
		--Armament Status 
		if (MasterArm == 1) and (RocketArm ~= 0) and (GunArm ~= 0) then 
			ArmStatus = "ARMD" 
		elseif (MasterArm == 1) and (RocketArm == 0) and (GunArm ~= 0) then 
			ArmStatus = "GUNS" 
		elseif (MasterArm == 1) and (RocketArm ~= 0) and (GunArm == 0) then
			ArmStatus = "RKTS"
		elseif (MasterArm == 0) then
			ArmStatus = "SAFE" 
		end 	
		
	elseif PwrSwpos == 0 then 
	FC3RadarAltitudeString = ""
	HeadingString = ""
	AirspeedString = ""
	FuelString = ""
	Vertical = ""
	ArmStatus = ""	
	Vpad = ""	
	end 
	
	--Send info to UFC components 
    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=Vertical,
        option1=FC3RadarAltitudeString,  
		option2=HeadingString, 
		option3=FuelString,  
		option4=AirspeedString,   
        option5=ArmStatus, 
		com1="A", 
		com2="6", 
		scratchPadString1="", 
		scratchPadString2=Vpad	 
    })
end

return ufcPatchAH6J --v2.0 by ANDR0ID 

