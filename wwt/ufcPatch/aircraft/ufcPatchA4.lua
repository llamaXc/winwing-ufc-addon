--[[UFC Patch A4 User Guide for Pilots - NATOPSGPT4 Style

Navigation Functions
To access the navigation functions provided by the UFC Patch script, 
ensure the script is running, and refer to the following information displayed on the UFC:
Speed (IAS): Indicated airspeed is automatically displayed.
Altitude (Barometric/Radar): Barometric or radar altitude information is presented.
Angle of Attack (AOA): AOA values are visible.
Magnetic Heading (BRNG): Magnetic heading readings are shown.
Pitch Attitude (PITCH): Pitch attitude information is provided.
Scratchpad Numbers (Bearing and DME): UFC displays the bearing and DME (Distance Measuring Equipment) values.
Scratchpad Strings (Navigation Modes): Current navigation mode strings are presented.
Communication Status: Updated communication status is provided.
Trim Settings: Information regarding trim settings is displayed.
Selected Windows: The status of selected windows, such as flaps, hook, spoiler, and gear, is indicated.

Weapons Control
To engage the weapons control mode, arm the Master Arm and refer to the following information displayed on the UFC:
Speed (IAS): Indicated airspeed is automatically displayed.
Altitude (Barometric/Radar): Barometric or radar altitude information is presented.
Angle of Attack (AOA): AOA values are visible.
Pitch Attitude (PITCH): Pitch attitude information is provided.
Weapon Function Display (WPRNFUNCDISPLAY): UFC displays the selected weapon function.
Scratchpad Numbers (Pylon Status): The status of pylons is indicated.
Scratchpad Strings (Weapon/Bomb Modes): Current weapon or bomb mode strings are presented.
Communication Status: Updated communication status is provided.
Tachometer Display: Relevant RPM information is shown on the tachometer.
Trim Settings: Information regarding trim settings is displayed.
Selected Windows: The status of selected windows, such as flaps, hook, spoiler, and gear, is indicated.

Landing Gear Operations
To activate the landing gear operations mode, extend the landing gear and refer to the following information displayed on the UFC:
Speed (IAS): Indicated airspeed is automatically displayed.
Altitude (Barometric/Radar): Barometric or radar altitude information is presented.
Angle of Attack (AOA): AOA values are visible.
Magnetic Heading (BRNG): Magnetic heading readings are shown.
Pitch Attitude (PITCH): Pitch attitude information is provided.
Scratchpad Numbers (ILS LOC): The ILS LOC (Localizer) information is displayed.
Scratchpad Strings (Landing Gear Mode): Current landing gear mode string is presented.
Communication Status: Updated communication status is provided.
Tachometer Display: Relevant RPM information is shown on the tachometer.
Trim Settings: Information regarding trim settings is displayed.
Selected Windows: The status of selected windows, such as flaps, hook, spoiler, and gear, is indicated.

Refueling Operations
To utilize the refueling operations mode with the UFC Patch script, follow these steps:
Ensure that the fuel probe light and/or drop tank fuel pressure switches are activated accordingly.
Refer to the following information displayed on the UFC:
Speed (IAS): Indicated airspeed is automatically displayed.
Tachometer Display: Relevant RPM information is shown on the tachometer.
Altitude (Barometric/Radar): Barometric or radar altitude information is presented.
Angle of Attack (AOA): AOA values are visible.
Variometer (VVY): Variometer or vertical speed information is displayed.
Convoluted Distance: Distance information is presented based on the DME (Distance Measuring Equipment) values.
Scratchpad Numbers (Bearing and DME): The UFC displays the bearing and DME (Distance Measuring Equipment) values.
Scratchpad Strings: The scratchpad strings "R" (Refuel) and "F" (Fuel Quantity) are shown.
Communication Status: Updated communication status is provided.
Fuel System Status: The UFC indicates the status of the fuel system with "R" for refuel, "P" for pressurized, or "X" for off.
Fuel Quantity: The UFC displays the fuel quantity percentage.
Selected Windows: The status of selected windows, such as flaps, hook, spoiler, and gear, is indicated.
]]

local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")
ufcPatchA4 = {}

function ufcPatchA4.generateUFCData()
    local MainPanel = GetDevice(0)
    local MASTERARM = MainPanel:get_argument_value(709)
    local GEARHANDLE = MainPanel:get_argument_value(8)
	local HOOK = MainPanel:get_argument_value(10)
	local FLAPS = MainPanel:get_argument_value(132)
	local SPOILER = MainPanel:get_argument_value(84)
	local SPDBRK = MainPanel:get_argument_value(85)
	local GUNSWITCH = MainPanel:get_argument_value(701)
	local GUNPODARM = MainPanel:get_argument_value(390)	
	local GUNPODLEFT = MainPanel:get_argument_value(391)	
	local GUNPODCENTER = MainPanel:get_argument_value(392)	
	local GUNPODRIGHT = MainPanel:get_argument_value(393)	
	local BOMBARM = MainPanel:get_argument_value(702)
	local WPNSTN1 = MainPanel:get_argument_value(703)
	local WPNSTN2 = MainPanel:get_argument_value(704)
	local WPNSTN3 = MainPanel:get_argument_value(705)
	local WPNSTN4 = MainPanel:get_argument_value(706)
	local WPNSTN5 = MainPanel:get_argument_value(707)
	local WPNFUNCSEL = MainPanel:get_argument_value(708)
	local ROLLTRIM = MainPanel:get_argument_value(871)
	local ASN41FUNCSEL = MainPanel:get_argument_value(176)
	local BDHIHDG = MainPanel:get_argument_value(780)
	local BDHISWITCH = MainPanel:get_argument_value(724)
	local ILSGS = MainPanel:get_argument_value(381)
	local ILSLOC = MainPanel:get_argument_value(382)
	local FUELGAUGE = MainPanel:get_argument_value(580)
	local AFCS_ENGAGE = MainPanel:get_argument_value(161)
	local AFCS_HDG_100s = math.floor(MainPanel:get_argument_value(167) * 10 + 0.5)
	local AFCS_HDG_10s = math.floor(MainPanel:get_argument_value(168) * 10 + 0.5)
	local AFCS_HDG_1s = math.floor(MainPanel:get_argument_value(169) * 10 + 0.5)
	local AFCSHDG = AFCS_HDG_100s .. AFCS_HDG_10s .. AFCS_HDG_1s
	local APC_ENABLE_STBY_OFF = MainPanel:get_argument_value(135)
	local APS_COLD_STD_HOT = MainPanel:get_argument_value(136)
	local MASTERLIGHTSWITCH = MainPanel:get_argument_value(83)
	local FUELPROBELIGHT = MainPanel:get_argument_value(217)	
	local FUELSYSTEMS = MainPanel:get_argument_value(101)
	local tacanmajor1to12 = MainPanel:get_argument_value(101)
	local tacanminor0to9 = MainPanel:get_argument_value(101)
	local ARN52TACAN = MainPanel:get_argument_value(900)
	
	local DROPTANKFUELSTATUS
		if FUELSYSTEMS == -1 then			-- DROP FUEL TANK REFUEL MODE
			DROPTANKFUELSTATUS = "R"
		elseif FUELSYSTEMS == 1 then		-- DROP FUEL TANKS OFF
			DROPTANKFUELSTATUS = "X"
		else								-- DROP FUEK TANKS NORMAL
			DROPTANKFUELSTATUS = "P"
	end
	
	-- Accelerometer or G-Force meter
	local gforce_raw = math.floor(MainPanel:get_argument_value(360) * 100)
	local gforce_text_map = {
		[0] = "G 00",
		[10] = "G 10", [15] = "G 15", [20] = "G 20", [25] = "G 25", [30] = "G 30",
		[35] = "G 35", [40] = "G 40", [45] = "G 45", [50] = "G 50", [55] = "G 55",
		[60] = "G 60", [65] = "G 65", [70] = "G 70", [75] = "G 75", [80] = "G 80",
		[85] = "G 85", [90] = "G 90", [95] = "G 95",
		[-10] = "G-05", [-20] = "G-10", [-30] = "G-15", [-40] = "G-20",
		[-50] = "G-25", [-60] = "G-30", [-70] = "G-35", [-80] = "G-40"
	}

	local closest_gforce_raw = nil
	for k, _ in pairs(gforce_text_map) do
		if closest_gforce_raw == nil or math.abs(gforce_raw - k) < math.abs(gforce_raw - closest_gforce_raw) then
			closest_gforce_raw = k
		end
	end

	local gforce_text = gforce_text_map[closest_gforce_raw] or ""

	-- Radar Altimeter
	function linearInterpolation(x, x1, y1, x2, y2)
		return y1 + (x - x1) * (y2 - y1) / (x2 - x1)
	end

	function getRadarAltitudeValue(radar_alt)
		if radar_alt <= 0.25 then
			return radar_alt * 400
		elseif radar_alt <= 0.30 then
			return linearInterpolation(radar_alt, 0.25, 100, 0.30, 150)
		elseif radar_alt <= 0.35 then
			return linearInterpolation(radar_alt, 0.30, 150, 0.35, 200)
		elseif radar_alt <= 0.45 then
			return linearInterpolation(radar_alt, 0.35, 200, 0.45, 400)
		elseif radar_alt <= 0.55 then
			return linearInterpolation(radar_alt, 0.45, 400, 0.55, 600)
		elseif radar_alt <= 0.65 then
			return linearInterpolation(radar_alt, 0.55, 600, 0.65, 1000)
		elseif radar_alt <= 0.80 then
			return linearInterpolation(radar_alt, 0.65, 1000, 0.80, 2000)
		elseif radar_alt <= 0.95 then
			return linearInterpolation(radar_alt, 0.80, 2000, 0.95, 5000)
		else
			return 5000
		end
	end

	-- Fuel Quantity / Totalizer
	local fuelQuantityPercentage = math.floor(FUELGAUGE * 100)
	local FUELQUANTITY = string.format("F%03d", fuelQuantityPercentage)
	local FUELQUANTITY2 = string.format("F%2d", fuelQuantityPercentage)

	-- ~Variometer / Vertical Speed
	local vvy_ftmin = MainPanel:get_argument_value(800) * 60 / 3.28084
	local VVY = string.format("V%s%02d", vvy_ftmin >= 0 and "" or "-", math.abs(math.floor(vvy_ftmin)))

	-- BDHI Hearding 
	local BDHIHDG = MainPanel:get_argument_value(780)
	local bdhiActualHeading = BDHIHDG * 360
	bdhiActualHeading = bdhiActualHeading % 360 -- Restrict the value to the range of 0 to 359
	local bdhiHeadingDisplay = string.format("H%03d", math.floor(bdhiActualHeading))

-- BDHI DME (Distance Measuring Equipment)
local BDHI_DME_Xxx = MainPanel:get_argument_value(785)
local BDHI_DME_xXx = MainPanel:get_argument_value(784)
local BDHI_DME_xxX = MainPanel:get_argument_value(783)

function calculateDMEValue(hundreds, tens, ones)
    return hundreds * 100 + tens * 10 + ones
end

local dmeHundreds = math.floor(BDHI_DME_Xxx * 10)
local dmeTens = math.floor(BDHI_DME_xXx * 10)
local dmeOnes = math.floor(BDHI_DME_xxX * 10)

local dmeMiles = calculateDMEValue(dmeHundreds, dmeTens, dmeOnes)
local dmeDisplay = string.format("%03d", calculateDMEValue(dmeHundreds, dmeTens, dmeOnes))

local dmeFeet = (BDHI_DME_Xxx * 100 + BDHI_DME_xXx * 10 + BDHI_DME_xxX) * 5280
local displayDmeFeet = string.format("%04d", dmeFeet % 10000)
local convoluted = dmeMiles >= 1 and "M" .. dmeDisplay or displayDmeFeet





	local function rawToBearing(rawValue)
		return (rawValue * 360.0)
	end

	local bearingPointer = rawToBearing(MainPanel:get_argument_value(782))
	local bearingDisplay = string.format("%03d", math.floor(bearingPointer))

	-- ASN Waypoint settings
	local function getASN41Display(ASN41FUNCSEL)
		local value = math.floor(ASN41FUNCSEL * 100 + 0.5) -- Convert to integer

		if value == 0 then
			return "T"
		elseif value == 10 then
			return "-"
		elseif value == 20 then
			return "S"
		elseif value == 30 then
			return "1"
		elseif value == 40 then
			return "2"
		else
			return "X" -- Display "X" if ASN41FUNCSEL is out of the expected range
		end
	end

	local ASN41Display = getASN41Display(ASN41FUNCSEL)

	-- Pitch trim settings
	local function pitchTrimToGaugeValue(pitchTrimRaw)
		local inputMin, inputMax = -3, 13
		local outputMin, outputMax = -0.25, 1

		-- Convert raw value to a value in the range [0, 1]
		local normalizedValue = (pitchTrimRaw - outputMin) / (outputMax - outputMin)

		-- Convert the normalized value to a value in the range [inputMin, inputMax]
		local gaugeValue = inputMin + normalizedValue * (inputMax - inputMin)

		-- Round the gauge value to the nearest integer
		local roundedGaugeValue = math.floor(gaugeValue + 0.5)

		return roundedGaugeValue
	end

	local PITCHTRIM = MainPanel:get_argument_value(870)
	local pitchTrimGaugeValue = pitchTrimToGaugeValue(PITCHTRIM)
	local pitchTrimDisplay = string.format("%2d", pitchTrimGaugeValue)

		local NAVString1, NAVString2
		if BDHISWITCH == 1 then
			NAVString1 = "N"
			NAVString2 = "C"
		elseif BDHISWITCH == 0 then
			NAVString1 = "T"
			NAVString2 = "C"
		elseif BDHISWITCH == -1 then
			NAVString1 = "N"
			NAVString2 = "P"
		end
		
	-- Weapon or bomb scratchpadstring selection
	local BombString1, BombString2
	if GUNSWITCH > 0.5 and GUNPODARM > 0.5 then
		BombString1 = "G"
		BombString2 = "G"
	elseif GUNPODARM > 0.5 then
		BombString1 = "P"
		BombString2 = "D"
	elseif GUNSWITCH > 0.5 then
		BombString1 = "G"
		BombString2 = "N"
	elseif BOMBARM == 1 then
		BombString1 = "B"
		BombString2 = "N"
	elseif BOMBARM == -1 then
		BombString1 = "B"
		BombString2 = "T"
	else
		BombString1 = "B"
		BombString2 = "-"
	end

	local function getPylonStatusValue(pylonArg, pylonWithGunpod)
		if pylonArg > 0.5 then
			if pylonWithGunpod then
				return "2"
			else
				return "1"
			end
		else
			return "."
		end
	end

	local pylonStatus = string.format("%s%s%s%s%s",
		getPylonStatusValue(WPNSTN1, false),
		getPylonStatusValue(WPNSTN2, GUNPODLEFT > 0.5),
		getPylonStatusValue(WPNSTN3, GUNPODCENTER > 0.5),
		getPylonStatusValue(WPNSTN4, GUNPODRIGHT > 0.5),
		getPylonStatusValue(WPNSTN5, false)
	)

	local function getFuncDisplay(wpnFuncSel)
		if wpnFuncSel >= 0 and wpnFuncSel < 0.1 then
			return "OFF "
		elseif wpnFuncSel >= 0.1 and wpnFuncSel < 0.15 then
			return "RCKT"
		elseif wpnFuncSel >= 0.15 and wpnFuncSel < 0.25 then
			return "GMUA"
		elseif wpnFuncSel >= 0.25 and wpnFuncSel < 0.35 then
			return "SPRY"
		elseif wpnFuncSel >= 0.35 and wpnFuncSel < 0.45 then
			return "LABS"
		elseif wpnFuncSel >= 0.45 and wpnFuncSel < 0.55 then
			return "BGMA"
		elseif wpnFuncSel >= 0.55 and wpnFuncSel <= 0.65 then
			return "CMPT"
		else
			return "XXXX"
		end
	end

	local WPRNFUNCDISPLAY = getFuncDisplay(WPNFUNCSEL)

	local scratchPadNumbersDisplay = "  " .. pylonStatus

	-- RPMs
	local tacho = MainPanel:get_argument_value(520) * 100 + 3
	local tachodisplay = string.format("%2d", math.floor(tacho))			-- 2 digit percentage
	local tachodisplay2 = string.format("R%03d", math.floor(tacho * 10))	-- 3 digit percentage eg 99 point 9

	-- Angle of Attack
	local AOA = string.format("%.0f", MainPanel:get_argument_value(840) * 300)
	local ANGLE = "A" .. AOA

	local radar_alt = MainPanel:get_argument_value(600)
	local RALTONOFF = MainPanel:get_argument_value(604)
    local radar_alt_transformed = RALTONOFF == 1 and 0 or getRadarAltitudeValue(radar_alt)
    local radar_alt_str = string.format("%.0f", radar_alt_transformed)

	local altitudeFeet = math.floor(LoGetAltitudeAboveSeaLevel() * 3.280839895)
	local thousands = math.floor(altitudeFeet / 1000)
	local hundreds = math.floor((altitudeFeet % 1000) / 100)
	local altBar
	if thousands < 10 then
		altBar = string.format('0%dK%d', thousands, hundreds)
	else
		altBar = string.format('%dK%d', thousands, hundreds)
	end
		
	local IAS = string.format('%d', math.floor(LoGetIndicatedAirSpeed() * 1.943844))
	local TAS = string.format('%d', math.floor(LoGetTrueAirSpeed() * 1.943844))
	local SPEED = "I" .. IAS
	local TRUESPEED = "T" .. TAS

	local ALTS
	if RALTONOFF == 1 then
		ALTS = altBar
	elseif tonumber(radar_alt_str) >= 5000 then
		ALTS = altBar
	else
		ALTS = radar_alt_str
	end

	local selfData = LoGetSelfData()
	local heading = selfData.Heading -- TRUE NORTH BEARING
	local headingDegrees = math.deg(heading)
	local headingDisplay = headingDegrees % 360
	local headingString = string.format("%03d", math.floor(headingDisplay))
	local BRNG = "B" .. headingString

	local pitch = selfData.Pitch
	local pitchDegrees = math.deg(pitch)
	local pitchDisplay = math.max(-99, math.min(99, pitchDegrees))
	local pitchString
	if pitchDisplay >= 0 then
		pitchString = string.format("%3d", pitchDisplay)
	else
		pitchString = string.format("%3d", pitchDisplay)
	end
	local PITCH = "P" .. pitchString


	function formatILSLOC(ilsloc)
		local formatted = ""
		local position = math.floor((1 - (-ilsloc)) * 3) + 1
		if position < 1 then
			position = 1
		elseif position > 7 then
			position = 7
		end

		for i = 1, 7 do
			if i == position then
				formatted = formatted .. "."
			elseif i == position - 1 or i == position + 1 then
				formatted = formatted .. "-"
			else
				formatted = formatted .. " "
			end
		end

		return formatted
	end

	local formattedILSLOC = formatILSLOC(ILSLOC)

	local selectedWindows = {}
	if FLAPS == -1 then
       table.insert(selectedWindows, "1")
	end
 	if HOOK == 1 then
       table.insert(selectedWindows, "2")
	end
	if SPDBRK == 1 then
       table.insert(selectedWindows, "3")	   
    end
	if SPOILER == 1 then
       table.insert(selectedWindows, "4")	   
    end

	function buildNavigationPayload(MainPanel)		-- NAVIGATION
		local currentTime = os.time()
		local elapsedTime = currentTime % 20
		local elapsedTimeGV = currentTime % 6	
		local option3_value

		if elapsedTime < 15 then
			option3_value = ANGLE
		else
			option3_value = FUELQUANTITY
		end

		if elapsedTime < 15 then
			option4_value = BRNG
		else
			option4_value = "X" .. AFCSHDG
		end

		if elapsedTimeGV < 3 then
			option5_value = gforce_text
		else
			option5_value = VVY
		end

		return ufcUtils.buildSimAppProUFCPayload({
			option1 = SPEED,					
			option2 = ALTS,						
			option3 = option3_value,					
			option4 = option4_value,						
			option5 = option5_value,
			scratchPadNumbers = bearingDisplay .. "-" .. dmeDisplay,
			scratchPadString1 = NAVString1,
			scratchPadString2 = NAVString2,
			com1 = ASN41Display,
			com2 = pitchTrimDisplay,
			selectedWindows = selectedWindows
		})
	end

	function buildMasterArmArmedPayload(MainPanel)		-- WEAPONS
		return ufcUtils.buildSimAppProUFCPayload({
			option1 = SPEED,
			option2 = ALTS,
			option3 = ANGLE,
			option4 = PITCH,
			option5 = WPRNFUNCDISPLAY,
			scratchPadNumbers = scratchPadNumbersDisplay,
			scratchPadString1 = BombString1,
			scratchPadString2 = BombString2,
			com1 = tachodisplay,
			com2 = pitchTrimDisplay,
			selectedWindows = selectedWindows
		})
	end

	function buildLandingGearDownPayload(MainPanel)		 -- LANDING

		local currentTime = os.time()
		local elapsedTimeAPC = currentTime % 6
		local option1_value
		if APC_ENABLE_STBY_OFF == 1 then
			if elapsedTimeAPC < 3 then
				option1_value = "APC1"
			else
				option1_value = SPEED
			end
		else
			option1_value = SPEED
		end

		return ufcUtils.buildSimAppProUFCPayload({
			option1 = option1_value,				
			option2 = ALTS,						
			option3 = ANGLE,					
			option4 = BRNG,						
			option5 = PITCH,					
			scratchPadNumbers = formattedILSLOC,
			scratchPadString1 = "L",
			scratchPadString2 = " ",
			com1 = tachodisplay,
			com2 = pitchTrimDisplay,
			selectedWindows = selectedWindows
		})
	end

	function buildRefuelPayload(MainPanel)		-- REFUEL
	
		return ufcUtils.buildSimAppProUFCPayload({
			option1 = SPEED,											-- IAS
			option2 = tachodisplay2,									-- 3 DIGIT PERCENTRAGE RPMS
			option3 = ALTS,												-- BALT / RALT
			option4 = VVY,												-- Variometer
			option5 = convoluted,										-- DISTANCE INFO
			scratchPadNumbers = bearingDisplay .. "-" .. dmeDisplay,	-- BEARING ON TARGET / DISTANCE
			scratchPadString1 = "R",
			scratchPadString2 = "F",							
			com1 = DROPTANKFUELSTATUS,									-- SHOW "R" IF FUELSYSTEMS= -1(REFUEL). SHOW "P" IF FUELSYSTEMS= 0(PRESSURIZED). SHOW "X" IF FUELSYSTEMS= 1 (OFF).
			com2 = FUELQUANTITY2,										-- FUEL QUANTITY PERCENTAGE
			selectedWindows = selectedWindows
		})
	end

			if GEARHANDLE > 0.5 then
				return buildLandingGearDownPayload(MainPanel)
			elseif MASTERARM > 0.5 then
				return buildMasterArmArmedPayload(MainPanel)
			elseif (FUELPROBELIGHT == -1 or FUELPROBELIGHT == 1) or (FUELSYSTEMS == -1 or FUELSYSTEMS == 1) then
				return buildRefuelPayload(MainPanel)
			else
				return buildNavigationPayload(MainPanel)
			end
	end

return ufcPatchA4

--[[






]]--