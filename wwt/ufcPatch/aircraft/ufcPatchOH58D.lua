local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchOH58D = {}

function ufcPatchOH58D.generateUFCData()

local MainPanel = GetDevice(0)
local UHFRadio = GetDevice(30)
local FMRadio1 = GetDevice(29)
local VHFRadio = GetDevice(31)
local FMRadio2 = GetDevice(32)

local PwrSwpos = MainPanel:get_argument_value(248) --OH58 Battery 1 switch 
local MasterArm = MainPanel:get_argument_value(171) 
local ICPRotarySwitch = MainPanel:get_argument_value(188)
local Switch13 = MainPanel:get_argument_value(14)
local Switch24 = MainPanel:get_argument_value(16)
local Switch5 = MainPanel:get_argument_value(17)

local ArmStatus = "S" 

	if PwrSwpos == 1 then

	FC3RadarAltitudeString = (ufcPatchUtils.GenaricRadarAltitudeFeet()-2) --Account for 2ft airframe offset 
	HeadingString = ufcPatchUtils.MagHeading()
	AirspeedString = ufcPatchUtils.AirspeedKnots()
	FuelString = ((ufcPatchUtils.TotalFuel()/100)*736) -- Conversion to lbs
	Vertical = ufcPatchUtils.VerticalV_FPMv2()
	FlareCount = ufcPatchUtils.flares()
	
	FM1Freq = FMRadio1:get_frequency()
	UHFFreq = UHFRadio:get_frequency()
	VHFFreq = VHFRadio:get_frequency()
	FM2Freq = FMRadio2:get_frequency()
	
		--Armament Status 
		if (MasterArm == 1) then 
			ArmStatus = "A" 
		elseif (MasterArm == 0) then 
			ArmStatus = "B"
		elseif (MasterArm == -1) then
			ArmStatus = "S" 
		end 	
		
	elseif PwrSwpos ~= 1 then 
	FC3RadarAltitudeString = ""
	HeadingString = ""
	AirspeedString = ""
	FuelString = ""
	Vertical = ""
	ArmStatus = ""
	RadioDisplay1 = ""
	RadioDisplay1 = ""
	RadioDisplay2 = ""	
	end 
	
--Radios
	--AN/ARC 201 FM1
	local FM1digits = { math.floor(FM1Freq / 1000) }

	local FM1String = ""
	for index, value in ipairs(FM1digits) do
		local FM1digitToAppend = value
		if value >= 88000 then
			FM1digitToAppend = 88000
		end
		FM1String = FM1String .. FM1digitToAppend
	end

	--AN/ARC 164 UHF
	local UHFdigits = { math.floor(UHFFreq / 1000) }

	local UHFString = ""
	for index, value in ipairs(UHFdigits) do
		local UHFdigitToAppend = value
		if value >= 399975 then
			UHFdigitToAppend = 399975
		end
		UHFString = UHFString .. UHFdigitToAppend
	end

	--AN/ARC 186 VHF
	local VHFdigits = { math.floor(VHFFreq / 1000) }

	local VHFString = ""
	for index, value in ipairs(VHFdigits) do
		local VHFdigitToAppend = value
		if value >= 152000 then
			VHFdigitToAppend = 152000
		end
		VHFString = VHFString .. VHFdigitToAppend
	end

	--AN/ARC 201 FM2
	local FM2digits = { math.floor(FM2Freq / 1000) }

	local FM2String = ""
	for index, value in ipairs(FM2digits) do
		local FM2digitToAppend = value
		if value >= 88000 then
			FM2digitToAppend = 88000
		end
		FM2String = FM2String .. FM2digitToAppend
	end
	
	--Remote Radio
	if Switch13 == 1 then --FM1 Remote
		RemoteRadioFreq = FM1String
	elseif Switch13 == -1 then --VHF Remote 
		RemoteRadioFreq = VHFString
	elseif Switch24 == 1 then --UHF Remote
		RemoteRadioFreq = UHFString
	elseif Switch24 == -1 then --Not Implimented 
		RemoteRadioFreq = "000000"
	elseif Switch5 == -1 then --FM2 Remote
		RemoteRadioFreq = FM2String
	elseif Switch13 == 0 and Switch24 == 0 and Switch5 == 0 then 
		RemoteRadioFreq = ""
	end
		
	--Pilot ICP
	local ICPdigits = { math.floor(ICPRotarySwitch * 10) }

	local ICPdisplay = ""
	for index, value in ipairs(ICPdigits) do
		local ICPdisplayToAppend = value
		if value >= 7 then
			ICPdisplayToAppend = 7
		end
		ICPdisplay = ICPdisplay .. ICPdisplayToAppend
		if value == 0 then
			RadioDisplay = "000000"
			RadioDisplay1 = "P"
			RadioDisplay2 = "V"
		elseif value == 1 then
			RadioDisplay = "000000"
			RadioDisplay1 = "I"
			RadioDisplay2 = "C"
		elseif value == 2 then
			RadioDisplay = FM1String
			RadioDisplay1 = "F"
			RadioDisplay2 = "1"
		elseif value == 3 then
			RadioDisplay = UHFString
			RadioDisplay1 = "U"
			RadioDisplay2 = "H"
		elseif value == 4 then
			RadioDisplay = VHFString 
			RadioDisplay1 = "V"
			RadioDisplay2 = "H"
		elseif value == 5 then
			RadioDisplay = "000000"
			RadioDisplay1 = "S"
			RadioDisplay2 = "A"
		elseif value == 6 then
			RadioDisplay = FM2String
			RadioDisplay1 = "F"
			RadioDisplay2 = "2"
		elseif value == 7 then
			RadioDisplay = RemoteRadioFreq 
			RadioDisplay1 = "R"
			RadioDisplay2 = "T"
		end
	end
	
	--Send info to UFC components 
    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=RadioDisplay, --Radio
        option1=FC3RadarAltitudeString,  
		option2=HeadingString, 
		option3=FuelString,  
		option4=AirspeedString,   
        option5=Vertical, --VSI
		com1=FlareCount, --Flare
		com2=ArmStatus, --Arm
		scratchPadString1=RadioDisplay1, --Radio Type
		scratchPadString2=RadioDisplay2  --Radio Type 
    })
end

return ufcPatchOH58D --v1.0 by ANDR0ID 

