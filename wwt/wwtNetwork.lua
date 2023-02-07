w_net={}
package.path  = package.path..";.\\LuaSocket\\?.lua"
package.cpath = package.cpath..";.\\LuaSocket\\?.dll"
--全局变量
w_net.socket={}
w_net.net = {}
w_net.json=loadfile("Scripts\\JSON.lua")()
w_net.addr={
	{ip="127.0.0.1",port=16536},
	-- {ip="127.0.0.1",port=16537}
}
--module开始
function w_net.start()
	w_net.socket=require("socket")
	w_net.net = w_net.socket.udp()
	w_net.net:setsockname("*", 0)
	w_net.net:setoption('broadcast', true)
	w_net.net:settimeout(0)
end

--module发送
function w_net.send(msg)
	for i,_addr in pairs(w_net.addr) do
		w_net.socket.try(w_net.net:sendto(w_net.json:encode(msg),_addr.ip,_addr.port))
	end
end

--module接收
function w_net.get()
	local _msg=w_net.net:receive()
	local _table={}
	if type(_msg)=="string" and #_msg>0 then
		_table=w_net.json:decode(_msg)
		if type(_table)=="table" then
			return _table
		else
			return {}
		end
	else
		return {}
	end
end

--module结束
function w_net.stop()
	--关闭socket
	w_net.net:close()
end

return w_net