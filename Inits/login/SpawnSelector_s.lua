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

-- Segurança: usar sempre `client` (o jogador que disparou o evento).
-- O `source` pode ser qualquer elemento escolhido pelo cliente.
-- Ref.: https://wiki.multitheftauto.com/wiki/Script_security
local savedPlace = {}

addEventHandler("onPlayerQuit", root, function()
    savedPlace[source] = nil
end)

addEvent("changeSkinServer",true)
addEventHandler( "changeSkinServer", root,function(idSkin)
    if isEventRateLimited(client, "changeSkinServer") then
        return
    end
    idSkin = tonumber(idSkin)
    if not idSkin then
        return
    end
    client:setModel(idSkin)
    client:setRotation(180,180,0)
end)

addEvent("protectPlayerServer",true)
addEventHandler( "protectPlayerServer", root,function()
    if isEventRateLimited(client, "protectPlayerServer") then
        return
    end
    -- Guarda no servidor onde o jogador estava, para restaurar depois.
    if not savedPlace[client] then
        savedPlace[client] = { dimension = client:getDimension(), interior = client:getInterior() }
    end
    client:setDimension(666)
    client:setRotation(180,180,0)
end)

addEvent("unprotectPlayerServer",true)
addEventHandler( "unprotectPlayerServer", root,function()
    if isEventRateLimited(client, "unprotectPlayerServer") then
        return
    end
    -- Ignora dimensão/interior enviados pelo cliente; usa o que o servidor guardou.
    local place = savedPlace[client]
    savedPlace[client] = nil
    if not place then
        return
    end
    client:setInterior(place.interior)
    client:setDimension(place.dimension)
end)
