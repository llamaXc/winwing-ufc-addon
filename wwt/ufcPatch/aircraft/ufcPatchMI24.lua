-- Credit to ANDR0ID on DCS Forums

local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchMI24 = {}

function ufcPatchMI24.generateUFCData()
	-- Access the Mi-24 Main panel & other devices from DCS
	local MainPanel = GetDevice(0)

	local FMRadio1 = GetDevice(49) --R-863 UHF
	local VHFRadio = GetDevice(51) --R-828 VHF
	local FMRadio2 = GetDevice(52) --R-852
	local HFRadio = GetDevice(50) --YaDRO-1A HF

	local PwrSwpos = MainPanel:get_argument_value(75) --Mi-24 Left Battery switch
	local MasterArm = MainPanel:get_argument_value(673) --Mi-24 Weapon Master Power Switch  551
	local WepsSwitch = MainPanel:get_argument_value(523) --Mi-24 Weapon Selector
	local ICSSwtich = MainPanel:get_argument_value(456) --Mi24 ICS Switch

	if PwrSwpos == 1 then
		VHFFreq = VHFRadio:get_frequency() --R-828 VHF
		FM1Freq = FMRadio1:get_frequency() --R-863 UHF
		HFFreq = HFRadio:get_frequency() --YaDRO-1A HF
		FM2Freq = FMRadio2:get_frequency() --R-852
	end

	-- Got these argument values from: mainpanel_init.lua
	--Mi-24 Radar Alt
	local digits = { math.abs(MainPanel:get_argument_value(32)) }

	-- Parse digits and build the radar alt string
	local radarAltitudeString = ""
	for index, value in ipairs(digits) do
		local digitToAppend = value
		if value >= 1 then
			digitToAppend = 1
		end
		radarAltitudeString = tostring(value)
		if value < 0.01125 then
			radarAltitudeString = "000" .. ((value * 210.5) - 2) -- Subtracting two gets us a zero value on flat ground
		elseif (value >= 0.01125 and value < 0.475) then
			radarAltitudeString = "00" .. (value * 210.5)
		elseif (value >= 0.475 and value < 0.625) then
			radarAltitudeString = "0" .. (value * 210.5)
		elseif (value >= 0.625 and value <= 1) then
			radarAltitudeString = "" .. (value * 210.5)
		end
	end

	--Mi-24 Baro Alt
	local barodigits100 = { math.floor(MainPanel:get_argument_value(19) * 10000) }

	local baroradarAltitudeString100 = ""
	for index, value in ipairs(barodigits100) do
		local barodigit100ToAppend = value
		if value >= 9999 then
			barodigit100ToAppend = 0
		end
		baroradarAltitudeString100 = tostring(barodigit100ToAppend)
		if barodigit100ToAppend < 10 then
			baroradarAltitudeString100 = "000" .. barodigit100ToAppend
		elseif barodigit100ToAppend >= 1000 then
			baroradarAltitudeString100 = "" .. barodigit100ToAppend
		elseif (barodigit100ToAppend >= 100 and barodigit100ToAppend <= 999) then
			baroradarAltitudeString100 = "0" .. barodigit100ToAppend
		elseif (barodigit100ToAppend >= 10 and barodigit100ToAppend <= 99) then
			baroradarAltitudeString100 = "00" .. barodigit100ToAppend
		end
	end

	--Heading
	local Headingdigits = { math.floor(360 - ((MainPanel:get_argument_value(25) + 0.0004) * 360)) } --MI24 is coded "backwards" & need to round, this is close but not perfect, may need refinement (1-2 degrees off)
	--0.01 (.004) bigger value is smaller

	local HeadingString = ""
	for index, value in ipairs(Headingdigits) do
		local HeadingdigitToAppend = value
		if value >= 360 then
			HeadingdigitToAppend = 0
		end
		HeadingString = tostring(value)
		if value < 10 then
			HeadingString = "00" ..
				value ..
				"T" --Using T for true to align with game values from the MI-24 Heading Indicator, even though it should probably be magnetic
		elseif value >= 100 then
			HeadingString = "" .. value .. "T"
		elseif value >= 10 then
			HeadingString = "0" .. value .. "T"
		end
	end

	--Airspeed
	local Airspeeddigits = { math.floor(MainPanel:get_argument_value(790) * 100) }

	local AirspeedString = ""
	for index, value in ipairs(Airspeeddigits) do
		local AirspeeddigitToAppend = value
		if value >= 400 then
			AirspeeddigitToAppend = 400
		end
		AirspeedString = AirspeedString .. AirspeeddigitToAppend
	end

	--Fuel (Internal)
	local Fueldigits = { math.floor(MainPanel:get_argument_value(525) * 2055) } --Non-linear, needs further investigation

	local FuelString = ""
	for index, value in ipairs(Fueldigits) do
		local FueldigitToAppend = value
		if value >= 2801 then
			FueldigitToAppend = 2800
		end
		FuelString = FuelString .. FueldigitToAppend
	end

	--Radios
	--R-863 UHF
	local FM1digits = { math.floor(FM1Freq / 1000) }

	local FM1String = ""
	for index, value in ipairs(FM1digits) do
		local FM1digitToAppend = value
		if value >= 4000000 then
			FM1digitToAppend = 4000000
		end
		FM1String = FM1String .. FM1digitToAppend
	end

	--YaDRO-1A HF
	local HFdigits = { math.floor(HFFreq / 100) }

	local HFString = ""
	for index, value in ipairs(HFdigits) do
		local HFdigitToAppend = value
		if value >= 180000 then
			HFdigitToAppend = 180000
		end
		HFString = HFString .. HFdigitToAppend
	end

	--R-828 VHF
	local VHFdigits = { math.floor(VHFFreq / 1000) }

	local VHFString = ""
	for index, value in ipairs(VHFdigits) do
		local VHFdigitToAppend = value
		if value >= 600000 then
			VHFdigitToAppend = 600000
		end
		VHFString = VHFString .. VHFdigitToAppend
	end

	--ARK U2 Channel
	--[[local ARKU2Dialdigits = MainPanel:get_argument_value(327)

	if ARKU2Dialdigits == 1 then
		ARKU2DialDisplay = "828COMP"
	elseif ARKU2Dialdigits == 0 then
		ARKU2DialDisplay = "COMM"
	elseif ARKU2Dialdigits == -1 then
		ARKU2DialDisplay = "852COMP"
	end ]]
	local FM2digits = { math.floor(FM2Freq / 1000) }

	local FM2String = ""
	for index, value in ipairs(FM2digits) do
		local FM2digitToAppend = value
		if value >= 4000000 then
			FM2digitToAppend = 4000000
		end
		FM2String = FM2String .. FM2digitToAppend
	end

	--ARK 15 462
	local ARK15BDialdigits = {
		math.floor((MainPanel:get_argument_value(467) * 17.4) + 0), --Add since 0 is Channel 1, number for multiplation due to Arg rounding requirements
		math.floor(((MainPanel:get_argument_value(468) + 0.05) * 9)), --Need to round for Arg value (see huey file for more info)
		math.floor(((MainPanel:get_argument_value(469) + 0.05) * 10)) --Not Perfect as the radio can do half KHz values, but probably good enough
	}

	local ARK15BDialDisplay = ""
	for index, value in ipairs(ARK15BDialdigits) do
		local ARK15BDialDisplayToAppend = value
		if value >= 600 then
			ARK15BDialDisplayToAppend = 600
		end
		ARK15BDialDisplay = ARK15BDialDisplay .. ARK15BDialDisplayToAppend --ARK-15 Backup
	end

	local ARK15PDialdigits = {
		math.floor((MainPanel:get_argument_value(464) * 17.4) + 0), --Add since 0 is Channel 1, number for multiplation due to Arg rounding requirements
		math.floor(((MainPanel:get_argument_value(465) + 0.05) * 9)), --Need to round for Arg value (see huey file for more info)
		math.floor(((MainPanel:get_argument_value(466) + 0) * 10)) --Not Perfect as the radio can do half KHz values, but probably good enough
	}

	local ARK15PDialDisplay = ""
	for index, value in ipairs(ARK15PDialdigits) do
		local ARK15PDialDisplayToAppend = value
		if value >= 600 then
			ARK15PDialDisplayToAppend = 600
		end
		ARK15PDialDisplay = ARK15PDialDisplay .. ARK15PDialDisplayToAppend --ARK-15 Primary
	end

	local ARK15Swtich = MainPanel:get_argument_value(462)

	if ARK15Swtich == 1 then
		ARK15DialDisplay = ARK15BDialDisplay
	elseif ARK15Swtich == 0 then
		ARK15DialDisplay = ARK15PDialDisplay
	end

	--SPU-8
	local ICPdigits = { math.floor(MainPanel:get_argument_value(455) * 5) }

	local ICPdisplay = ""
	for index, value in ipairs(ICPdigits) do
		local ICPdisplayToAppend = value
		if value >= 10 then
			ICPdisplayToAppend = 0
		end
		ICPdisplay = ICPdisplay .. ICPdisplayToAppend
		if ICSSwtich == 1 then
			RadioDisplay = "0000"
			RadioDisplay1 = "I"
			RadioDisplay2 = "C"
		elseif value == 0 then --863
			RadioDisplay = FM1String
			RadioDisplay1 = "6"
			RadioDisplay2 = "3"
		elseif value == 1 then
			RadioDisplay = "0000" --Not Implimented in Game
			RadioDisplay1 = "V"
			RadioDisplay2 = "K"
		elseif value == 2 then --828
			RadioDisplay = VHFString
			RadioDisplay1 = "2"
			RadioDisplay2 = "8"
		elseif value == 3 then
			RadioDisplay = HFString
			RadioDisplay1 = "H"
			RadioDisplay2 = "F"
		elseif value == 4 then
			RadioDisplay = ARK15DialDisplay
			RadioDisplay1 = "1"
			RadioDisplay2 = "5"
		elseif value == 5 then
			RadioDisplay = FM2String
			RadioDisplay1 = "U"
			RadioDisplay2 = "2"
		end
	end

	--Radio Channel R-863, Radio Channel Selector Knob
	local R863Dialdigits = { math.floor(((MainPanel:get_argument_value(513) + 0.025) * 20) + 0) } --Need to round Arg value (see huey file for more info)

	local LeftDialDisplay = ""
	for index, value in ipairs(R863Dialdigits) do
		local LeftDialDisplayToAppend = value
		if value >= 21 then
			LeftDialDisplayToAppend = 1
		end
		LeftDialDisplay = LeftDialDisplay .. LeftDialDisplayToAppend
	end

	--R-828, Radio Channel Selector Knob
	local R828Dialdigits = { math.floor(((MainPanel:get_argument_value(337) + 0.05) * 10) + 0) } --Need to round Arg value (see huey file for more info)

	local RightDialDisplay = ""
	for index, value in ipairs(R828Dialdigits) do
		local RightDialDisplayToAppend = value
		if value >= 11 then
			RightDialDisplayToAppend = 1
		end
		RightDialDisplay = RightDialDisplay .. RightDialDisplayToAppend
	end

	--Weapons

	if MasterArm ~= 1 then
		WepsDisplay = "SAFE"
	elseif WepsSwitch == 0 then
		WepsDisplay = "MSL"
	elseif (WepsSwitch > 0 and WepsSwitch <= 0.15) then
		WepsDisplay = "GM30"
	elseif (WepsSwitch > 0.15 and WepsSwitch <= 0.21) then
		WepsDisplay = "GUNS"
	elseif (WepsSwitch > 0.21 and WepsSwitch <= 0.32) then
		WepsDisplay = "12-7"
	elseif (WepsSwitch > 0.32 and WepsSwitch <= 0.49) then
		WepsDisplay = "7-62"
	elseif WepsSwitch == 0.5 then
		WepsDisplay = "30MM"
	elseif (WepsSwitch > 0.5 and WepsSwitch <= 0.64) then
		WepsDisplay = "RKTS"
	elseif (WepsSwitch > 0.64 and WepsSwitch <= 0.7) then
		WepsDisplay = "BOMB"
	elseif WepsSwitch > 0.7 then
		WepsDisplay = "USLP"
	end

	return ufcUtils.buildSimAppProUFCPayload({
		scratchPadNumbers = RadioDisplay, --Freq of Slectected Radio
		option1 = baroradarAltitudeString100, --radarAltitudeString, --Altitiude
		option2 = HeadingString,
		option3 = "", --FuelString, --Commented Out pending investigation of possible non-linear nature of fuel gage
		option4 = "MI24", --AirspeedString,
		option5 = WepsDisplay,
		com1 = LeftDialDisplay,
		com2 = RightDialDisplay,
		scratchPadString1 = RadioDisplay1, --RadioType1
		scratchPadString2 = RadioDisplay2 --RadioType2
	})
end

return ufcPatchMI24 --v1.0 by ANDR0ID
