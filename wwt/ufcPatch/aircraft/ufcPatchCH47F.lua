local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")
local lightsHelper = require("ufcPatch\\utilities\\wwLights")

ufcPatchCH47F = {}

--CH-47 Light Program (To be updated)
function ufcPatchCH47F.generateLightData()
	local MainPanel = GetDevice(0)

	return {
		[lightsHelper.LANDING_GEAR_HANDLE] = 0,
		[lightsHelper.AA] = 0,
		[lightsHelper.AG] = 0,
		[lightsHelper.APU_READY] = 0,
		[lightsHelper.JETTISON_CTR] = 0,
		[lightsHelper.JETTISON_LI] = 0,
		[lightsHelper.JETTISON_LO] = 0,
		[lightsHelper.JETTISON_RI] = 0,
		[lightsHelper.JETTISON_RO] = 0,
		[lightsHelper.ALR_POWER] = 0,
	}
end

function ufcPatchCH47F.generateUFCData()


local MainPanel = GetDevice(0)
local PwrSwpos = MainPanel:get_argument_value(559) --CH47 Battery switch 
--local ICPRotarySwitch = MainPanel:get_argument_value(613) --613 is Pilot ICP --Now using utility function
local UHFRadio = GetDevice(47) --ARC-164 UHF
local FMRadio1 = GetDevice(49) --ARC-201 FM1
local VHFRadio = GetDevice(48) --ARC-186 VHF
--local FMRadio2 = GetDevice(32)--ARC-201 FM2 --*Update When Second Radio Implimented* 
local HFRadio = GetDevice(50) --ARC-220 HF

	if PwrSwpos == 1 then

	FC3RadarAltitudeString = (ufcPatchUtils.GenaricRadarAltitudeFeet()-7) --Account for 7ft airframe offset 
	HeadingString = ufcPatchUtils.MagHeading()
	AirspeedString = ufcPatchUtils.AirspeedKnots()
	FuelString = ((ufcPatchUtils.TotalFuel()/100)*6734) -- Conversion to lbs
	Vertical = ufcPatchUtils.VerticalV_FPMv2()
	FlareCount = ufcPatchUtils.flares()
	ChaffCount = ufcPatchUtils.chaff()
	ICPRotarySwitch = ufcPatchUtils.SwtichPosition(613, 20) 
	
	FM1Freq = FMRadio1:get_frequency()
	UHFFreq = UHFRadio:get_frequency()
	VHFFreq = VHFRadio:get_frequency()
	--FM2Freq = FMRadio2:get_frequency() --*Update When Second Radio Implimented* 
	HFFreq = HFRadio:get_frequency()
	
	elseif PwrSwpos ~= 1 then 
	FC3RadarAltitudeString = ""
	HeadingString = ""
	AirspeedString = ""
	FuelString = ""
	Vertical = ""
	FlareCount = ""
	ChaffCount = ""
	RadioDisplay = ""
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
	
	--AN/ARC 220 HF
	local HFdigits = { math.floor(HFFreq / 1000) }

	local HFString = ""
	for index, value in ipairs(HFdigits) do
		local HFdigitToAppend = value
		if value >= 30000 then
			HFdigitToAppend = 30000
		end
		HFString = HFString .. HFdigitToAppend
	end
 
	--Pilot ICP
	local ICPdigits = {(ICPRotarySwitch * 1)}

	local ICPdisplay = ""
	for index, value in ipairs(ICPdigits) do
		local ICPdisplayToAppend = value
		if value >= 10 then
			ICPdisplayToAppend = 10
		end
		ICPdisplay = ICPdisplay .. ICPdisplayToAppend
		if value == 0 then
			RadioDisplay = "000000"
			RadioDisplay1 = "I"
			RadioDisplay2 = "C"
		elseif value == 1 then
			RadioDisplay = FM1String
			RadioDisplay1 = "F"
			RadioDisplay2 = "1"
		elseif value == 2 then
			RadioDisplay = UHFString
			RadioDisplay1 = "U"
			RadioDisplay2 = "H"
		elseif value == 3 then
			RadioDisplay = VHFString
			RadioDisplay1 = "V"
			RadioDisplay2 = "H"
		elseif value == 4 then
			RadioDisplay = HFString
			RadioDisplay1 = "H"
			RadioDisplay2 = "F"
		elseif value == 5 then
			RadioDisplay = "05"--FM2String
			RadioDisplay1 = "F"
			RadioDisplay2 = "2"
		elseif value == 6 then
			RadioDisplay = "06"
			RadioDisplay1 = ""
			RadioDisplay2 = ""
		elseif value == 7 then --Needs Update?
			RadioDisplay = "07"
			RadioDisplay1 = ""
			RadioDisplay2 = ""
		elseif value == 8 then
			RadioDisplay = "08"--RemoteRadioFreq 
			RadioDisplay1 = "R"
			RadioDisplay2 = "T"
		elseif value == 9 then --Needs Update?
			RadioDisplay = "09"
			RadioDisplay1 = "B"
			RadioDisplay2 = "U"
		elseif value == 10 then
			RadioDisplay = "000000"
			RadioDisplay1 = "P"
			RadioDisplay2 = "V"		
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
		com2=ChaffCount, --Chaff
		scratchPadString1=RadioDisplay1, --Radio Type
		scratchPadString2=RadioDisplay2  --Radio Type 
    })
end

return ufcPatchCH47F --v1.1 by ANDR0ID 16MAR25 

