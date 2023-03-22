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
local ufcPatchUH60 = require("ufcPatch\\aircraft\\ufcPatchUH60")
local ufcPatchMH60R = require("ufcPatch\\aircraft\\ufcPatchMH60R")
local ufcPatchMI8 = require("ufcPatch\\aircraft\\ufcPatchMI8")
local ufcPatchMI24 = require("ufcPatch\\aircraft\\ufcPatchMI24")
local ufcPatchKA50 = require("ufcPatch\\aircraft\\ufcPatchKA50")
local ufcPatchJF17 = require("ufcPatch\\aircraft\\ufcPatchJF17")

-- Add new module names here, then create a supporting lua file for the aircraft
-- See aircraft/ufcPatchCustomModuleExample.lua for an example.
-- There are various rates you can export UFC data at.
-- Time throttled: Exports every 0.2 seconds (UH-1H, MI8, MI24, UH60, MH60)
-- Static export: Exports a single time at mission start (A10-C2, CustomModuleExample)
-- Normal export: Exports anytime new data is available (AV88)
function ufcPatch.generateUFCExport(deltaTime, moduleName)
    ufcExportClock.tick(deltaTime)

    -- UH-1H sends throttled data every 0.2 seconds
    if moduleName == "UH-1H" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchHuey.generateUFCData()
        end

    -- A-10C_2 sends throttled data every 0.2 seconds
    elseif moduleName == "A-10C_2" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchA10C2.generateUFCData()
        end
		
    -- A-10C sends throttled data every 0.2 seconds
    elseif moduleName == "A-10C" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchA10C2.generateUFCData()
        end

    -- AV8BNA sends ODU information when latest is available
    elseif moduleName == 'AV8BNA' then
        return ufcPatchAV88.generateUFCData()

    -- BS3 sends information when latest is available
    elseif moduleName == 'Ka-50_3' then
        return ufcPatchKA50.generateUFCData()

    -- BS2 sends information when latest is available
    elseif moduleName == 'Ka-50' then
        return ufcPatchKA50.generateUFCData()

    -- CustomModuleExample sends static data once
    elseif moduleName =="CustomModuleExample" then
        if ufcExportClock.canExportStaticData then
            return ufcPatchCustomModuleExample.generateUFCData()
        end

    --UH-60L sends throttled data every 0.2 seconds
	elseif moduleName == "UH-60L" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchUH60.generateUFCData()
        end

	--MH-60R sends throttled data every 0.2 seconds
	elseif moduleName == "MH-60R" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchMH60R.generateUFCData()
        end

	--Mi-8 sends throttled data every 0.2 seconds
	elseif moduleName == "Mi-8MT" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchMI8.generateUFCData()
        end

	--Mi-24 sends throttled data every 0.2 seconds
	elseif moduleName == "Mi-24P" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchMI24.generateUFCData()
        end
		
    	-- JF-17 sends throttled data every 0.2 seconds
    	elseif moduleName == "JF-17" then
		if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchJF17.generateUFCData()
	end
    end
end

return ufcPatch
