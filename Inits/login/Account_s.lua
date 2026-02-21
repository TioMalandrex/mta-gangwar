local EVENT_COOLDOWN_MS = 500
local eventCooldowns = {}

local function isEventRateLimited(player, eventName)
	if not isElement(player) then
		return true
	end
	local now = getTickCount()
	local playerCooldowns = eventCooldowns[player]
	if not playerCooldowns then
		playerCooldowns = {}
		eventCooldowns[player] = playerCooldowns
	end

	local lastTick = playerCooldowns[eventName] or 0
	if now - lastTick < EVENT_COOLDOWN_MS then
		return true
	end

	playerCooldowns[eventName] = now
	return false
end

addEventHandler("onPlayerQuit", root, function()
	eventCooldowns[source] = nil
end)

addEvent("onAccountTryLogin",true)
addEventHandler("onAccountTryLogin",root,function (username,password)
	if isEventRateLimited(client, "onAccountTryLogin") then
		return
	end
	local class = Account.getInstance()
	if(class:login(client,username,password)) then
		triggerClientEvent(client,"onAccountLogged",client)
	end
end)

addEvent("onAccountTryRegister",true)
addEventHandler("onAccountTryRegister",root,function (username,password)
	if isEventRateLimited(client, "onAccountTryRegister") then
		return
	end
	local class =  Account.getInstance()
	if(class:create(client,username,password)) then
		triggerClientEvent( client,"onAccountRegister",client)
	end
end)
