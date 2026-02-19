local loginRateLimit = {}
local LOGIN_RATE_LIMIT_MS = 1000

local function checkLoginRateLimit(player)
    local now = getTickCount()
    if (now - (loginRateLimit[player] or 0)) < LOGIN_RATE_LIMIT_MS then
        return false
    end
    loginRateLimit[player] = now
    return true
end

addEventHandler("onPlayerQuit", root, function()
    loginRateLimit[source] = nil
end)

addEvent("onAccountTryLogin",true)
addEventHandler("onAccountTryLogin",root,function (username,password)
    if not checkLoginRateLimit(client) then return end
	local class = Account.getInstance()
	if(class:login(client,username,password)) then
		triggerClientEvent(client,"onAccountLogged",client)
	end
end)

addEvent("onAccountTryRegister",true)
addEventHandler("onAccountTryRegister",root,function (username,password)
    if not checkLoginRateLimit(client) then return end
	local class =  Account.getInstance()
	if(class:create(client,username,password)) then
		triggerClientEvent( client,"onAccountRegister",client)
	end
end)