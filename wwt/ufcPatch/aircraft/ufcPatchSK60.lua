local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchSK60 = {}

function ufcPatchSK60.generateUFCData()

local MainPanel = GetDevice(0)
local PwrSwpos = MainPanel:get_argument_value(401) 
local MasterArm = MainPanel:get_argument_value(413) 
FlareCount = ufcPatchUtils.flares()
ChaffCount = ufcPatchUtils.chaff()

	if PwrSwpos == 1 then 

	FC3RadarAltitudeString = (ufcPatchUtils.GenaricRadarAltitudeFeet()-3) --Account for 3ft airframe offset 
	HeadingString = ufcPatchUtils.MagHeading()
	AirspeedString = ufcPatchUtils.AirspeedKnots()
	FuelString = ((ufcPatchUtils.TotalFuel()/100)*3616) -- Conversion to lbs
	Vertical = ufcPatchUtils.VerticalV_FPM()
	FlareCount = ufcPatchUtils.flares()
	ChaffCount = ufcPatchUtils.chaff()
	Vpad = "V"
	
		--Armament Status 
		if (MasterArm == 1) then 
			ArmStatus = "ARMD" 
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
	FlareCount = ""
	ChaffCount = ""
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
		com1=FlareCount, 
		com2=ChaffCount,
		scratchPadString1="", 
		scratchPadString2=Vpad	 
    })
end

return ufcPatchSK60 --v1.0 by ANDR0ID 


