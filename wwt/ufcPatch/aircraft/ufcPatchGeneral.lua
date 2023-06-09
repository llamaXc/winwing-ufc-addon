local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchGeneral = {}

function ufcPatchGeneral.generateUFCData()

local MainPanel = GetDevice(0)

	local FC3RadarAltitudeString = ufcPatchUtils.GenaricRadarAltitudeFeet()
	local HeadingString = ufcPatchUtils.MagHeading()
	local AirspeedString = ufcPatchUtils.AirspeedKnots()
	local FuelString = ufcPatchUtils.TotalFuel()
	local Vertical = ufcPatchUtils.VerticalV_FPM()
	local FlareCount = ufcPatchUtils.flares()
	local ChaffCount = ufcPatchUtils.chaff()
	
	--Send info to UFC components 
    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=Vertical,
        option1=FC3RadarAltitudeString,  
		option2=HeadingString, 
		option3=FuelString,   --May be significantly incorrect depending on module, should be % but could be kg or other 
		option4=AirspeedString,   
        option5="GNRL", 
		com1=FlareCount, 
		com2=ChaffCount, 
		scratchPadString1="", 
		scratchPadString2="V"	 
    })
end

return ufcPatchGeneral --v2.0 by ANDR0ID 

--[[ Other avaliable functions
ufcPatchUtils.GenaricRadarAltitudeFeet()
ufcPatchUtils.GenaricRadarAltitudeMeters()
ufcPatchUtils.GenaricBaroAltitudeFeet()
ufcPatchUtils.GenaricBaroAltitudeMeters()
ufcPatchUtils.AirspeedKnots()
ufcPatchUtils.AirspeedMPS()
ufcPatchUtils.MagHeading()
ufcPatchUtils.TotalFuel()
ufcPatchUtils.VerticalV_FPM()
ufcPatchUtils.VerticalV_MPS()
ufcPatchUtils.flares() 
ufcPatchUtils.chaff()
]]