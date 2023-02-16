-- Credit to ANDR0ID on DCS Forums

local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchMI8 = {}

function ufcPatchMI8.generateUFCData()

    -- Access the Mi-8 Main panel & other devices from DCS
    local MainPanel = GetDevice(0)

	local UHFRadio = GetDevice(41)  --ARK-UD
	local FMRadio1 = GetDevice(38) --R-863 UHF
	local VHFRadio = GetDevice(39) 	--R-828 VHF
	local FMRadio2 = GetDevice(40) --ARK-9 ADF
	local HFRadio = GetDevice(37) --YaDRO-1A HF

	local PwrSwpos = MainPanel:get_argument_value(495) --Mi-8 Battery 1 switch
	local MasterArm = MainPanel:get_argument_value(921) --Mi-8 Master Arm switch
	local WepsSwitch = MainPanel:get_argument_value(344) --Mi-8 UPK.PKT/RS Switch
	local ICSSwitch = MainPanel:get_argument_value(553) --Mi-8 SPU-7ICS Switch
	local ARK9Switch = MainPanel:get_argument_value(469) --Mi-8 ARK-9 Pri/Backup Switch
	local RocketPairsSwitch = MainPanel:get_argument_value(342) --Mi-8 8/16/4 Switch

	if PwrSwpos == 1 then
	VHFFreq = VHFRadio:get_frequency() --R-828 VHF
	FM1Freq = FMRadio1:get_frequency() --R-863 UHF
	HFFreq = HFRadio:get_frequency() --YaDRO-1A HF
	end

    -- Got these argument values from: mainpanel_init.lua
	--Mi-8 Radar Alt
    local digits = {math.abs(MainPanel:get_argument_value(34))}  --Non-linear output, needs more work

    -- Parse digits and build the radar alt string
    local radarAltitudeString = ""
    for index, value in ipairs(digits) do
        local digitToAppend = value
        if value >= 1 then
            digitToAppend = 1
        end
		radarAltitudeString = tostring(value)
		if value <0.01125 then
		radarAltitudeString = "000"..((value*210.5)-2) -- Subtracting two gets us a zero value on flat ground
		elseif (value >= 0.01125 and value < 0.475) then
        radarAltitudeString = "00"..(value*210.5)
		elseif (value >= 0.475 and value < 0.625) then
		radarAltitudeString = "0"..(value*210.5)
		elseif (value >= 0.625 and value <= 1) then
		radarAltitudeString = ""..(value*210.5)
		end
    end

	--Mi-8 Baro Alt
	local barodigits100 = {
        math.floor(MainPanel:get_argument_value(19) * 10000)
    }

    local baroradarAltitudeString100 = ""
    for index, value in ipairs(barodigits100) do
        local barodigit100ToAppend = value
        if value >= 9999 then
            barodigit100ToAppend = 0
        end
        baroradarAltitudeString100 = tostring(value)
		if value < 10 then
		baroradarAltitudeString100 = "000"..value
		elseif value >= 1000 then
		baroradarAltitudeString100 = ""..value
		elseif (value >= 100 and value <= 999) then
		baroradarAltitudeString100 = "0"..value
		elseif (value >= 10 and value <= 99) then
		baroradarAltitudeString100 = "00"..value
		end
    end

	--Heading
    local Headingdigits = {math.floor(MainPanel:get_argument_value(25) * 360)}

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

	--Airspeed
	local Airspeeddigits = {math.floor(MainPanel:get_argument_value(24) * 10)}

    local AirspeedString = ""
    for index, value in ipairs(Airspeeddigits) do
        local AirspeeddigitToAppend = value
        if value >= 400 then
            AirspeeddigitToAppend = 400
        end
        AirspeedString = AirspeedString..AirspeeddigitToAppend
    end

	--Fuel (Internal)
	local Fueldigits = {math.floor(MainPanel:get_argument_value(62) * 2800)} --Non-linear output, needs more work

    local FuelString = ""
    for index, value in ipairs(Fueldigits) do
        local FueldigitToAppend = value
        if value >= 2801 then
            FueldigitToAppend = 2800
        end
        FuelString = FuelString..FueldigitToAppend
    end

--Radios
	--R-863 UHF
	local FM1digits = {math.floor(FM1Freq / 1000)}

    local FM1String = ""
    for index, value in ipairs(FM1digits) do
        local FM1digitToAppend = value
        if value >= 4000000 then
            FM1digitToAppend = 4000000
        end
        FM1String = FM1String..FM1digitToAppend
    end

	--YaDRO-1A HF
	local HFdigits = {math.floor(HFFreq / 100)}

    local HFString = ""
    for index, value in ipairs(HFdigits) do
        local HFdigitToAppend = value
        if value >= 180000 then
            HFdigitToAppend = 180000
        end
        HFString = HFString..HFdigitToAppend
    end

	--R-828 VHF
	local VHFdigits = {math.floor(VHFFreq / 1000)}

    local VHFString = ""
    for index, value in ipairs(VHFdigits) do
        local VHFdigitToAppend = value
        if value >= 600000 then
            VHFdigitToAppend = 600000
        end
        VHFString = VHFString..VHFdigitToAppend
    end

	--ARK UD Channel
	local ARKUDDialdigits = {math.floor(((MainPanel:get_argument_value(457)+0.075) * 10)+1)} --Add since 0 is Channel 1, also need to round Arg value (see huey file for more info)

	local ARKUDDialDisplay = ""
    for index, value in ipairs(ARKUDDialdigits) do
        local ARKUDDialDisplayToAppend = value
        if value >= 11 then
            ARKUDDialDisplayToAppend = 1
        end
        ARKUDDialDisplay = ARKUDDialDisplay..ARKUDDialDisplayToAppend
	end

	--ARK 9
	local ARK9BDialdigits = {math.floor((MainPanel:get_argument_value(675) * 21)+1), --Add since 0 is Channel 1, number for multiplation due to Arg rounding requirements
						   math.floor(((MainPanel:get_argument_value(450)+0.05) * 10)), --Need to round for Arg value (see huey file for more info)
						   math.floor(((MainPanel:get_argument_value(449)+0.0)* 52)) --Get wierd display if negative tuning or over 9
							}

	local ARK9BDialDisplay = ""
    for index, value in ipairs(ARK9BDialdigits) do
        local ARK9BDialDisplayToAppend = value
        if value >= 600 then
            ARK9BDialDisplayToAppend = 600
        end
        ARK9BDialDisplay = ARK9BDialDisplay..ARK9BDialDisplayToAppend --ARK-9 Backup
	end

	local ARK9PDialdigits = {math.floor((MainPanel:get_argument_value(678) * 21)+1), --Add since 0 is Channel 1, number for multiplation due to Arg rounding requirements
						   math.floor(((MainPanel:get_argument_value(452)+0.05) * 10)), --Need to round for Arg value (see huey file for more info)
						   math.floor(((MainPanel:get_argument_value(451)+0.0)* 52)) --Get wierd display if negative tuning or over 9
							}

	local ARK9PDialDisplay = ""
    for index, value in ipairs(ARK9PDialdigits) do
        local ARK9PDialDisplayToAppend = value
        if value >= 600 then
            ARK9PDialDisplayToAppend = 600
        end
        ARK9PDialDisplay = ARK9PDialDisplay..ARK9PDialDisplayToAppend --ARK-9 Primary
	end

	if ARK9Switch == 0 then
		ARK9DialDisplay = ARK9BDialDisplay
	elseif ARK9Switch == 1 then
		ARK9DialDisplay = ARK9PDialDisplay
	end

	--SPU-7
	local ICPdigits = {math.floor(MainPanel:get_argument_value(550) * 10)}

	local ICPdisplay = ""
    for index, value in ipairs(ICPdigits) do
        local ICPdisplayToAppend = value
        if value >= 10 then
            ICPdisplayToAppend = 0
        end
        ICPdisplay = ICPdisplay..ICPdisplayToAppend
	if ICSSwitch == 1 then
		RadioDisplay = "0000"
		RadioDisplay1 = "I"
		RadioDisplay2 = "C"
	elseif value == 0 then --863
		RadioDisplay = FM1String
		RadioDisplay1 = "6"
		RadioDisplay2 = "3"
	elseif value == 1 then
		RadioDisplay = HFString
		RadioDisplay1 = "H"
		RadioDisplay2 = "F"
	elseif value == 2 then --828
		RadioDisplay = VHFString
		RadioDisplay1 = "2"
		RadioDisplay2 = "8"
	elseif value == 3 then
		RadioDisplay = "0000" --Not Implimented in Game
		RadioDisplay1 = "S"
		RadioDisplay2 = "W"
	elseif value == 4 then
		RadioDisplay = ARK9DialDisplay
		RadioDisplay1 = "A"
		RadioDisplay2 = "9"
	elseif value == 5 then
		RadioDisplay = ARKUDDialDisplay
		RadioDisplay1 = "U"
		RadioDisplay2 = "D"
		end
    end

	--Radio Channel R-863, Radio Channel Selector Knob
	local R863Dialdigits = {math.floor(((MainPanel:get_argument_value(370)+0.025) * 20)+1)} --Add since 0 is Channel 1, also need to round Arg value (see huey file for more info)

	local LeftDialDisplay = ""
    for index, value in ipairs(R863Dialdigits) do
        local LeftDialDisplayToAppend = value
        if value >= 21 then
            LeftDialDisplayToAppend = 1
        end
        LeftDialDisplay = LeftDialDisplay..LeftDialDisplayToAppend
	end

	--R-828, Radio Channel Selector Knob
	local R828Dialdigits = {math.floor(((MainPanel:get_argument_value(735)+0.05) * 10)+1)} --Add since 0 is Channel 1, also need to round Arg value (see huey file for more info)

	local RightDialDisplay = ""
    for index, value in ipairs(R828Dialdigits) do
        local RightDialDisplayToAppend = value
        if value >= 11 then
            RightDialDisplayToAppend = 1
        end
        RightDialDisplay = RightDialDisplay..RightDialDisplayToAppend
	end

	--Weapons

	if RocketPairsSwitch == 1 then
		RocketNum = "RKT8"
	elseif RocketPairsSwitch == 0 then
		RocketNum = "RKTS"
	elseif RocketPairsSwitch == -1 then
		RocketNum ="RKT4"
	end

	if MasterArm == 0 then
		WepsDisplay = "SAFE"
	elseif WepsSwitch == 1 then
		WepsDisplay = "GUNS" --UPK
	elseif WepsSwitch == 0 then
		WepsDisplay = "PKT"
	elseif WepsSwitch == -1 then
		WepsDisplay = RocketNum --RS
	end

    return ufcUtils.buildSimAppProUFCPayload({
        scratchPadNumbers=RadioDisplay, --Freq of Slectected Radio
        option1=baroradarAltitudeString100,--radarAltitudeString, --Altitiude
		option2=HeadingString,
		option3="",--FuelString,  --Commented Out Pending linear investigation
		option4="MI-8",--AirspeedString,  --Commented Out Pending linear investigation
        option5=WepsDisplay,
		com1=LeftDialDisplay,
		com2=RightDialDisplay,
		scratchPadString1=RadioDisplay1, --RadioType1
		scratchPadString2=RadioDisplay2	 --RadioType2
    })
end


return ufcPatchMI8 --v1.0 by ANDR0ID