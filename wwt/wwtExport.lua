-- 新增外部库地址
g_lfs = require('lfs')
package.path = package.path .. ";" .. g_lfs.writedir() .. "Scripts\\wwt\\?.lua"
package.cpath = package.cpath .. ";" .. g_lfs.writedir() .. "Scripts\\wwt\\?.dll"
-- 版本
g_wwtVersion = "2.0.1"
-- 定义dcs export函数
do
    -- 初始化
    if g_wwtInit == nil then
        g_wwtInit = true
        -- 声明
        local _wwt = {}
        _wwt.selfData = {}
        _wwt.mission = nil
        _wwt.mod = nil
        _wwt.output = {}
        _wwt.specifiedMod = {}
        _wwt.common = {}
        _wwt.commonMod = {}
        _wwt.commonModLastSendTime = {}
        _wwt.clock = 0
        _wwt.delay = 1.0
        _wwt.interval = 0.03
        _wwt.lastHeartbeatTime = 0
        _wwt.heartbeatInterval = 3
        _wwt.json = loadfile("Scripts\\JSON.lua")()
        local _dev = nil
        local _devVal = nil
        local _key = nil
        local _val = nil
        -- 加载网络库
        _wwt.net = require("wwtNetwork")
        -- 启动网络
        _wwt.net.start()
		
		-- [MOD PART 1] Load UFC Patch Mod
        _wwt.ufcPatch = require("ufcPatch//ufcPatch")
		
        -- 网络就绪
        local _send = {}
        _send["func"] = "net"
        _send["msg"] = "ready"
        _wwt.net.send(_send)
        do
            -- 定义函数
            _wwt.LuaExportStart = function()
                -- 记录日志
                log.write("WWT", log.INFO, "Export start!")
                -- 任务就绪
                local _send = {}
                _send["func"] = "mission"
                _send["msg"] = "ready"
                _wwt.net.send(_send)
            end

            _wwt.LuaExportBeforeNextFrame = function()
                -- 接收数据
                _wwt.getNet(_wwt.clock)
            end

            _wwt.equal2 = function(a, b, precision)
                a = tonumber(a) or 0
                b = tonumber(b) or 0
                precision = tonumber(precision) or 0
                return math.abs(a - b) < (1 / 10 ^ precision)
            end

            _wwt.getNet = function(t)
                -- 接受网络数据并处理
                local getCountMax = 1024
                local getCount = 0
                while getCount < getCountMax do
                    getCount = getCount + 1
                    local _get = _wwt.net.get()
                    if type(_get) == "table" and _wwt.mod ~= nil then
                        -- [MOD PART 2] Intercept lighting if Mod is active
                        if _wwt.ufcPatch.overrideLights == false and _get["func"] == "addOutput" then
                            -- 遍历数据并添加
                            for _dev, _devVal in pairs(_get["args"]) do
                                for _key, _valOld in pairs(_devVal) do
                                    if type(_wwt.output[_dev]) ~= "table" then
                                        _wwt.output[_dev] = {}
                                    end
                                    _wwt.output[_dev][_key] = _valOld
                                end
                            end
                        elseif _get["func"] == "getOutput" then -- 获取输出（仅一次）
                            -- 遍历数据并回应
                            local _send = {}
                            _send["func"] = _get["func"]
                            for _dev, _devVal in pairs(_get["args"]) do
                                GetDevice(_dev):update_arguments()
                                for _key, _valOld in pairs(_devVal) do
                                    local _valNew = GetDevice(_dev):get_argument_value(_key)
                                    if type(_send["args"]) ~= 'table' then
                                        _send["args"] = {}
                                    end
                                    if type(_send["args"][_dev]) ~= 'table' then
                                        _send["args"][_dev] = {}
                                    end
                                    _send["args"][_dev][_key] = _valNew
                                end
                            end
                            _wwt.net.send(_send)
                        elseif _get["func"] == "clearOutput" then -- 清空输出
                            _wwt.output = {}
                            local _send = {}
                            _send["func"] = "clearOutput"
                            _wwt.net.send(_send)
                        elseif _get["func"] == "addCommon" then -- 添加公共接口（变化输出）
                            -- 遍历数据并添加
                            for _key, _arg in pairs(_get["args"]) do
                                _wwt.common[_key] = {}
                                _wwt.common[_key]["identifyMethod"] = _arg
                                _wwt.common[_key]["value"] = nil
                            end
                        elseif _get["func"] == "getCommon" then -- 获取公共接口（仅一次）
                            -- 遍历数据并回应
                            local _send = {}
                            _send["func"] = _get["func"]
                            for _key, _msg in pairs(_get["args"]) do
                                local _func, _err = loadstring(_msg)
                                if _func then
                                    local _status, _result = pcall(_func)
                                    local _send = {}
                                    _send["args"][_key] = _result
                                else
                                    local _send = {}
                                    _send["args"][_key] = tostring(_err)
                                end
                            end
                            _wwt.net.send(_send)
                        elseif _get["func"] == "clearCommon" then -- 清空公共接口
                            _wwt.commonMod = {}
                            local _send = {}
                            _send["func"] = "clearCommon"
                            _wwt.net.send(_send)
                        elseif _get["func"] == "addSpecifiedMod" then
                            for _dev, _devVal in pairs(_get["args"]) do
                                if type(_wwt.specifiedMod[_dev]) ~= "table" then
                                    _wwt.specifiedMod[_dev] = {}
                                    for _key, _arg in pairs(_devVal) do
                                        _wwt.specifiedMod[_dev][_key] = {}
                                        _wwt.specifiedMod[_dev][_key]["value"] = nil
                                        _wwt.specifiedMod[_dev][_key]["period"] = tonumber(_arg["period"]) or
                                                                                      _wwt.interval
                                        _wwt.specifiedMod[_dev][_key]["ot"] = nil
                                        _wwt.specifiedMod[_dev][_key]["precision"] = tonumber(_arg["precision"]) or nil

                                    end
                                end
                            end
                        elseif _get["func"] == "clearSpecifiedMod" then
                            _wwt.specifiedMod = {}
                            local _send = {}
                            _send["func"] = "clearSpecifiedMod"
                            _wwt.net.send(_send)
                        elseif _get["func"] == "addCommonMod" then
                            for _key, _arg in pairs(_get["args"]) do
                                if type(_wwt.commonMod[_key]) ~= 'table' then
                                    _wwt.commonMod[_key] = {}
                                end
                                _wwt.commonMod[_key]["identifyMethod"] = _arg["identifyMethod"]
                                _wwt.commonMod[_key]["period"] = tonumber(_arg["period"]) or 0
                                _wwt.commonMod[_key]["value"] = nil
                                _wwt.commonMod[_key]["ot"] = nil
                                _wwt.commonMod[_key]["precision"] = tonumber(_arg["precision"]) or nil
                            end
                        elseif _get["func"] == "clearCommonMod" then
                            _wwt.commonMod = {}
                            local _send = {}
                            _send["func"] = "clearCommonMod"
                            _wwt.net.send(_send)
                        elseif _get["func"] == "original" then -- 原始接口
                            local _func, _err = loadstring(_get["msg"])
                            if _func then
                                local _status, _result = pcall(_func)
                                local _send = {}
                                _send["func"] = _get["func"]
                                _send["status"] = _status
                                _send["msg"] = _result
                                _send["timestamp"] = t
                                _wwt.net.send(_send)
                            else
                                local _send = {}
                                _send["func"] = _get["func"]
                                _send["status"] = false
                                _send["msg"] = tostring(_err)
                                _send["timestamp"] = t
                                _wwt.net.send(_send)
                            end
                        elseif _get["func"] == "setInput" then -- 设置输入
                            -- 遍历数据并触发
                            for _dev, _devVal in pairs(_get["args"]) do
                                for _key, _val in pairs(_devVal) do
                                    local dev = GetDevice(_dev)
                                    if dev.performClickableAction ~= nil then
                                        dev:performClickableAction(_key, _val)
                                    end
                                end
                            end
                        elseif _get["func"] == "setCommand" then -- 设置command
                            -- 遍历数据并触发
                            for _cmd, _cmdVal in pairs(_get["args"]) do
                                if LoSetCommand ~= nil then
                                    LoSetCommand(_cmd, _cmdVal)
                                end
                            end
                        end
                    else
                        break
                    end
                end
            end

            _wwt.sendNet = function(t)
                -- 任务开始（仅一次）
                if _wwt.mission == nil then
                    _wwt.mission = true
                    local _send = {}
                    _send["func"] = "mission"
                    _send["msg"] = "start"
                    _wwt.net.send(_send)
                end
                -- 获取机型
                local _self = LoGetSelfData()
                if _self ~= nil then
                    if _wwt.mod ~= _self.Name then
                        -- 记录机型
                        log.write("WWT", log.INFO, _self.Name)
                        _wwt.mod = _self.Name
                        local _send = {}
                        _send["func"] = "mod"
                        _send["msg"] = _self.Name
						
						-- [MOD PART 3] Spoof module detection to load the layout
                        if _wwt.ufcPatch.useCustomUFC then
                            -- Support Super Bugs
                            if _self.Name == "FA-18E" or _self.Name == "FA-18F" then _self.Name = "FA-18C_hornet" end
                            
                            local isF18 = _self.Name == 'FA-18C_hornet'
                            local isF16 = _self.Name == 'F-16C_50'
                            
                            if not isF18 and not isF16 then
                                -- Enable Mod for non-F18/16 planes
                                _wwt.ufcPatch.useCustomUFC = true
                                _send["msg"] = "FA-18C_hornet" 
                            else
                                -- DISABLE Mod natively if F-18 or F-16 is detected (Protects default functionality)
                                _wwt.ufcPatch.useCustomUFC = false
                                _wwt.ufcPatch.overrideLights = false
                            end
                        end
						
                        _wwt.net.send(_send)
                    end
                end
                -- 心跳
                if t - _wwt.lastHeartbeatTime > _wwt.heartbeatInterval then
                    _wwt.lastHeartbeatTime = t
                    local _send = {}
                    _send["func"] = "heartbeat"
                    _send["msg"] = _wwt.lastHeartbeatTime
                    _wwt.net.send(_send)
                end
                -- 发送之前添加的输出数据（变化发送）
                local _sendOutput = {}
                _sendOutput["func"] = "addOutput"
                _sendOutput["timestamp"] = t
                for _dev, _devVal in pairs(_wwt.output) do
                    if GetDevice(_dev) == nill or type(GetDevice(_dev)) ~= 'table' then
                        break
                    end
                    GetDevice(_dev):update_arguments()
                    for _key, _valOld in pairs(_devVal) do
                        local _valNew = GetDevice(_dev):get_argument_value(_key)
                        if _valNew ~= _valOld then
                            _wwt.output[_dev][_key] = _valNew
                            if type(_sendOutput["args"]) ~= 'table' then
                                _sendOutput["args"] = {}
                            end
                            if type(_sendOutput["args"][_dev]) ~= 'table' then
                                _sendOutput["args"][_dev] = {}
                            end
                            _sendOutput["args"][_dev][_key] = _valNew
                        end
                    end
                end
                if _sendOutput["args"] ~= nil then
                    _wwt.net.send(_sendOutput)
                end
				
				-- [MOD PART 4] Generate custom payload to send to SimApp Pro
                if _wwt.ufcPatch.useCustomUFC then
                    local success, ufcPayload = pcall(function() return _wwt.ufcPatch.generateUFCExport(_wwt.interval, _wwt.mod) end)
                    local lightSuccess, lightPayload = pcall(function() return _wwt.ufcPatch.generateLightExport(_wwt.interval, _wwt.mod) end)
                    
                    if success and lightSuccess and ufcPayload ~= nil and ufcPayload ~= _wwt.ufcPatch.prevUFCPayload then
                        _wwt.ufcPatch.prevUFCPayload = ufcPayload
                        local ufcCommon = {}
                        ufcCommon["func"] = "addCommon"
                        ufcCommon["timestamp"] = t
                        ufcCommon["args"] = { ["FA-18C_hornet"] = ufcPayload }
                        _wwt.net.send(ufcCommon)
                    end

                    if _wwt.ufcPatch.overrideLights and lightPayload ~= nil and lightPayload ~= _wwt.ufcPatch.prevLightPayload then
                        _wwt.ufcPatch.prevLightPayload = lightPayload
                        local lightOutputMessage = {}
                        lightOutputMessage["func"] = "addOutput"
                        lightOutputMessage["args"] = { ["0"] = lightPayload }
                        _wwt.net.send(lightOutputMessage)
                    end
                end

                -- 发送之前添加的公共接口（变化发送）
                local _sendCommon = {}
                _sendCommon["func"] = "addCommon"
                _sendCommon["timestamp"] = t
                for _key, _arg in pairs(_wwt.common) do
                    local _func, _err = loadstring(_arg.identifyMethod)
                    if _func then
                        local _status, _result = pcall(_func)
                        if _wwt.json:encode(_result) ~= _wwt.json:encode(_arg.value) then
                            if type(_sendCommon["args"]) ~= 'table' then
                                _sendCommon["args"] = {}
                            end
                            _sendCommon["args"][_key] = _result
                            _arg.value = _result
                        end
                    else
                        if type(_sendCommon["args"]) ~= 'table' then
                            _sendCommon["args"] = {}
                        end
                        _sendCommon["args"][_key] = tostring(_err)
                    end
                end
                if _sendCommon["args"] ~= nil then
                    _wwt.net.send(_sendCommon)
                end
                -- 发送之前添加的指定模型的数据（变化发送）
                local _sendSpecifiedMod = {}
                _sendSpecifiedMod["func"] = "addSpecifiedMod"
                _sendSpecifiedMod["timestamp"] = t

                for _dev, _devVal in pairs(_wwt.specifiedMod) do
                    local dev = GetDevice(_dev)
                    if dev ~= nil and type(dev) == 'table' then
                        dev:update_arguments()
                        for _key, _val in pairs(_devVal) do
                            local _valOld = _val.value
                            local _fps = _wwt.specifiedMod[_dev][_key]["period"] or 0
                            local _precision = _wwt.specifiedMod[_dev][_key]["precision"]
                            local _period = _fps > 0 and (1 / _fps) or 1
                            local _lastSendTime = _wwt.specifiedMod[_dev][_key]["ot"] or 0

                            if (t - _lastSendTime) >= _period then
                                local _valNew = dev:get_argument_value(_key)
                                local _isEqual = true
                                if _precision then

                                    if not _wwt.equal2(_valNew, _valOld, _precision) then
                                        _isEqual = false
                                    end
                                else
                                    if _valNew ~= _valOld then
                                        _isEqual = false
                                    end
                                end
                                if not _isEqual then

                                    if type(_sendSpecifiedMod["args"]) ~= 'table' then
                                        _sendSpecifiedMod["args"] = {}
                                    end
                                    if type(_sendSpecifiedMod["args"][_dev]) ~= 'table' then
                                        _sendSpecifiedMod["args"][_dev] = {}
                                    end
                                    if type(_sendSpecifiedMod["args"][_dev][_key]) ~= 'table' then
                                        _sendSpecifiedMod["args"][_dev][_key] = {}
                                    end

                                    _sendSpecifiedMod["args"][_dev][_key]["value"] = _valNew
                                    _wwt.specifiedMod[_dev][_key]["value"] = _valNew
                                    _wwt.specifiedMod[_dev][_key]["ot"] = t
                                end
                            end
                        end
                    end
                end

                if _sendSpecifiedMod["args"] ~= nil then
                    _wwt.net.send(_sendSpecifiedMod)
                end
                -- 发送之前添加的通用模型的数据（变化发送）
                local _sendCommonMod = {}
                _sendCommonMod["func"] = "addCommonMod"
                _sendCommonMod["timestamp"] = t
                for _key, _arg in pairs(_wwt.commonMod) do
                    local _func, _err = loadstring(_arg.identifyMethod)
                    if _func then
                        local _status, _result = pcall(_func)
                        local _fps = _arg["period"] or 0
                        local _precision = _arg["precision"]
                        local _period = _fps > 0 and (1 / _fps) or 1
                        local _lastSendTime = _arg["ot"] or 0
                        if (t - _lastSendTime) >= _period then
                            local _isEqual = true
                            local _valNew = _result
                            local _valOld = _arg.value
                            if _precision then
                                if not _wwt.equal2(_valNew, _valOld, _precision) then
                                    _isEqual = false
                                end
                            else
                                if _wwt.json:encode(_valNew) ~= _wwt.json:encode(_valOld) then
                                    _isEqual = false
                                end
                            end
                            if not _isEqual then
                                if type(_sendCommonMod["args"]) ~= 'table' then
                                    _sendCommonMod["args"] = {}
                                end
                                _sendCommonMod["args"][_key] = _valNew
                                _arg.value = _valNew
                                _wwt.commonMod[_key]['ot'] = t
                            end
                        end
                    else
                        if type(_sendCommonMod["args"]) ~= 'table' then
                            _sendCommonMod["args"] = {}
                        end
                        _sendCommonMod["args"][_key] = tostring(_err)
                    end
                end
                if _sendCommonMod["args"] ~= nil then
                    _wwt.net.send(_sendCommonMod)
                end
            end

            _wwt.LuaExportActivityNextEvent = function(t)
                _wwt.clock = t + _wwt.interval
                -- 发送数据
                _wwt.sendNet(_wwt.clock)
                return _wwt.clock
            end

            _wwt.LuaExportStop = function()
                -- 任务结束,关闭网络
                local _send = {}
                _send["func"] = "mission"
                _send["msg"] = "stop"
                _wwt.net.send(_send)
                -- 清空缓存
                _wwt.output = nil
                _wwt.specifiedMod = nil
                _wwt.common = nil
                _wwt.commonMod = nil
                _wwt.commonModLastSendTime = nil
                -- 记录日志
                log.write("WWT", log.INFO, "Export stop!")
            end
            -- 记录其他的（第三方）export函数，方便之后在执行我们的函数后，执行第三方函数。
            _wwt.OtherLuaExportStart = LuaExportStart -- 开始函数
            _wwt.OtherLuaExportBeforeNextFrame = LuaExportBeforeNextFrame -- 输入数据到DCS内部,比如控制飞机的横滚
            _wwt.OtherLuaExportActivityNextEvent = LuaExportActivityNextEvent -- 输出数据到DCS外部,比如获取飞机的高度
            _wwt.OtherLuaExportStop = LuaExportStop -- 结束函数

            -- 定义dcs export函数
            LuaExportStart = function()
                _wwt.LuaExportStart()
                if _wwt.OtherLuaExportStart then
                    _wwt.OtherLuaExportStart()
                end
            end

            LuaExportBeforeNextFrame = function()
                _wwt.LuaExportBeforeNextFrame()
                if _wwt.OtherLuaExportBeforeNextFrame then
                    _wwt.OtherLuaExportBeforeNextFrame()
                end
            end

            LuaExportActivityNextEvent = function(t)
                t = _wwt.LuaExportActivityNextEvent(t)
                if _wwt.OtherLuaExportActivityNextEvent then
                    t = _wwt.OtherLuaExportActivityNextEvent(t)
                end
                return t
            end

            LuaExportStop = function()
                _wwt.LuaExportStop()
                if _wwt.OtherLuaExportStop then
                    _wwt.OtherLuaExportStop()
                end
            end
            log.write("WWT", log.INFO, "Wwt export installed!")
        end
    end
end
