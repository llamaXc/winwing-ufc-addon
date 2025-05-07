local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")
local lightsHelper = require("ufcPatch\\utilities\\wwLights")

ufcPatchJF17 = {}

--JF-17 Light Program
function ufcPatchJF17.generateLightData()
	local MainPanel = GetDevice(0)

	local AAlight = MainPanel:get_argument_value(163)
	local AG1light = MainPanel:get_argument_value(164)
	local AG2light = MainPanel:get_argument_value(165)
	
	local UFCDisplaySetting = MainPanel:get_argument_value(732)
	local UFCState = UFCDisplaySetting
	
	if AAlight ~= 0 then
		aaLightState = "1"
		agLightState = "0"
	elseif AG1light ~= 0 then
		aaLightState = "0"
		agLightState = "1"
	elseif AG2light ~= 0 then
		aaLightState = "0"
		agLightState = "1"
	end

	local landingGearLightState = MainPanel:get_argument_value(107)

	return {
		[lightsHelper.LANDING_GEAR_HANDLE] = landingGearLightState,
		[lightsHelper.AA] = aaLightState,
		[lightsHelper.AG] = agLightState,
		[lightsHelper.APU_READY] = 0,
		[lightsHelper.JETTISON_CTR] = 0,
		[lightsHelper.JETTISON_LI] = 0,
		[lightsHelper.JETTISON_LO] = 0,
		[lightsHelper.JETTISON_RI] = 0,
		[lightsHelper.JETTISON_RO] = 0,
		[lightsHelper.ALR_POWER] = 0,
		[lightsHelper.UFC_BRIGHTNESS] = UFCState
	}
end

-- JF-17 Thunder: Shows UFCP values
function ufcPatchJF17.generateUFCData()

	local MainPanel = GetDevice(0)
	local Radio1 = GetDevice(25)
	local Radio2 = GetDevice(26)

--Initial Data
	local PwrSwpos = MainPanel:get_argument_value(904)

	if PwrSwpos == 1 then

	Radio1Freq = Radio1:get_frequency()
	Radio2Freq = Radio2:get_frequency()

	MasterArmStatus = MainPanel:get_argument_value(509)
	AAlight = MainPanel:get_argument_value(163)
	AG1light = MainPanel:get_argument_value(164)
	AG2light = MainPanel:get_argument_value(165)
	UFCPL4Button = MainPanel:get_argument_value(724)
	UFCPR4Button = MainPanel:get_argument_value(725)

    JF17Data3 = ufcUtils.getDCSListIndication(3) --1st Line of UFCP
	JF17Data4 = ufcUtils.getDCSListIndication(4) --2nd Line of UFCP
    JF17Data5 = ufcUtils.getDCSListIndication(5) --3rd Line of UFCP
	JF17Data6 = ufcUtils.getDCSListIndication(6) --4th Line of UFCP

	UFCP1 = JF17Data3.txt_win1
	UFCP2 = JF17Data4.txt_win2
	UFCP3 = JF17Data5.txt_win3
	UFCP4 = JF17Data6.txt_win4

	UFCP4_R_Three = string.sub(UFCP4, 6, 8) --Shows the last three digits of the string (Comm2 Channel)
	end
		--Radio Freq Display

	local Radio1digits = {math.floor(Radio1Freq / 1000)}

    local Radio1String = ""
    for index, value in ipairs(Radio1digits) do
        local Radio1digitToAppend = value
        if value >= 400000 then
            Radio1digitToAppend = 400000
        end
        Radio1String = Radio1String..Radio1digitToAppend
    end

	local Radio2digits = {math.floor(Radio2Freq / 1000)}

    local Radio2String = ""
    for index, value in ipairs(Radio2digits) do
        local Radio2digitToAppend = value
        if value >= 400000 then
            Radio2digitToAppend = 400000
        end
        Radio2String = Radio2String..Radio2digitToAppend
    end

	--Radio Freq Display cont
	if UFCPL4Button == 1 then
		RadioDisplay = Radio1String
		RadioDisplay1 = "C"
		RadioDisplay2 = "1"
	elseif UFCPR4Button == 1 then
		RadioDisplay = Radio2String
		RadioDisplay1 = "C"
		RadioDisplay2 = "2"
	end

	--Master Arm Status
	if MasterArmStatus < 0 then
		MasterArmIndicator = "S"
	elseif MasterArmStatus == 0 then
		MasterArmIndicator = "X"
	elseif MasterArmStatus > 0 then
		MasterArmIndicator = "A"
	end

	--AG Mode
	if AAlight ~= 0 then
		ModeIndicator = "A"
	elseif AG1light ~= 0 then
		ModeIndicator = "1"
	elseif AG2light ~= 0 then
		ModeIndicator = "2"
	end

        -- Generate the required SimApp Pro values to "mock" the F18 UFC with JF-17 values
        -- In theory, you could replace these with a custom value from another module, and have them appear on the DCS UFC
        return ufcUtils.buildSimAppProUFCPayload({
            option1=JF17Data3.txt_win1,
            option2=JF17Data4.txt_win2,
            option3=JF17Data5.txt_win3,
            option4=JF17Data6.txt_win4,
            option5=UFCP4_R_Three,
            scratchPadNumbers=RadioDisplay,
            scratchPadString1=RadioDisplay1,
            scratchPadString2=RadioDisplay2,
            com1=MasterArmIndicator,
            com2=ModeIndicator
        })

end

return ufcPatchJF17  --v2.1 by ANDR0ID 16MAR25