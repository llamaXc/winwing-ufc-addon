local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

local ufcPilotSpadTimestamp = nil
local ufcWsoSpadTimestamp = nil

ufcPatchF15e = {}

function ufcPatchF15e.generateUFCData()

    local MainPanel = GetDevice(0)
    local INDICATOR_0 = ufcUtils.getDCSListIndication(0) --NF_FOV_Left value?
    local HUD = ufcUtils.getDCSListIndication(1)
    local PILOT_LEFT_MFD = ufcUtils.getDCSListIndication(2)
    local PILOT_MFCD = ufcUtils.getDCSListIndication(4)
    local PILOT_RIGHT_MFD = ufcUtils.getDCSListIndication(6)
    local UFC = ufcUtils.getDCSListIndication(9)
    local WSO_MFD1	= ufcUtils.getDCSListIndication(10)
    local WSO_MFD2  = ufcUtils.getDCSListIndication(12)
    local WSO_MFD3  = ufcUtils.getDCSListIndication(14)
    local WSO_MFD4	= ufcUtils.getDCSListIndication(16)
    local WSO_UFC = ufcUtils.getDCSListIndication(18)

    local AltValue = math.floor((LoGetAltitudeAboveSeaLevel() * 3.281) / 10) * 10
    local BAltString = string.format("%02dK%d", math.floor(AltValue / 1000), math.floor((AltValue % 1000) / 100))
    local RAltValue = math.floor((LoGetAltitudeAboveGroundLevel() * 3.281) / 10) * 10
    local RAltString = "R" .. string.format('%.0f', RAltValue)
    local Altitudes = (RAltValue > 999) and BAltString or RAltString

    local UFCL01	= UFC and UFC.UFC_SC_01 or "01"
    local UFCR12	= UFC and UFC.UFC_SC_12 or "12"
    local UFCL02	= UFC and UFC.UFC_SC_02 or "02"
    local UFCR11	= UFC and UFC.UFC_SC_11 or "11"
    local UFCL03	= UFC and UFC.UFC_SC_03 or "03"
    local UFCR10	= UFC and UFC.UFC_SC_10 or "10"
    local UFCL04	= UFC and UFC.UFC_SC_04 or "04"
    local UFCR09	= UFC and UFC.UFC_SC_09 or "09"
    local UFCL05	= UFC and UFC.UFC_SC_05 or "05"
    local UFCR08	= UFC and UFC.UFC_SC_08 or "08"
    local UFCL06	= UFC and UFC.UFC_SC_06 or "06"
    local UFCR07	= UFC and UFC.UFC_SC_07 or "07"
    local UFC_SPAD	= UFC and UFC.UFC_CC_04 or ""
	local WSO_SPAD	= WSO_UFC and WSO_UFC.UFC_CC_04 or ""
	
	local Flaredigits = math.min(99, LoGetSnares().flare)
	local Chaffdigits = math.min(99, LoGetSnares().chaff)

    local Flaredigits = math.min(99, LoGetSnares().flare)
    local Chaffdigits = math.min(99, LoGetSnares().chaff)
    local SNARES

    if Flaredigits == 0 and Chaffdigits > 0 then
        SNARES = Chaffdigits
    elseif Chaffdigits == 0 and Flaredigits > 0 then
        SNARES = Flaredigits
    elseif Flaredigits == 0 and Chaffdigits == 0 then
        SNARES = "00"
    else
        SNARES = math.min(Flaredigits, Chaffdigits)
    end

    local TAS = HUD and HUD.Window01 or "SPD"

	-- MASTER MODE SELECTOR LIGHTS (FUNCTIONS ARE 126-129)
    local AA_LIGHT = MainPanel:get_argument_value(326)
    local AG_LIGHT = MainPanel:get_argument_value(327)
    local NAV_LIGHT = MainPanel:get_argument_value(328)
    local INST_LIGHT = MainPanel:get_argument_value(329)

-- Pilot UFC_SPAD and timestamp
if UFC and UFC.UFC_CC_04 ~= "" then
    UFC_SPAD = UFC.UFC_CC_04
    ufcPilotSpadTimestamp = os.clock() -- update the timestamp when UFC_SPAD data is generated
end

-- WSO UFC_SPAD and timestamp
if WSO_UFC and WSO_UFC.UFC_CC_04 ~= "" then
    WSO_SPAD = WSO_UFC.UFC_CC_04
    ufcWsoSpadTimestamp = os.clock() -- update the timestamp when WSO_SPAD data is generated
end

local NAVSTEER = HUD and HUD.Window18 or "000 00"
local scratchPadNumbers

-- Check the timestamps
if ufcPilotSpadTimestamp and os.clock() - ufcPilotSpadTimestamp <= 5 then
    scratchPadNumbers = UFC_SPAD -- if less than 5 seconds passed since pilot updated
elseif ufcWsoSpadTimestamp and os.clock() - ufcWsoSpadTimestamp <= 5 then
    scratchPadNumbers = WSO_SPAD -- if less than 5 seconds passed since WSO updated
else
    scratchPadNumbers = NAVSTEER -- otherwise, default to NAVSTEER
end

	local MASTERMODE
	if AA_LIGHT == 1 then
		MASTERMODE = "A"
	elseif AG_LIGHT == 1 then
		MASTERMODE = "G"
	elseif NAV_LIGHT == 1 then
		MASTERMODE = "N"
	elseif INST_LIGHT == 1 then
		MASTERMODE = "I"
	else
		MASTERMODE = " "
	end

    local Headingdigits =  {math.floor(LoGetMagneticYaw()* (180/math.pi))} 
	local HeadingString = ""
    for index, value in ipairs(Headingdigits) do
        local HeadingdigitToAppend = value
        if value >= 360 then
            HeadingdigitToAppend = 0
        end
        HeadingString = tostring(value) 
		if value == -7 then --These strings needed as there is a "negative heading bug" with LoGet
			HeadingString = "353M"
		elseif value == -6 then 
			HeadingString = "354M"
		elseif value == -5 then 
			HeadingString = "355M" 
		elseif value == -4 then 
			HeadingString = "356M"
		elseif value == -3 then 
			HeadingString = "357M"
		elseif value == -2 then 
			HeadingString = "358M"
		elseif value == -1 then 
			HeadingString = "359M"
		elseif value < 10 then 
			HeadingString = "00"..value.."M" 
		elseif value >= 100 then 
			HeadingString = ""..value.."M" 
		elseif value >= 10 then 
			HeadingString = "0"..value.."M"
		end
    end

    local Fuelpercentage = "F" .. string.format("%03d", math.floor(LoGetEngineInfo().fuel_internal * 100))

    local UFCL06NoSpace = string.gsub(UFCL06, " ", "")
    local UFCR07NoSpace = string.gsub(UFCR07, " ", "")

    local COMMS = UFCL06NoSpace .. UFCR07NoSpace

    if #COMMS < 4 then
        COMMS = UFCL06NoSpace .. "-" .. UFCR07NoSpace
    end

	local BOMB1 = HUD and HUD.Window19 or "BOMB"
	local bombDisplay = ""

    -- Define the expected designations
    local designations = {
        TREL = "R",
        TIMPCT = "I",
        TTGT = "T"
    }

    -- Extracting minutes, seconds, and designation from the bomb-related information
    local minutes, seconds, designation = string.match(BOMB1, "(%d+):(%d+)%s+(%a+)")
    if designation and designations[designation] then
        local bombTime = tonumber(minutes) * 60 + tonumber(seconds) -- Convert minutes and seconds to seconds
        local fourthDigit = designations[designation]

        bombDisplay = string.format("%03d%s", bombTime, fourthDigit)
    elseif COMMS and #COMMS > 0 then
        bombDisplay = COMMS
    else
        bombDisplay = COMMS
    end

    -- Check if steerpoint information is being displayed on any output
    local steerpointDigits
    local steerpointPattern = "(%a+)%s*(%d+)%.?(%a?)%s?"  -- updated pattern to make the period optional

    if HUD and HUD.Window17 and string.match(HUD.Window17, steerpointPattern) then
        steerpointDigits = { string.match(HUD.Window17, steerpointPattern) }
    elseif PILOT_RIGHT_MFD and PILOT_RIGHT_MFD.Steerpoint and string.match(PILOT_RIGHT_MFD.Steerpoint, steerpointPattern) then
        steerpointDigits = { string.match(PILOT_RIGHT_MFD.Steerpoint, steerpointPattern) }
    elseif PILOT_LEFT_MFD and PILOT_LEFT_MFD.Steerpoint and string.match(PILOT_LEFT_MFD.Steerpoint, steerpointPattern) then
        steerpointDigits = { string.match(PILOT_LEFT_MFD.Steerpoint, steerpointPattern) }
    elseif PILOT_MFCD and PILOT_MFCD.Steerpoint and string.match(PILOT_MFCD.Steerpoint, steerpointPattern) then
        steerpointDigits = { string.match(PILOT_MFCD.Steerpoint, steerpointPattern) }
    elseif WSO_MFD1 and WSO_MFD1.Steerpoint and string.match(WSO_MFD1.Steerpoint, steerpointPattern) then
        steerpointDigits = { string.match(WSO_MFD1.Steerpoint, steerpointPattern) }
    elseif WSO_MFD2 and WSO_MFD2.Steerpoint and string.match(WSO_MFD2.Steerpoint, steerpointPattern) then
        steerpointDigits = { string.match(WSO_MFD2.Steerpoint, steerpointPattern) }
    elseif WSO_MFD3 and WSO_MFD3.Steerpoint and string.match(WSO_MFD3.Steerpoint, steerpointPattern) then
        steerpointDigits = { string.match(WSO_MFD3.Steerpoint, steerpointPattern) }
    elseif WSO_MFD4 and WSO_MFD4.Steerpoint and string.match(WSO_MFD4.Steerpoint, steerpointPattern) then
        steerpointDigits = { string.match(WSO_MFD4.Steerpoint, steerpointPattern) }
    elseif WSO_UFC and WSO_UFC.UFC_SC_12 and string.match(WSO_UFC.UFC_SC_12, steerpointPattern) then
        steerpointDigits = { string.match(WSO_UFC.UFC_SC_12, steerpointPattern) }
    elseif UFC and UFC.UFC_SC_12 and string.match(UFC.UFC_SC_12, steerpointPattern) then
        steerpointDigits = { string.match(UFC.UFC_SC_12, steerpointPattern) }
    end

    -- Assign the extracted digit to scratchPadString2
    local scratchPadString1 = ""
    local scratchPadString2 = ""
    if steerpointDigits and #steerpointDigits > 1 then  -- check the length of steerpointDigits
        scratchPadString1 = steerpointDigits[2] or ""  -- the numeric part is the second element in steerpointDigits
        scratchPadString2 = steerpointDigits[3] or ""  -- the alphanumeric part is the third element in steerpointDigits
    end


    return ufcUtils.buildSimAppProUFCPayload({
 		option1= bombDisplay,
		option2= "V" .. TAS,
        option3= Altitudes,
        option4= "B" .. HeadingString,
        option5= Fuelpercentage,
        scratchPadNumbers=scratchPadNumbers,
        scratchPadString1=scratchPadString1,
        scratchPadString2=scratchPadString2,
        com1=SNARES,
        com2=MASTERMODE,
        selectedWindows={}
    })
end

return ufcPatchF15e