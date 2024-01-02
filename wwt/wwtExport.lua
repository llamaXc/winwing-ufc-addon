-- 新增外部库地址
g_lfs=require('lfs')
package.path  = package.path..";"..g_lfs.writedir().."Scripts\\wwt\\?.lua"
package.cpath = package.cpath..";"..g_lfs.writedir().."Scripts\\wwt\\?.dll"
-- 定义dcs export函数
do
	--初始化
	if g_winwingInit==nil then
		g_winwingInit=true
		-- 声明
		local _winwing={}
		_winwing.selfData={}
		_winwing.mission=nil
		_winwing.mod=nil
		_winwing.output={}
		_winwing.common={}
		_winwing.clock=0
		_winwing.delay=1.0
		_winwing.interval=0.03
		local _dev=nil
		local _devVal=nil
		local _key=nil
		local _val=nil
		--加载网络库
		_winwing.net=require("wwtNetwork")
		--启动网络
		_winwing.net.start()

		-- Include UFC Patch files and initalize for universal UFC plugin
		_winwing.ufcPatch=require("ufcPatch//ufcPatch")

		--网络就绪
		local _send={}
		_send["func"]="net"
		_send["msg"]="ready"
		_winwing.net.send(_send)
		do
			--定义函数
			_winwing.LuaExportStart=function()
				--记录日志
				log.write("WWT",log.INFO,"Export start!")
				--任务就绪
				local _send={}
				_send["func"]="mission"
				_send["msg"]="ready"
				_winwing.net.send(_send)
			end
			
			_winwing.LuaExportBeforeNextFrame=function()
			end

			_winwing.getNet=function(t)
				--任务开始（仅一次）
				if _winwing.mission==nil then
					_winwing.mission=true
					local _send={}
					_send["func"]="mission"
					_send["msg"]="start"
					_winwing.net.send(_send)
				end
				--获取机型
				local _self=LoGetSelfData()
				if _self~=nil then
					if _winwing.mod~=_self.Name then
						--记录机型
						log.write("WWT",log.INFO,_self.Name)
						_winwing.mod=_self.Name
						local _send={}
						_send["func"]="mod"
						_send["msg"]=_self.Name

						-- Required to trick SimApp Pro into allowing UFC/Com/Scratch pad commands
						local isF18 = _self.Name == 'FA-18C_hornet'
						local isF16 = _self.Name == 'F-16C_50'
						-- To prevent Breaking the ICP, this mod will be disabled when flying the F18 or the F16
						if isF18 == false and isF16 == false then
							_winwing.ufcPatch.useCustomUFC = true
						end

						_winwing.net.send(_send)
					end
				end
				--接受网络数据并处理
				local _get=_winwing.net.get()
				if type(_get)=="table" and _winwing.mod~=nil then
					if _get["func"]=="addOutput" then--添加输出（变化输出）
						--遍历数据并添加
						for _dev,_devVal in pairs(_get["args"]) do
							for _key,_valOld in pairs(_devVal) do
								if type(_winwing.output[_dev])~="table" then
									_winwing.output[_dev]={}
								end
								_winwing.output[_dev][_key]=_valOld
							end
						end
					elseif _get["func"]=="getOutput" then--获取输出（仅一次）
						--遍历数据并回应
						local _send={}
						_send["func"]=_get["func"]
						for _dev,_devVal in pairs(_get["args"]) do
							GetDevice(_dev):update_arguments()
							for _key,_valOld in pairs(_devVal) do
								local _valNew=GetDevice(_dev):get_argument_value(_key)
								if type(_send["args"])~='table' then
									_send["args"]={}
								end
								if type(_send["args"][_dev])~='table' then
									_send["args"][_dev]={}
								end
								_send["args"][_dev][_key]=_valNew
							end
						end
						_winwing.net.send(_send)
					elseif _get["func"]=="clearOutput" then--清空输出
						_winwing.output={}
					elseif _get["func"]=="addCommon" then--添加公共接口（变化输出）
						--遍历数据并添加
						for _key,_arg in pairs(_get["args"]) do
							_winwing.common[_key]={}
							_winwing.common[_key]["identifyMethod"]=_arg
							_winwing.common[_key]["value"]=nil
						end
					elseif _get["func"]=="getCommon" then--获取公共接口（仅一次）
						--遍历数据并回应
						local _send={}
						_send["func"]=_get["func"]
						for _key,_msg in pairs(_get["args"]) do
							local _func,_err=loadstring(_msg)
							if _func then
								local _status,_result = pcall(_func)
								local _send={}
								_send["args"][_key]=_result
							else
								local _send={}
								_send["args"][_key]=tostring(_err)
							end
						end
						_winwing.net.send(_send)
					elseif _get["func"]=="clearCommon" then--清空公共接口
						_winwing.common={}
					elseif _get["func"]=="original" then--原始接口
						local _func,_err=loadstring(_get["msg"])
						if _func then
							local _status,_result = pcall(_func)
							local _send={}
							_send["func"]=_get["func"]
							_send["status"]=_status
							_send["msg"]=_result
							_winwing.net.send(_send)
						else
							local _send={}
							_send["func"]=_get["func"]
							_send["status"]=false
							_send["msg"]=tostring(_err)
							_winwing.net.send(_send)
						end
					elseif _get["func"]=="setInput" then--设置输入
						--遍历数据并触发
						for _dev,_devVal in pairs(_get["args"]) do
							for _key,_val in pairs(_devVal) do
								if _dev ~= nil then
									local dev=GetDevice(_dev)
									if dev ~= nil and dev.performClickableAction~= nil then
										dev:performClickableAction(_key,_val)
									end
								end
							end
						end
					end
				end
			end

			_winwing.sendNet=function(t)
				--发送之前添加的输出数据（变化发送）
				local _sendOutput={}
				_sendOutput["func"]="addOutput"
				_sendOutput["timestamp"]=t

				for _dev,_devVal in pairs(_winwing.output) do
					if type(GetDevice(_dev))~='table' then
						break
					end
					GetDevice(_dev):update_arguments()
					for _key,_valOld in pairs(_devVal) do
						local _valNew=GetDevice(_dev):get_argument_value(_key)
						if _valNew~=_valOld then
							_winwing.output[_dev][_key]=_valNew
							if type(_sendOutput["args"])~='table' then
								_sendOutput["args"]={}
							end
							if type(_sendOutput["args"][_dev])~='table' then
								_sendOutput["args"][_dev]={}
							end

							-- Force update LCD brightness to 80% for UFC
							-- Required since SimApp Pro expects datum id 109 to be the UFC brightness
							if _winwing.ufcPatch.useCustomUFC and _key == "109" then
								_sendOutput["args"]["0"] = {}
								_sendOutput["args"]["0"]["109"] = 0.9
							else
								_sendOutput["args"][_dev][_key]=_valNew
							end
						end
					end
				end

				if _sendOutput["args"]~=nil then
					_winwing.net.send(_sendOutput)
				end


				if _winwing.ufcPatch.useCustomUFC then

					-- Generate the payload to send to SimApp Pro
					local ufcPayload  = _winwing.ufcPatch.generateUFCExport(_winwing.interval, _winwing.mod)

					-- Detect new custom UFC values, then send to SimApp Pro
					if ufcPayload ~= nil and ufcPayload ~= _winwing.ufcPatch.prevUFCPayload then
						_winwing.ufcPatch.prevUFCPayload = ufcPayload
						local ufcCommon={}
						ufcCommon["func"]="addCommon"
						ufcCommon["timestamp"]=t
						ufcCommon["args"]={}
						-- Trick SimApp Pro into thinking we are using the F18 and F18 UFC
						-- But we pass in the custom UFC values.
						ufcCommon["args"]["FA-18C_hornet"] = ufcPayload
						_winwing.net.send(ufcCommon)
					end
				end

				--发送之前添加的公共接口（变化发送）
				local _sendCommon={}
				_sendCommon["func"]="addCommon"
				_sendCommon["timestamp"]=t
				for _key,_arg in pairs(_winwing.common) do
					local _func,_err=loadstring(_arg.identifyMethod)
					if _func then
						local _status,_result = pcall(_func)
						if _result~=_arg.value then
							if type(_sendCommon["args"])~='table' then
								_sendCommon["args"]={}
							end
							_sendCommon["args"][_key]=_result
							_arg.value=_result
						end
					else
						if type(_sendCommon["args"])~='table' then
							_sendCommon["args"]={}
						end
						_sendCommon["args"][_key]=tostring(_err)
					end
				end
				if _sendCommon["args"]~=nil then
					_winwing.net.send(_sendCommon)
				end
			end

			_winwing.LuaExportActivityNextEvent=function(t)
				_winwing.clock=t+_winwing.interval
				--接收数据
				_winwing.getNet(_winwing.clock)
				--发送数据
				_winwing.sendNet(_winwing.clock)
				return _winwing.clock
			end
			
			_winwing.LuaExportStop=function()
				--任务结束,关闭网络
				local _send={}
				_send["func"]="mission"
				_send["msg"]="stop"
				_winwing.net.send(_send)
				--清空缓存
				_winwing.output=nil
				_winwing.common=nil
				--记录日志
				log.write("WWT",log.INFO,"Export stop!")
			end
			--记录其他的（第三方）export函数，方便之后在执行我们的函数后，执行第三方函数。
			_winwing.OtherLuaExportStart=LuaExportStart								--开始函数
			_winwing.OtherLuaExportBeforeNextFrame=LuaExportBeforeNextFrame			--输入数据到DCS内部,比如控制飞机的横滚
			_winwing.OtherLuaExportActivityNextEvent=LuaExportActivityNextEvent		--输出数据到DCS外部,比如获取飞机的高度
			_winwing.OtherLuaExportStop=LuaExportStop								--结束函数
			
			--定义dcs export函数
			LuaExportStart=function()
				_winwing.LuaExportStart()
				if _winwing.OtherLuaExportStart then
					_winwing.OtherLuaExportStart()
				end
			end
			
			LuaExportBeforeNextFrame=function()
				_winwing.LuaExportBeforeNextFrame()
				if _winwing.OtherLuaExportBeforeNextFrame then
					_winwing.OtherLuaExportBeforeNextFrame()
				end
			end
			
			LuaExportActivityNextEvent=function(t)
				t=_winwing.LuaExportActivityNextEvent(t)
				if _winwing.OtherLuaExportActivityNextEvent then
					t=_winwing.OtherLuaExportActivityNextEvent(t)
				end
				return t
			end
			
			LuaExportStop=function()
				_winwing.LuaExportStop()
				if _winwing.OtherLuaExportStop then
					_winwing.OtherLuaExportStop()
				end
			end
			log.write("WWT",log.INFO,"Winwing export installed!")
		end
	end
end