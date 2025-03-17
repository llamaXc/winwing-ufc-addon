ufcPatch={}

ufcPatch.prevUFCPayload = nil
ufcPatch.prevLightPayload = nil

-- Controls if the mod is enabled or not. Set this false if you want to stop using the mod
ufcPatch.useCustomUFC = true

-- If lights are not working well, you can disable this value to stop the new feature. 
ufcPatch.overrideLights = true

-- Utils
local ufcExportClock = require("ufcPatch\\utilities\\ufcPatchClock")
local lightsHelper = require("ufcPatch\\utilities\\wwLights")
local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

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
local ufcPatchTF51D = require("ufcPatch\\aircraft\\ufcPatchTF51D")
local ufcPatchA4 = require("ufcPatch\\aircraft\\ufcPatchA4")
local ufcPatchAH64 = require("ufcPatch\\aircraft\\ufcPatchAH64")
local ufcPatchF16 = require("ufcPatch\\aircraft\\ufcPatchF16")
local ufcPatchF15e = require("ufcPatch\\aircraft\\ufcPatchF15e")
local ufcPatchPHANTOM = require("ufcPatch\\aircraft\\ufcPatchPHANTOM")
local ufcPatchT45 = require("ufcPatch\\aircraft\\ufcPatchT45")
local ufcPatchOV10 = require("ufcPatch\\aircraft\\ufcPatchOV10")
local ufcPatchAH6J = require("ufcPatch\\aircraft\\ufcPatchAH6J")
local ufcPatchSK60 = require("ufcPatch\\aircraft\\ufcPatchSK60")
local ufcPatchOH58D = require("ufcPatch\\aircraft\\ufcPatchOH58D")
local ufcPatchCH47F = require("ufcPatch\\aircraft\\ufcPatchCH47F")
local ufcPatchGeneral = require("ufcPatch\\aircraft\\ufcPatchGeneral")
---------------------------------------

-- Common light settings for all modules to use
function ufcPatch.getCommonLightData()
    return {
        [lightsHelper.UFC_BRIGHTNESS] = 0.9
    }
end

-- Light Data to control WinWing Panel Lights
function ufcPatch.generateLightExport(deltaTime, moduleName)
    local lightData = ufcPatch.getCommonLightData()
    local moduleLightData = {}

    -- First time reset all lights
    if ufcPatch.prevLightPayload == nil then
        return {
            [lightsHelper.UFC_BRIGHTNESS] = 0.9,
            [lightsHelper.AA] = 0,
            [lightsHelper.AG] = 0,
            [lightsHelper.JETTISON_CTR] = 0,
            [lightsHelper.JETTISON_LI] = 0,
            [lightsHelper.JETTISON_LO] = 0,
            [lightsHelper.JETTISON_RI] = 0,
            [lightsHelper.JETTISON_RO] = 0,
            [lightsHelper.LANDING_GEAR_HANDLE] = 0,
            [lightsHelper.APU_READY] = 0,
            [lightsHelper.ALR_POWER] = 0,
        }
    end

    -- Override with module-specific data if available
    if moduleName == "UH-1H" then
        moduleLightData = ufcPatchHuey.generateLightData()
    -- elseif moduleName == "TODO_NEW_MODULE" then 
    --     moduleLightData = ufcPatchModuleName.generateLightData()
	elseif moduleName == "Mi-8MT" then
		moduleLightData = ufcPatchMI8.generateLightData()

	elseif moduleName == "Mi-24P" then
		moduleLightData = ufcPatchMI24.generateLightData()

	elseif moduleName == "CH-47Fbl1" then
		moduleLightData = ufcPatchCH47F.generateLightData()
		
	elseif moduleName == "UH-60L" then
		moduleLightData = ufcPatchUH60.generateLightData()
		
	elseif moduleName == "MH-60R" then
		moduleLightData = ufcPatchMH60R.generateLightData()
		
	elseif moduleName == "AH-64D_BLK_II" then
		moduleLightData = ufcPatchAH64.generateLightData()
		
	elseif moduleName == "OH58D" then
		moduleLightData = ufcPatchOH58D.generateLightData()
		
	elseif moduleName == "JF-17" then
		moduleLightData = ufcPatchJF17.generateLightData()	

	elseif moduleName == "A-4E-C" then
		moduleLightData = ufcPatchA4.generateLightData()	
		
    end

    -- Merge in module data to common light payload
    for key, value in pairs(moduleLightData) do
        lightData[key] = value
    end

    return lightData
end


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

    --A4 sends throttled data every 0.2 seconds
    elseif moduleName == "A-4E-C" then
       if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchA4.generateUFCData()
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

    -- AH-64D_BLK_II sends information when latest is available
    elseif moduleName == 'AH-64D_BLK_II' then
        return ufcPatchAH64.generateUFCData()

    -- F-16C_50 sends information when latest is available
    -- WARNING: The F-16C ufc patch addon will no longer work. This is due to SimApp Pro and the new F16 ICP causing issues.
    -- For now, this will be disabled
    elseif moduleName == 'F-16C_50' then
        return ufcPatchF16.generateUFCData()

    -- F-15e sends information when latest is available
    elseif moduleName == 'F-15ESE' then
        return ufcPatchF15e.generateUFCData()

    -- AV8BNA sends ODU information when latest is available
    elseif moduleName == 'AV8BNA' then
        return ufcPatchAV88.generateUFCData()

    -- BS3 sends information when latest is available
    elseif moduleName == 'Ka-50_3' then
        return ufcPatchKA50.generateUFCData()

    -- BS2 sends information when latest is available
    elseif moduleName == 'Ka-50' then
        return ufcPatchKA50.generateUFCData()

    elseif moduleName == "F-4E-45MC" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchPHANTOM.generateUFCData()
        end

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

    -- JF-17 sends throttled data every 0.2 seconds
    elseif moduleName == "JF-17" then
		if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchJF17.generateUFCData()
        end

    -- TF-51D sends throttled data every 0.2 seconds
    elseif moduleName == "TF-51D" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchTF51D.generateUFCData()
        end

	--Mi-24 sends throttled data every 0.2 seconds
	elseif moduleName == "Mi-24P" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchMI24.generateUFCData()
        end
    -- T-45 sends throttled data every 0.2 seconds
    elseif moduleName == "T-45" then
        if ufcExportClock.canTransmitLatestPayload then
                return ufcPatchT45.generateUFCData()
        end

    -- A-29B Mod sends latest data
    elseif moduleName == "A-29B" then
        return ufcPatchA29B.generateUFCData()

     -- Hercules Mod sends throttled data every 0.2 seconds
    elseif moduleName == "Hercules" then
        if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchHerc.generateUFCData()
	    end

	 -- OV-10A Bronco Mod sends throttled data every 0.2 seconds
    elseif moduleName == "Bronco-OV-10A" then
		if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchOV10.generateUFCData()
		end

	-- AH-6Mod sends throttled data every 0.2 seconds
    elseif moduleName == "AH-6" then
		if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchAH6J.generateUFCData()
		end	

	-- SK-60 mod sends throttled data every 0.2 seconds
    elseif moduleName == "SK-60" then
		if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchSK60.generateUFCData()
		end	

	--OH-58D sends throttled data every 0.2 seconds
    elseif moduleName == "OH58D" then
		if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchOH58D.generateUFCData()
		end
		
		--CH-47F sends throttled data every 0.2 seconds
    elseif moduleName == "CH-47Fbl1" then
		if ufcExportClock.canTransmitLatestPayload then
            return ufcPatchCH47F.generateUFCData()
		end
		
     --General Profile sends throttled data (THIS MUST ALWAYS BE LAST IN THE LIST)
    elseif moduleName ~= "FA-18C_hornet" then
        if ufcExportClock.canTransmitLatestPayload then
                return ufcPatchGeneral.generateUFCData()
        end
    end
end

return ufcPatch
