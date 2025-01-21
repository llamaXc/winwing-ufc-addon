local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchOV10 = {}

function ufcPatchOV10.generateUFCData()

local MainPanel = GetDevice(0)
local UHFRadio = GetDevice(4) 
local PwrSwpos = MainPanel:get_argument_value(400) --OV-10 Battery 
local MasterArm = MainPanel:get_argument_value(4000) 
local ArmStatus = "SAFE" 

	if PwrSwpos ~= -1 then --0 is on for Bronco, 1 is emerg Btt, -1 is off 
	
	UHFFreq = UHFRadio:get_frequency()

	FC3RadarAltitudeString = (ufcPatchUtils.GenaricRadarAltitudeFeet()-4) --Account for 4ft airframe offset 
	HeadingString = ufcPatchUtils.MagHeading()
	AirspeedString = ufcPatchUtils.AirspeedKnots()
	FuelString = ((ufcPatchUtils.TotalFuel()/100)*2072) -- Conversion to lbs
	Vertical = ufcPatchUtils.VerticalV_FPM()
	Vpad = "V"
	
		--Armament Status 
		if (MasterArm == 1) then 
			ArmStatus = "ARMD" 
		elseif (MasterArm == 0) then
			ArmStatus = "SAFE" 
		end 
	

		
	elseif PwrSwpos == -1 then 
	FC3RadarAltitudeString = ""
	HeadingString = ""
	AirspeedString = ""
	FuelString = ""
	Vertical = ""
	ArmStatus = ""
	Vpad = ""
	end 

--Radios (Not currenlty used) 
	--UHF
	local UHFdigits = {math.floor(UHFFreq / 1000)}
	
    local UHFString = ""
    for index, value in ipairs(UHFdigits) do
        local UHFdigitToAppend = value
        if value >= 4000000 then
            UHFdigitToAppend = 4000000
        end
        UHFString = UHFString..UHFdigitToAppend	
    end
	
	--Send info to UFC components 
    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=Vertical,
        option1=FC3RadarAltitudeString,  
		option2=HeadingString, 
		option3=FuelString,  
		option4=AirspeedString,   
        option5=ArmStatus, 
		com1="", 
		com2="", 
		scratchPadString1="", 
		scratchPadString2=Vpad	 
    })
end

return ufcPatchOV10 --v1.0 by ANDR0ID 

