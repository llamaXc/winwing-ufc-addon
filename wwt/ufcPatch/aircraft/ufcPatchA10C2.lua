local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchA10C2 = {}


-- Shows static data for the A10 UFC
function ufcPatchA10C2.generateUFCData()

    --Example off setting the 5 option display windows to static values.
    return ufcUtils.buildSimAppProUFCPayload({
        option1="FUNC",
        option2="HACK",
        option3="LTR",
        option4="MK",
        option5="ALT",
    })
end

return ufcPatchA10C2