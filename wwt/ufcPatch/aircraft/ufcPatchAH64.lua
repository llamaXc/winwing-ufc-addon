local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")
local lightsHelper = require("ufcPatch\\utilities\\wwLights")

ufcPatchAH64 = {}

--AH-64 Light Program 
function ufcPatchAH64.generateLightData()
	local MainPanel = GetDevice(0)
--Initial Data
	local PwrSwposLights = MainPanel:get_argument_value(315)
	local RWRPower = 0 
	
--Parking Brake 
	local ParkingBrake = MainPanel:get_argument_value(634) --AH-64 Parking Brake Display Indicator
	local landingGearLightState = 0 
	if ParkingBrake > 0.1 then
		landingGearLightState = 1
	end

--CMWS Status
	local CMWSSwitch = MainPanel:get_argument_value(610) --CMWS Switch
	if PwrSwposLights ~= 0 and CMWSSwitch == 0 then 
		RWRPower = 1
	else RWRPower = 0
	end 	
	
--APU_READY
	local APU_Status = MainPanel:get_argument_value(406) --AH-64 APU ON Display Indicator
	if PwrSwposLights ~= 0 and APU_Status == 1 then
		apuLightState = 1
	else apuLightState = 0 
	end 	
	
	return {
		[lightsHelper.LANDING_GEAR_HANDLE] = landingGearLightState,
		[lightsHelper.AA] = 0,
		[lightsHelper.AG] = 0,
		[lightsHelper.APU_READY] = apuLightState,
		[lightsHelper.JETTISON_CTR] = 0,
		[lightsHelper.JETTISON_LI] = 0,
		[lightsHelper.JETTISON_LO] = 0,
		[lightsHelper.JETTISON_RI] = 0,
		[lightsHelper.JETTISON_RO] = 0,
		[lightsHelper.ALR_POWER] = RWRPower,
	}
end

-- Timestamp for last KU data update
local lastKUDataTimestamp = nil

local function getKU(indication)
    local success, KU = pcall(ufcUtils.getDCSListIndication, indication)
    if not success then
        return nil
    end
    return KU
end

local function replace(key, value)
    local replacedValue = string.gsub(value, "#", "*")
    return replacedValue
end

local function defaultDisplay()

--ANDR0ID Added
local MainPanel = GetDevice(0) --Electical Interface for AH64

local MasterArmInfo = MainPanel:get_argument_value(413) --AH-64 Master Arm light
local MasterWarnInfo = MainPanel:get_argument_value(424) --AH-64 Master Arm Warning Light
local MasterCautInfo = MainPanel:get_argument_value(425) --AH-64 Master Arm Caution Light

	--Radar Altitude FC3
	
	local FC3RadarAlt = {
	math.floor(((LoGetAltitudeAboveGroundLevel())-1.5)*3.28) --Covert meters to feet & account for airframe offset 
	}

    local FC3RadarAltitudeString = ""
    for index, value in ipairs(FC3RadarAlt) do
        local FC3RadarAltitudeStringToAppend = value
		if value <= 0.9 then 
			FC3RadarAltitudeStringToAppend = 0      
		elseif value >= 9999 then
            FC3RadarAltitudeStringToAppend = 9999
        end
        FC3RadarAltitudeString = tostring(value)
		if value < 10 then 
		FC3RadarAltitudeString = "000"..value
		elseif value >= 1000 then 
		FC3RadarAltitudeString = ""..value
		elseif (value >= 100 and value <= 999) then 
		FC3RadarAltitudeString = "0"..value
		elseif (value >= 10 and value <= 99) then
		FC3RadarAltitudeString = "00"..value
		end 
    end

	--Heading (Magnetic) 
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
	
	--Fuel (Total)	
	local Fueldigits = {math.floor((LoGetEngineInfo().fuel_internal)*376*6.692)} --Coverts % fuel to pounds (Uses 376 gallons. as 100% per Chuck's Guide), works for internal, internal and aux, and interal and external 

    local FuelString = ""
    for index, value in ipairs(Fueldigits) do
        local FueldigitToAppend = value
        if value >= 9999 then
            FueldigitToAppend = 9999
        end
        FuelString = FuelString..FueldigitToAppend
    end
	
	--Countermeassures 
	local Flaredigits = LoGetSnares().flare
	local Chaffdigits = LoGetSnares().chaff
	
	--Master Arm 
	local MasterArmDigit = {math.floor(MasterArmInfo)} 
	
	local MasterArmDisplay = ""
    for index, value in ipairs(MasterArmDigit) do
        local MasterArmDisplayToAppend = value
        if value >= 0.2 then
            MasterArmDisplayToAppend = 1
        end
        MasterArmDisplay = MasterArmDisplay..MasterArmDisplayToAppend
		if value == 1 then 
		MasterArmDisplay1 = "ARMD"
	elseif value == 0 then 
		MasterArmDisplay1 = "SAFE"
		end
    end 
	
	--Master Warning / Caution 

	if MasterWarnInfo == 1 then 
		StatusDisplay = "WARN"
	elseif MasterCautInfo == 1 then 
		StatusDisplay = "CAUT" 
	elseif ((MasterWarnInfo == 0) and (MasterCautInfo == 0)) then 
		StatusDisplay = MasterArmDisplay1
	end 
	
--End ANDR0ID Added
    return ufcUtils.buildSimAppProUFCPayload({
        option1 = FC3RadarAltitudeString, --Radar Altitude --
        option2 = HeadingString, --Magnetic Heading 
        option3 = FuelString, --Fuel (Internal) in Gallons 
        option4 = "T" .. string.format('%.0f', LoGetTrueAirSpeed()*1.943), --True Airspeed (Knots)
        option5 = StatusDisplay,
		--"B" .. string.format('%.0f', math.floor((LoGetAltitudeAboveSeaLevel() * 3.281) / 10) * 10), --Barometric Altimeter 
        scratchPadNumbers = string.format('%.0f', math.floor(LoGetVerticalVelocity() * 196.85)) .. "  ", --Vertical Velocity (FPM)* 0.3048 * 10
		--"V" .. string.format('%.0f', math.floor(LoGetVerticalVelocity() * 0.3048 * 10)), --Vertical Velocity (FPS) 
        scratchPadString1 = "",
        scratchPadString2 = "V",
        com1 = Flaredigits,
        com2 = Chaffdigits,
        selectedWindows = {}
    })
end

function ufcPatchAH64.generateUFCData()
    local PLT_KU = getKU(15)
    local CPG_KU = getKU(14)

    if PLT_KU then
        for key, value in pairs(PLT_KU) do replace(key, value) end
    end

    if CPG_KU then
        for key, value in pairs(CPG_KU) do replace(key, value) end
    end

    local standbyText = ""
    if PLT_KU and PLT_KU["Standby_text"] and PLT_KU["Standby_text"] ~= "" then
        standbyText = PLT_KU["Standby_text"]
        lastKUDataTimestamp = os.time() -- KU data is available, record the time
    elseif CPG_KU and CPG_KU["Standby_text"] and CPG_KU["Standby_text"] ~= "" then
        standbyText = CPG_KU["Standby_text"]
        lastKUDataTimestamp = os.time() -- KU data is available, record the time
    else
        -- Check if 7 seconds have passed since last KU data was available, if so show default display
        if lastKUDataTimestamp == nil or (lastKUDataTimestamp and os.difftime(os.time(), lastKUDataTimestamp) >= 7) then
            return defaultDisplay()
        end

        return nil
    end

    if string.len(standbyText) > 19 then standbyText = string.sub(standbyText, 5) end

    local function getKPU(n)
        return string.gsub(string.gsub(standbyText:sub(n, n + 3), "#", "*"), ":", "-")
    end
--ANDR0ID Added
	--Countermeassures 
	local Flaredigits = LoGetSnares().flare
	local Chaffdigits = LoGetSnares().chaff
--End ANDR0ID Added
    return ufcUtils.buildSimAppProUFCPayload({
        option1 = getKPU(1),
        option2 = getKPU(5),
        option3 = getKPU(9),
        option4 = getKPU(13),
        option5 = getKPU(17),
        scratchPadNumbers = "-64    ",
        scratchPadString1 = "A",
        scratchPadString2 = "H",
        com1 = Flaredigits,
        com2 = Chaffdigits,
        selectedWindows = {}
    })
end

return ufcPatchAH64

--v1.0 by Wostg
--v2.0 by ANDR0ID 
--v3.0 by ANDR0ID 16MAR25
