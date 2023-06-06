local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchA10C2 = {}


-- A10 UFC updated for combination of static and dynamic data by ANDR0ID
function ufcPatchA10C2.generateUFCData()
	local MainPanel = GetDevice(0) 
	
	local MasterCautionLight = MainPanel:get_argument_value(404)
	
	if MasterCautionLight == 1 then 
		Warn1 = "M"
		Warn2 = "C" 
	elseif MasterCautionLight == 0 then 
		Warn1 = ""
		Warn2 = ""
	end 
	
	--local A10C_CDU_ScratchPad = ufcUtils.getDCSListIndication(5) --getListIndicatorValue(5)
	
    --Example off setting the 5 option display windows to static values.
    return ufcUtils.buildSimAppProUFCPayload({
        option1="HACK",
        option2="FUNC",
        option3="LTR",
        option4="MK",
        option5="ALT",
		scratchPadString1=Warn1,
        scratchPadString2=Warn2,
		--scratchPadNumbers=A10C_CDU_ScratchPad.CDU_SUBSET_SCRATCHPAD
    })
end

return ufcPatchA10C2
