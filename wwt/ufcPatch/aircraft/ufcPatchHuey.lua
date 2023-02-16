-- Credit to ANDR0ID on DCS Forums

local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchHuey = {}

function ufcPatchHuey.generateUFCData()

    -- Access the UH1 Main panel from DCS
    local MainPanel = GetDevice(0)

	local UHFRadio = GetDevice(22)
	local FMRadio1 = GetDevice(23)
	local VHFRadio = GetDevice(20)

	--Initial Data
	local PwrSwpos = MainPanel:get_argument_value(219)

	--Checks UH-1 power and starts data pull
	if PwrSwpos == 0 then --0 is Battery on for the Huey
	FM1Freq = FMRadio1:get_frequency()
	UHFFreq = UHFRadio:get_frequency()
	VHFFreq = VHFRadio:get_frequency()

	MasterArmLamp = MainPanel:get_argument_value(254)
	WepsSwitch = MainPanel:get_argument_value(256)
	MasterArm = MainPanel:get_argument_value(252)
	RocketInfo = MainPanel:get_argument_value(257)
	end

    -- Got these argument values from: <DCS_INSTALL>\Mods\aircraft\Uh-1H\Cockpit\Scripts\mainpanel_init.lua
    -- DCS get_argument_value returns floats for these values. Example: 7 = .069999999999901. We need to round to get the proper digit
    -- By adding .05 and flooring we get the proper digit shown on the altimeter.
    local digits = {
        math.floor((MainPanel:get_argument_value(468) + 0.05) * 10),
        math.floor((MainPanel:get_argument_value(469)+ 0.05) * 10),
        math.floor((MainPanel:get_argument_value(470)+ 0.05) * 10),
        math.floor((MainPanel:get_argument_value(471)+ 0.05) * 10)
    }

    -- Parse digits and build the radar alt string
    local radarAltitudeString = ""
    for index, value in ipairs(digits) do
        local digitToAppend = value
        if value >= 10 then
            digitToAppend = 0
        end
        radarAltitudeString = radarAltitudeString..digitToAppend
    end

	--Flare Count
	local flaredigit = {
        math.floor(MainPanel:get_argument_value(460) * 10),
		math.floor((MainPanel:get_argument_value(461)+0.05) * 10)
	}

	local flarecount = ""
    for index, value in ipairs(flaredigit) do
        local flaredigitToAppend = value
        if value >= 10 then
           flaredigitToAppend = 0
        end
        flarecount = flarecount..flaredigitToAppend
    end

	--Chaff Count
	local chaffdigit = {
        math.floor(MainPanel:get_argument_value(462) * 10),
		math.floor((MainPanel:get_argument_value(463)+0.05) * 10)
	}

	local chaffcount = ""
    for index, value in ipairs(chaffdigit) do
        local chaffdigitToAppend = value
        if value >= 10 then
            chaffdigitToAppend = 0
        end
        chaffcount = chaffcount..chaffdigitToAppend
    end

	--Heading
    local Headingdigits = {math.floor(MainPanel:get_argument_value(165) * 360)} --May need refinement/rounding... sometimes 1-2 degrees off

	local HeadingString = ""
    for index, value in ipairs(Headingdigits) do
        local HeadingdigitToAppend = value
        if value >= 360 then
            HeadingdigitToAppend = 0
        end
        HeadingString = tostring(value)
		if value < 10 then
			HeadingString = "00"..value.."M"
		elseif value >= 100 then
			HeadingString = ""..value.."M"
		elseif value >= 10 then
			HeadingString = "0"..value.."M"
		end
    end

	--Fuel (Internal)
	local Fueldigits = {math.floor(MainPanel:get_argument_value(239) * 1580)}

    local FuelString = ""
    for index, value in ipairs(Fueldigits) do
        local FueldigitToAppend = value
        if value >= 1581 then
            FueldigitToAppend = 1580
        end
        FuelString = FuelString..FueldigitToAppend
    end
--Radios
	--FM1
	local FM1digits = {math.floor(FM1Freq / 10000)}

    local FM1String = ""
    for index, value in ipairs(FM1digits) do
        local FM1digitToAppend = value
        if value >= 7595 then
            FM1digitToAppend = 7595
        end
        FM1String = FM1String..FM1digitToAppend
    end

	--UHF
	local UHFdigits = {math.floor(UHFFreq / 10000)}

    local UHFString = ""
    for index, value in ipairs(UHFdigits) do
        local UHFdigitToAppend = value
        if value >= 39995 then
            UHFdigitToAppend = 39995
        end
        UHFString = UHFString..UHFdigitToAppend
    end

	--VHF
	local VHFdigits = {math.floor(VHFFreq / 1000)}

    local VHFString = ""
    for index, value in ipairs(VHFdigits) do
        local VHFdigitToAppend = value
        if value >= 600000 then
            VHFdigitToAppend = 600000
        end
        VHFString = VHFString..VHFdigitToAppend
    end

	--Pilot ICP
	local ICPdigits = {math.floor((MainPanel:get_argument_value(30)+0.05) * 10)}

	local ICPdisplay = ""
    for index, value in ipairs(ICPdigits) do
        local ICPdisplayToAppend = value
        if value >= 10 then
            ICPdisplayToAppend = 0
        end
        ICPdisplay = ICPdisplay..ICPdisplayToAppend
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
	elseif (RocketPairSwitch > 0.0 and RocketPairSwitch <= 0.15)  then
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

    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=RadioDisplay, --Freq of Slectected Radio
        option1=radarAltitudeString, --Altitiude
		option2=HeadingString, --Heading
		option3=FuelString, --Total Fuel (Internal)
		option4="UH1H",
        option5=WepsDisplay, --UH-1 Weapon Selector
		com1=flarecount, --Flare Count
		com2=chaffcount, --Chaff Count
		scratchPadString1=RadioDisplay1, --RadioType1
		scratchPadString2=RadioDisplay2	 --RadioType2
    })
end


return ufcPatchHuey