ufcPatch={}

ufcPatch.prevUFCPayload = nil
ufcPatch.useCustomUFC = false

-- Clock module
local ufcExportClock = require("ufcPatch\\utilities\\ufcPatchClock")

-- Import supported modules
local ufcPatchHuey = require("ufcPatch\\aircraft\\ufcPatchHuey")
local ufcPatchA10C2 = require("ufcPatch\\aircraft\\ufcPatchA10C2")
local ufcPatchAV88 = require("ufcPatch\\aircraft\\ufcPatchAV88")
local ufcPatchCustomModuleExample = require("ufcPatch\\aircraft\\ufcPatchCustomModuleExample")

-- Add new module names here, then create a supporting lua file for the aircraft
-- See aircraft/ufcPatchCustomModuleExample.lua for an example.
-- There are various rates you can export UFC data at.
-- Time throttled: Exports every 0.2 seconds (UH-1H)
-- Static export: Exports a single time at mission start (A10-C2)
-- Normal export: Exports anytime new data is available (AV88)
function ufcPatch.generateUFCExport(deltaTime, moduleName)
    ufcExportClock.tick(deltaTime)

    -- UH-1H sends throttled data every 0.2 seconds
    if moduleName == "UH-1H" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchHuey.generateUFCData()
        end

    -- A-10C_2 sends static data once
    elseif moduleName == "A-10C_2" then
        if ufcExportClock.canExportStaticData then
            return ufcPatchA10C2.generateUFCData()
        end

    -- AV8BNA sends ODU information when latest is available
    elseif moduleName == 'AV8BNA' then
        return ufcPatchAV88.generateUFCData()

    -- CustomModuleExample sends static data once
    elseif moduleName =="CustomModuleExample" then
        if ufcExportClock.canExportStaticData then
            return ufcPatchCustomModuleExample.generateUFCData()
        end
    end
end

return ufcPatch
