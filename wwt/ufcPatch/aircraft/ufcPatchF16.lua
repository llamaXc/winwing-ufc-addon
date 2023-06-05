local ufcUtils = require("ufcPatch\\utilities\\ufcPatchUtils")

ufcPatchF16 = {}

ufcPatchF16.startTime = os.time()

function ufcPatchF16.generateUFCData()
    if os.time() - ufcPatchF16.startTime < 15 then
        return
    end

    local MainPanel = GetDevice(0)
    local HUD = ufcUtils.getDCSListIndication(1)
    local expendableReadout = ufcUtils.getDCSListIndication(16)

    -- Altimeter AAU-34/A
    local HUD_Altitude_num_k = HUD.HUD_Altitude_num_k or 0
    local HUD_Altitude_num = HUD.HUD_Altitude_num or 0
    local HUD_BARO = (HUD_Altitude_num_k * 1000) + HUD_Altitude_num

    local Altimeter_100_footCount = GetDevice(0):get_argument_value(54)
    local Altimeter_1000_footCount = GetDevice(0):get_argument_value(53)
    local Altimeter_10000_footCount = GetDevice(0):get_argument_value(52)
    local BACKUP_BARO = Altimeter_10000_footCount * 10000 + Altimeter_1000_footCount * 1000 + Altimeter_100_footCount * 100

    local BARO_ALT = ""
    if HUD_BARO ~= 0 then
        BARO_ALT = string.format('%02dK%01d%01d', math.floor(HUD_BARO / 1000), math.floor((HUD_BARO % 1000) / 100), 0)
    elseif BACKUP_BARO ~= 0 then
        BARO_ALT = string.format('%02dK%01d%01d', math.floor(BACKUP_BARO / 100), math.floor((BACKUP_BARO % 1000) / 10), 0)
    elseif LoGetAltitudeAboveSeaLevel then
        local success, ALT_ASL = pcall(LoGetAltitudeAboveSeaLevel)
        if success then
            BARO_ALT = string.format('%02dK%01d%01d', math.floor(ALT_ASL / 1000), math.floor((ALT_ASL % 1000) / 100), 0)
        else
            BARO_ALT = "BALT"
        end
    else
        BARO_ALT = "BALT"
    end

    -- Velocity Mnemonic and Numerics
    local HUD_Window2_VelScaleMnemonic = HUD.HUD_Window2_VelScaleMnemonic or "V"
    local HUD_Velocity_num = HUD.HUD_Velocity_num or 0
    local TAS = LoGetTrueAirSpeed()

    local Velocity = HUD_Window2_VelScaleMnemonic .. string.format('%03d', HUD_Velocity_num)
    if Velocity == HUD_Window2_VelScaleMnemonic then
        Velocity = string.format('T%.0f', TAS)
    end

    if Velocity == HUD_Window2_VelScaleMnemonic and TAS == 0 then
        Velocity = "VELO"
    end

    -- Fuel Totaliser
    local FuelTotalizer_10k = MainPanel:get_argument_value(730)
    local FuelTotalizer_1k = MainPanel:get_argument_value(731)
    local FuelTotalizer_100 = MainPanel:get_argument_value(732)
    local fuelPercentage = math.floor(FuelTotalizer_10k * 10000 + FuelTotalizer_1k * 1000 + FuelTotalizer_100 * 100)

    -- FLARES AND CHAFF, display the final two digits
    local flareCount = expendableReadout and expendableReadout.CMDS_FL_Amount or 0
    local chaffCount = expendableReadout and expendableReadout.CMDS_CH_Amount or 0

    local FLARES, CHAFF = "", ""
    if type(flareCount) == "string" then
        FLARES = string.sub(flareCount, -2)
    elseif type(flareCount) == "number" then
        FLARES = string.sub(string.format('%04d', flareCount), 3)
    end

    if type(chaffCount) == "string" then
        CHAFF = string.sub(chaffCount, -2)
    elseif type(chaffCount) == "number" then
        CHAFF = string.sub(string.format('%04d', chaffCount), 3)
    end

    return ufcUtils.buildSimAppProUFCPayload({
        option1=Velocity,
        option2=BARO_ALT,
        option3="H" .. string.format('%.0f', ((LoGetMagneticYaw() * 180 / math.pi) + 360) % 360),
        option4="V" .. string.format('%.0f', LoGetVerticalVelocity() * 0.3048 * 10),
        option5="F" .. string.format('%03d', fuelPercentage),
        scratchPadNumbers=HUD.HUD_Window14_StpTgtData_RangeNum,
        scratchPadString1="S",
        scratchPadString2="P",
        com1=CHAFF,
        com2=FLARES,
        selectedWindows={}
    })
end

return ufcPatchF16
