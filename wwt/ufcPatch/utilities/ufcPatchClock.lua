ufcPatchExportClock = {}
ufcPatchExportClock.canTransmitLatestPayload = true
ufcPatchExportClock.canExportStaticData = true

-- Local variables
local updateInterval = 0.2 -- update delay interval. units = seconds
local currentTimestamp = 0 -- seconds
local staticExportCount = 0

function ufcPatchExportClock.tick(deltaTime)

    -- Track time for throttled payloads
    currentTimestamp = currentTimestamp + deltaTime
    if currentTimestamp > updateInterval then
        currentTimestamp = 0
        ufcPatchExportClock.canTransmitLatestPayload = true
    else
        ufcPatchExportClock.canTransmitLatestPayload = false
    end

    -- Detect if static data can go out on the first tick
    if ufcPatchExportClock.canExportStaticData and staticExportCount > 1 then
        ufcPatchExportClock.canExportStaticData = false
    elseif ufcPatchExportClock.canExportStaticData then
        staticExportCount = staticExportCount + 1
    end

end

return ufcPatchExportClock