local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchCustomModuleExample = {}

-- Shows static data on the UFC
function ufcPatchCustomModuleExample.generateUFCData()
    log.write("WWT", log.INFO, "Trying to load custom example")
    return ufcUtils.buildSimAppProUFCPayload({
        option1="FOX3",
        option2="AIM9",
        option3="A120",
        option4="DCS",
        option5="UFC",
        scratchPadNumbers="2023",
        scratchPadString1="O",
        scratchPadString2="N",
        com1="X",
        com2="8",
        selectedWindows={"1", "2", "3", "4", "5"}
    })
end

return ufcPatchCustomModuleExample