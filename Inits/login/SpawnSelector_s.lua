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

addEvent("changeSkinServer",true)
addEventHandler( "changeSkinServer", root,function(idSkin)
    if isEventRateLimited(client, "changeSkinServer") then
        return
    end
    source:setModel(idSkin)
    source:setRotation(180,180,0)
end)

addEvent("protectPlayerServer",true)
addEventHandler( "protectPlayerServer", root,function()
    if isEventRateLimited(client, "protectPlayerServer") then
        return
    end
    source:setDimension(666)
    source:setRotation(180,180,0)
end)

addEvent("unprotectPlayerServer",true)
addEventHandler( "unprotectPlayerServer", root,function(dimension,interior)
    if isEventRateLimited(client, "unprotectPlayerServer") then
        return
    end
    source:setInterior(interior)
    source:setDimension(dimension)
end)
