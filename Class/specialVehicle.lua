local super = Class("specialVehicle", LuaObject, function()

    static.instances = ArrayList();
    static.allowTimer = {}
    static.forbidden = {}
    static.rcVehicles = {}

    static.vehicleData = {
        {"Area 51", 425, 267.02517700195, 1861.5544433594, 18.719791412354, 83},      -- Hunter
        {"Fabrica", 520, 948.71069, 2120.38989, 19.69389, 270},                      -- Hydra
        {"Departamento Militar", 432, 1088.14758, 1334.06299, 10.82031, 87},         -- Rhino
        {"Construção", 447, 2454.79443, 1914.87244, 10.86473, 0},                    -- Seasparrow
        {"Garagem", 447, 2870.40112, 919.25647, 10.75, 90}                           -- Seasparrow
    }

end).getSuperclass()	


function specialVehicle:init(base, model, x, y, z, rotation)
    super.init(self)

    self.vehicle = createVehicle(model, x, y, z, 0, 0, rotation)
    self.base = base
    self.owner = nil
    self:updateColor(160,160,160)

    if Base and Base.instances and Base.instances.table then
        for _, baseInstance in pairs(Base.instances.table) do
            if baseInstance.name == self.base and baseInstance.owner then
                local gang = Gang.getFromName(baseInstance.owner)
                if gang then
                    local r,g,b = gang:getColor()
                    self:updateColor(r,g,b)
                    self:setOwner(baseInstance.owner)
                end
                break
            end
        end
    end

    -- Corrigido: syncVehicle agora usa função global correta
    syncVehicle(self.vehicle)

    addEventHandler("onVehicleStartEnter", self.vehicle, function(...)
        self:onVehicleStartEnter(...)
    end)

    addEventHandler("onVehicleEnter", self.vehicle, function(...)
        self:onVehicleEnter(...)
    end)

    addEventHandler("onVehicleExit", self.vehicle, function(...)
        self:onVehicleExit(...)
    end)

    addEventHandler("onVehicleExplode", self.vehicle, function()
        self:onVehicleExplode()
    end)

    addEventHandler("onVehicleRespawn", self.vehicle, function()
        self:onVehicleRespawn(self.vehicle)
    end)

    specialVehicle.instances:add(self)
    return self
end


--------------------------------------------------------------------
-- ⚠️ CORREÇÃO: Jogadores só entram se forem da gang dona
--------------------------------------------------------------------
function specialVehicle:onVehicleStartEnter(player)
    if (player and player:getType() == "player") then
        -- Check if vehicle has forbidden status (cooldown active)
        if (isTimer(specialVehicle.allowTimer[self.vehicle])) then
            cancelEvent()
            outputChatBox("[BASE] Este veículo foi usado recentemente.", player, 255, 0, 0, true)
            return
        end
        
        -- Check if vehicle has an owner
        if not self.owner then
            cancelEvent()
            outputChatBox("[BASE] Este veículo não pertence a nenhuma gang.", player, 255, 0, 0, true)
            return
        end
        
        -- Check if player's gang matches owner
        if (player:getTeam() and player:getTeam().name == self.owner) then
            -- Player is from the owning gang - allow entry
            return
        else
            outputChatBox("[BASE] Este veículo pertence à base "..self.base, player, 255, 0, 0, true)
            cancelEvent()
        end
    end
end


--------------------------------------------------------------------
-- Event handler: When player enters vehicle
--------------------------------------------------------------------
function specialVehicle:onVehicleEnter(player, seat)
    -- Additional logic when player successfully enters vehicle
    if (player and player:getType() == "player" and seat == 0) then
        -- Driver entered, can add additional logic here if needed
    end
end


--------------------------------------------------------------------
-- Event handler: When player exits vehicle
--------------------------------------------------------------------
function specialVehicle:onVehicleExit(player, seat)
    -- Additional logic when player exits vehicle
    if (player and player:getType() == "player") then
        -- Can add additional logic here if needed
    end
end


--------------------------------------------------------------------
-- Event handler: When vehicle explodes
--------------------------------------------------------------------
function specialVehicle:onVehicleExplode()
    -- Vehicle exploded, will respawn automatically
    -- Respawn handler will set cooldown timer
end


--------------------------------------------------------------------
-- Sistema de cooldown pós-respawn
--------------------------------------------------------------------
function specialVehicle:onVehicleRespawn(vehicle)
    vehicle:setData("forbidden", true)
    
    -- Cancel existing timer if it exists
    if (isTimer(specialVehicle.allowTimer[vehicle])) then
        killTimer(specialVehicle.allowTimer[vehicle])
    end
    
    -- Create new cooldown timer (10 minutes)
    specialVehicle.allowTimer[vehicle] = setTimer(function()
        if isElement(vehicle) then
            vehicle:setData("forbidden", false)
        end
        specialVehicle.allowTimer[vehicle] = nil
    end, 10*60000, 1)
end


--------------------------------------------------------------------
-- NOVO: Buscar veículo especial pela base
--------------------------------------------------------------------
function specialVehicle.getFromBaseName(baseName)
    if not baseName then return false end
    
    -- Handle ArrayList or regular table structure
    local instanceTable = specialVehicle.instances.table or specialVehicle.instances
    
    if type(instanceTable) == "table" then
        for _, inst in pairs(instanceTable) do
            if inst and inst.base == baseName then
                return inst
            end
        end
    end
    
    return false
end


--------------------------------------------------------------------
-- NOVO: Atualizar cor para a cor da gang
--------------------------------------------------------------------
function specialVehicle:updateColor(r,g,b)
    if isElement(self.vehicle) then
        -- Validate RGB values (0-255)
        r = math.max(0, math.min(255, tonumber(r) or 255))
        g = math.max(0, math.min(255, tonumber(g) or 255))
        b = math.max(0, math.min(255, tonumber(b) or 255))
        
        self.vehicle:setColor(r,g,b)
    end
end


--------------------------------------------------------------------
-- NOVO: Atualizar owner da gang
--------------------------------------------------------------------
function specialVehicle:setOwner(owner)
    self.owner = owner
end


--------------------------------------------------------------------
-- Evento de listagem de veículos bloqueados
--------------------------------------------------------------------
addEvent("onPlayerRequestForbiddenVehicles", true)
addEventHandler("onPlayerRequestForbiddenVehicles", root,
function()
    -- Initialize timers table before loop
    local timers = {}
    
    -- Handle ArrayList or regular table structure
    local instanceTable = specialVehicle.instances.table or specialVehicle.instances
    
    if type(instanceTable) == "table" then
        for _,instance in pairs(instanceTable) do
            if instance and instance.vehicle and isTimer(specialVehicle.allowTimer[instance.vehicle]) then
                local forbidden = {
                    elem = instance.vehicle,
                    time = getTimerDetails(specialVehicle.allowTimer[instance.vehicle])
                }
                table.insert(timers, forbidden)
            end
        end
    end
    
    -- Only send event if there are forbidden vehicles
    if #timers > 0 then
        triggerClientEvent(source, "onClientRecieveForbiddenVehicles", source, timers)
    end
end)


--------------------------------------------------------------------
-- Criar todos veículos especiais ao iniciar o recurso
--------------------------------------------------------------------
addEventHandler("onResourceStart", resourceRoot, function()
    for _,vehicle in pairs(specialVehicle.vehicleData) do
        specialVehicle(vehicle[1], vehicle[2], vehicle[3], vehicle[4], vehicle[5], vehicle[6])
    end
end)
