-- Credit to ANDR0ID on DCS Forums
local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")
local lightsHelper = require("ufcPatch\\utilities\\wwLights")

ufcPatchHuey = {}

-- To add this ability to another module, add this function into the class 
-- and implement the lights to be powered by DCS module update_arguments
function ufcPatchHuey.generateLightData()
	local MainPanel = GetDevice(0)

	local masterArmLight = MainPanel:get_argument_value(254)
	local agLightState = masterArmLight

	local starterGenSwitch = MainPanel:get_argument_value(220)
	local apuLightState = starterGenSwitch

	local MasterCautLight = MainPanel:get_argument_value(277)

	local heightAboveGround = LoGetAltitudeAboveGroundLevel()
	local landingGearLightState = 0
	if heightAboveGround <= 1.7 then
		landingGearLightState = 1
	end

	return {
		[lightsHelper.LANDING_GEAR_HANDLE] = 0,
		[lightsHelper.HOOK] = 0,
		[lightsHelper.GEAR_NOSE] = landingGearLightState,
		[lightsHelper.GEAR_LEFT] = landingGearLightState,
		[lightsHelper.GEAR_RIGHT] = landingGearLightState,
		[lightsHelper.FLAP_HALF] = 0,
		[lightsHelper.FLAP_FULL] = 0,
		[lightsHelper.FLAPS] = 0,
		[lightsHelper.AA] = 0,
		[lightsHelper.AG] = agLightState,
		[lightsHelper.APU_READY] = apuLightState,
		[lightsHelper.MASTER_CAUTION] = MasterCautLight,
		[lightsHelper.JETTISON_CTR] = 0,
		[lightsHelper.JETTISON_LI] = 0,
		[lightsHelper.JETTISON_LO] = 0,
		[lightsHelper.JETTISON_RI] = 0,
		[lightsHelper.JETTISON_RO] = 0
	}
end


function ufcPatchHuey.generateUFCData()
	-- Access the UH1 Main panel from DCS
	local MainPanel = GetDevice(0)

	local UHFRadio = GetDevice(22)
	local FMRadio1 = GetDevice(23)
	local VHFRadio = GetDevice(20)

	--Initial Data
	local PwrSwpos = MainPanel:get_argument_value(219)

	-- Define safe defaults so the script doesn't crash when the battery is OFF
	local FM1Freq = 0
	local UHFFreq = 0
	local VHFFreq = 0
	local MasterArmLamp = 0
	local WepsSwitch = 0
	local MasterArm = 0
	local RocketInfo = 0

	-- Pre-declare display strings to avoid nil crashes
	local RadioDisplay = "000000"
	local RadioDisplay1 = " "
	local RadioDisplay2 = " "

	--Checks UH-1 power and starts data pull
	if PwrSwpos == 0 then --0 is Battery on for the Huey
		if FMRadio1 then FM1Freq = FMRadio1:get_frequency() or 0 end
		if UHFRadio then UHFFreq = UHFRadio:get_frequency() or 0 end
		if VHFRadio then VHFFreq = VHFRadio:get_frequency() or 0 end

		MasterArmLamp = MainPanel:get_argument_value(254) or 0
		WepsSwitch = MainPanel:get_argument_value(256) or 0
		MasterArm = MainPanel:get_argument_value(252) or 0
		RocketInfo = MainPanel:get_argument_value(257) or 0
	end

	-- Got these argument values from: <DCS_INSTALL>\Mods\aircraft\Uh-1H\Cockpit\Scripts\mainpanel_init.lua
	-- DCS get_argument_value returns floats for these values. Example: 7 = .069999999999901. We need to round to get the proper digit
	-- By adding .05 and flooring we get the proper digit shown on the altimeter.
	local digits = {
		math.floor((MainPanel:get_argument_value(468) + 0.05) * 10),
		math.floor((MainPanel:get_argument_value(469) + 0.05) * 10),
		math.floor((MainPanel:get_argument_value(470) + 0.05) * 10),
		math.floor((MainPanel:get_argument_value(471) + 0.05) * 10)
	}

	-- Parse digits and build the radar alt string
	local radarAltitudeString = ""
	for index, value in ipairs(digits) do
		local digitToAppend = value
		if value >= 10 then
			digitToAppend = 0
		end
		radarAltitudeString = radarAltitudeString .. digitToAppend
	end

	--Flare Count
	local flaredigit = {
		math.floor(MainPanel:get_argument_value(460) * 10),
		math.floor((MainPanel:get_argument_value(461) + 0.05) * 10)
	}

	local flarecount = ""
	for index, value in ipairs(flaredigit) do
		local flaredigitToAppend = value
		if value >= 10 then
			flaredigitToAppend = 0
		end
		flarecount = flarecount .. flaredigitToAppend
	end

	--Chaff Count
	local chaffdigit = {
		math.floor(MainPanel:get_argument_value(462) * 10),
		math.floor((MainPanel:get_argument_value(463) + 0.05) * 10)
	}

	local chaffcount = ""
	for index, value in ipairs(chaffdigit) do
		local chaffdigitToAppend = value
		if value >= 10 then
			chaffdigitToAppend = 0
		end
		chaffcount = chaffcount .. chaffdigitToAppend
	end

	--Heading
	local Headingdigits = { math.floor(MainPanel:get_argument_value(165) * 360) } --May need refinement/rounding... sometimes 1-2 degrees off

	local HeadingString = ""
	for index, value in ipairs(Headingdigits) do
		local HeadingdigitToAppend = value
		if value >= 360 then
			HeadingdigitToAppend = 0
		end
		HeadingString = tostring(value)
		if value < 10 then
			HeadingString = "00" .. value .. "M"
		elseif value >= 100 then
			HeadingString = "" .. value .. "M"
		elseif value >= 10 then
			HeadingString = "0" .. value .. "M"
		end
	end

	--Fuel (Internal)
	local Fueldigits = { math.floor(MainPanel:get_argument_value(239) * 1580) }

	local FuelString = ""
	for index, value in ipairs(Fueldigits) do
		local FueldigitToAppend = value
		if value >= 1581 then
			FueldigitToAppend = 1580
		end
		FuelString = FuelString .. FueldigitToAppend
	end
	--Radios
	--FM1
	local FM1digits = { math.floor(FM1Freq / 10000) }

	local FM1String = ""
	for index, value in ipairs(FM1digits) do
		local FM1digitToAppend = value
		if value >= 7595 then
			FM1digitToAppend = 7595
		end
		FM1String = FM1String .. FM1digitToAppend
	end

	--UHF
	local UHFdigits = { math.floor(UHFFreq / 10000) }

	local UHFString = ""
	for index, value in ipairs(UHFdigits) do
		local UHFdigitToAppend = value
		if value >= 39995 then
			UHFdigitToAppend = 39995
		end
		UHFString = UHFString .. UHFdigitToAppend
	end

	--VHF
	local VHFdigits = { math.floor(VHFFreq / 1000) }

	local VHFString = ""
	for index, value in ipairs(VHFdigits) do
		local VHFdigitToAppend = value
		if value >= 600000 then
			VHFdigitToAppend = 600000
		end
		VHFString = VHFString .. VHFdigitToAppend
	end

	--Pilot ICP
	local ICPdigits = { math.floor((MainPanel:get_argument_value(30) + 0.05) * 10) }

	local ICPdisplay = ""
	for index, value in ipairs(ICPdigits) do
		local ICPdisplayToAppend = value
		if value >= 10 then
			ICPdisplayToAppend = 0
		end
		ICPdisplay = ICPdisplay .. ICPdisplayToAppend
		if value == 0 then
			RadioDisplay = "000000"
			RadioDisplay1 = "P"
			RadioDisplay2 = "V"
		elseif value == 1 then
			RadioDisplay = "0000"
			RadioDisplay1 = "I"
			RadioDisplay2 = "P"
		elseif value == 2 then
			RadioDisplay = FM1String
			RadioDisplay1 = "F"
			RadioDisplay2 = "M"
		elseif value == 3 then
			RadioDisplay = UHFString
			RadioDisplay1 = "U"
			RadioDisplay2 = "H"
		elseif value == 4 then
			RadioDisplay = VHFString
			RadioDisplay1 = "V"
			RadioDisplay2 = "H"
		elseif value == 5 then
			RadioDisplay = "0000"
			RadioDisplay1 = "N"
			RadioDisplay2 = "A"
		end
	end

	--Weapons
	local RocketPairSwitch = RocketInfo

	if RocketPairSwitch == 0 then
		RocketNum = "RKT0"
	elseif (RocketPairSwitch > 0.0 and RocketPairSwitch <= 0.15) then
		RocketNum = "RKT1"
	elseif (RocketPairSwitch > 0.15 and RocketPairSwitch <= 0.21) then
		RocketNum = "RKT2"
	elseif (RocketPairSwitch > 0.21 and RocketPairSwitch <= 0.32) then
		RocketNum = "RKT3"
	elseif (RocketPairSwitch > 0.32 and RocketPairSwitch <= 0.44) then
		RocketNum = "RKT4"
	elseif (RocketPairSwitch > 0.44 and RocketPairSwitch <= 0.55) then
		RocketNum = "RKT5"
	elseif (RocketPairSwitch > 0.55 and RocketPairSwitch <= 0.64) then
		RocketNum = "RKT6"
	elseif RocketPairSwitch > 0.64 then
		RocketNum = "RKT7"
	end

	if MasterArmLamp == 0 then
		WepsDisplay = "SAFE"
	elseif WepsSwitch == 1 then
		WepsDisplay = "40MM"
	elseif WepsSwitch == 0 then
		WepsDisplay = RocketNum
	elseif WepsSwitch == -1 then
		WepsDisplay = "7-62"
	end


	local torqueValue = math.floor(MainPanel:get_argument_value(124) * 100) .. "%"

	return ufcUtils.buildSimAppProUFCPayload({
		scratchPadNumbers = RadioDisplay, --Freq of Slectected Radio
		option1 = radarAltitudeString, --Altitiude
		option2 = HeadingString, --Heading
		option3 = FuelString, --Total Fuel (Internal)
		option4 = torqueValue, -- Torque PSI (0-100) as Percent
		option5 = WepsDisplay, --UH-1 Weapon Selector
		com1 = flarecount, --Flare Count
		com2 = chaffcount, --Chaff Count
		scratchPadString1 = RadioDisplay1, --RadioType1
		scratchPadString2 = RadioDisplay2 --RadioType2
	})
end

return ufcPatchHuey
