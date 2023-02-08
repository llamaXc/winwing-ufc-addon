ufcPatch={}

ufcPatch.prevUFCPayload = nil
ufcPatch.useCustomUFC = false

-- Local A10C_2 variables
local a10CHasExported = false

-- Local AV88 variables
local prevAV88HarrierValues

-- Local time variables
local updateInterval = 0.2 -- update delay interval. units = seconds
local currentTimestamp = 0 -- seconds
local prevTimestamp = 0 --seconds
local canTransmitLatestPayload = true

-- Utility functions references
local getDCSListIndication
local buildSimAppProUFCPayload

-- Keep track of time
function ufcPatch.updateClock(deltaTime)
    currentTimestamp = currentTimestamp + deltaTime
    if currentTimestamp > updateInterval then 
        currentTimestamp = 0
        prevTimestamp = 0
        canTransmitLatestPayload = true
    else
        prevTimestamp = currentTimestamp
        canTransmitLatestPayload = false
    end
end

-- Initalize utility helper methods
function ufcPatch.initializeUFC()
    getDCSListIndication = ufcPatch.ufcPatchUtils.getDCSListIndication
    buildSimAppProUFCPayload = ufcPatch.ufcPatchUtils.buildSimAppProUFCPayload
end

-- UH-1 HUEY: Shows Radar Altimeter on scratch pad
local generateUFCDataForHuey = function()
    -- Only update every 200ms
    -- This is optinal but nice when data from DCS changes every frame
    -- Helps avoid sending a UFC message every game tick
    if canTransmitLatestPayload == false then 
        return nil
    end

    -- Access the UH1 Main panel from DCS
    local MainPanel = GetDevice(0)

    -- Got these argument values from: <DCS_INSTALL>\Mods\aircraft\Uh-1H\Cockpit\Scripts\mainpanel_init.lua
    local digits = {
        math.floor(MainPanel:get_argument_value(468) * 10),
        math.floor(MainPanel:get_argument_value(469) * 10),
        math.floor(MainPanel:get_argument_value(470) * 10),
        math.floor(MainPanel:get_argument_value(471) * 10)
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
    
    return buildSimAppProUFCPayload({
        scratchPadNumbers=radarAltitudeString,
        option1="FEET",
        option5="UH1H"
    })
end

-- AV88 Harrier: Shows ODU and UFC values
local generateUFCDataForAV88 = function()
    -- Avoid extra work by checking the base values up front. ODU + UFC == string of DCS Values
    -- Good practice to check the DCS value for any change before making the whole UFC Payload message
    local av88HarrierDCSValues = list_indication(6)..list_indication(5)
    if av88HarrierDCSValues ~= prevAV88HarrierValues then

        -- Update prev values
        prevAV88HarrierValues = av88HarrierDCSValues

        -- Query DCS for the current state of ODU and UFC
        local av88HarrierODU = getDCSListIndication(6)
        local av88HarrierUFC = getDCSListIndication(5)

        -- Get the scratch pad values (Example ON  16) for Tacan on channel 16.
        local ufcLeftStrings = av88HarrierUFC.ufc_left_position
        if ufcLeftStrings == nil then 
            ufcLeftStrings = "  "
        end
        
        local ufcLeftString1 = string.sub(ufcLeftStrings, 1, 1)
        local ufcLeftString2 = string.sub(ufcLeftStrings, 2, 2)

        -- Cued Windows are any window with a ':' indicating the window is selected
        local selectedWindows = {}
        for _key, _val in pairs(av88HarrierODU) do
            if _val == ":" then 
                local windowPos = string.sub(_key, 12, 12)
                selectedWindowPositionString = tostring(windowPos)
                table.insert(selectedWindows, selectedWindowPositionString)
            end
        end

        -- Generate the required SimApp Pro values to "mock" the F18 UFC with AV88 values
        -- In theory, you could replace these with a custom value from another module, and have them appear on the DCS UFC
        return buildSimAppProUFCPayload({
            option1=av88HarrierODU.ODU_Option_1_Text,
            option2=av88HarrierODU.ODU_Option_2_Text,
            option3=av88HarrierODU.ODU_Option_3_Text,
            option4=av88HarrierODU.ODU_Option_4_Text,
            option5=av88HarrierODU.ODU_Option_5_Text,
            scratchPadNumbers=av88HarrierUFC.ufc_right_position,
            scratchPadString1=ufcLeftString1,
            scratchPadString2=ufcLeftString2,
            com1=av88HarrierUFC.ufc_chnl_1_m,
            com2=av88HarrierUFC.ufc_chnl_2_m,
            selectedWindows=selectedWindows
        })
    end
end

-- Shows static data for the A10 UFC
local generateUFCDataForA10CII = function()
    -- Only send once for static data. Avoids spamming messages when data never changes
    -- See Huey Example for a time throttle message
    -- See Harrier Example for a DCS Value change throttle example
    if a10CHasExported then
        return nil
    else
        a10CHasExported = true
    end

    --Example off setting the 5 option display windows to static values.
    return buildSimAppProUFCPayload({
        option1="FUNC",
        option2="HACK",
        option3="LTR",
        option4="MK",
        option5="ALT",
    })
end

function ufcPatch.getUFCPayloadByModuleType(moduleName)
    if moduleName == 'AV8BNA' then
        return generateUFCDataForAV88()
    elseif moduleName == "UH-1H" then
        return generateUFCDataForHuey()
    elseif moduleName == "A-10C_2" then
        return generateUFCDataForA10CII()
    end
end

return ufcPatch