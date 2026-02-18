# CONSIDERAÇÕES ESPECÍFICAS PARA MTA:SA - GANG WAR GAMEMODE

**Data:** 18 de Fevereiro de 2026  
**Plataforma:** Multi Theft Auto: San Andreas (MTA:SA)  
**Versão Requerida:** MTA 1.5.3+  
**Tipo:** Gamemode

---

## 📋 SOBRE MTA:SA

**Multi Theft Auto: San Andreas (MTA:SA)** é uma plataforma multiplayer modificada para GTA San Andreas que permite criar servidores personalizados com modos de jogo (gamemodes), scripts e recursos customizados usando a linguagem Lua.

### Características da Plataforma MTA:SA

- **Linguagem:** Lua 5.1
- **Arquitetura:** Cliente-Servidor
- **Sistema de Recursos:** Modular (resources)
- **Sincronização:** Elementos, eventos e dados entre cliente/servidor
- **API:** Extensa biblioteca de funções nativas
- **Performance:** Suporta 100+ jogadores simultâneos
- **Comunidade:** Grande base de recursos compartilhados

---

## 🎮 GANG WAR COMO GAMEMODE MTA:SA

### Tipo de Resource

```xml
<meta>
    <info author="MainGames Developers" 
          description="Gang War" 
          version="1.0" 
          type="gamemode" />
    <oop>true</oop>
    <!-- ... -->
</meta>
```

**Características:**
- **Type:** `gamemode` - Modo de jogo completo que gerencia toda a experiência do servidor
- **OOP:** `true` - Usa programação orientada a objetos do MTA
- **Version:** 1.0 - Versão inicial do gamemode

### Diferença entre Gamemode e Resource

| Aspecto | Gamemode | Resource |
|---------|----------|----------|
| **Escopo** | Sistema completo | Funcionalidade específica |
| **Controle** | Gerencia servidor inteiro | Complementa gamemode |
| **Exemplos** | Gang War, Race, DM | Scoreboard, Map Editor |
| **Inicialização** | Único ativo por vez | Múltiplos ativos |

**Gang War é um gamemode completo**, não apenas um resource adicional.

---

## 🔧 RECURSOS MTA UTILIZADOS

### Recursos Incluídos (Dependencies)

O gamemode depende de 20+ recursos externos do MTA:

```xml
<!-- Recursos Essenciais -->
<include resource="hud"/>                    <!-- Interface do usuário -->
<include resource="systemID" />              <!-- Sistema de IDs -->
<include resource="scoreboard"/>             <!-- Placar de jogadores -->

<!-- Recursos de Gameplay -->
<include resource="realdriveby"/>            <!-- Drive-by realista -->
<include resource="wasted"/>                 <!-- Tela de morte -->
<include resource="deathpickups" minversion="1.5.2"/> <!-- Drops ao morrer -->

<!-- Recursos Visuais -->
<include resource="modern_radar"/>           <!-- Radar moderno -->
<include resource="maximap" minversion="1.5.2"/>     <!-- Mapa expandido -->
<include resource="nametag" minversion="1.5.2"/>     <!-- Nametags -->
<include resource="deaths_tags" minversion="1.3.4"/> <!-- Tags de morte -->

<!-- Recursos de Economia -->
<include resource="ammunation" minversion="1.5.2"/>   <!-- Lojas de armas -->
<include resource="burguer" minversion="1.5.2"/>      <!-- Comida -->
<include resource="vehicleShop" minversion="1.5.2"/>  <!-- Loja de veículos -->

<!-- Mapas -->
<include resource="[map-gang-war-bases]" />  <!-- Objetos das bases -->
```

### Compatibilidade de Versões

| Recurso | Versão Mínima MTA |
|---------|-------------------|
| maximap | 1.5.2 |
| nametag | 1.5.2 |
| deaths_tags | 1.3.4 |
| ammunation | 1.5.2 |
| burguer | 1.5.2 |
| vehicleShop | 1.5.2 |
| Base gamemode | 1.5.3 |

**Recomendação:** Usar MTA Server 1.5.9 ou superior para melhor compatibilidade.

---

## 📡 ARQUITETURA CLIENTE-SERVIDOR MTA

### Separação de Código

```
mta-gangwar/
├── Server-side (type="server")
│   ├── Class/*.lua              # Lógica de negócio
│   ├── Inits/*_s.lua           # Handlers servidor
│   └── Shared/exports.lua      # Exports públicos
│
├── Client-side (type="client")
│   ├── hud/client/**/*.lua     # Interface gráfica
│   ├── Inits/*_c.lua           # Handlers cliente
│   └── Inits/main_c.lua        # Inicialização cliente
│
└── Shared (type="shared")
    ├── Shared/core.luac        # Framework OOP
    └── Class/utils.lua         # Utilitários
```

### Sistema de Eventos MTA

#### Eventos Nativos Utilizados
```lua
-- Eventos do Servidor
addEventHandler("onResourceStart", resourceRoot, function()
    -- Inicialização do gamemode
end)

addEventHandler("onPlayerJoin", root, function()
    -- Novo jogador conectou
end)

addEventHandler("onPlayerQuit", root, function()
    -- Jogador desconectou - salvar dados
end)

addEventHandler("onVehicleEnter", root, function(player, seat)
    -- Controle de acesso a veículos
end)

addEventHandler("onColShapeHit", root, function(element)
    -- Dominação de territórios
end)

-- Eventos do Cliente
addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Inicialização cliente
end)

addEventHandler("onClientRender", root, function()
    -- Renderização DX (HUD)
end)
```

#### Eventos Customizados
```lua
-- Servidor
addEvent("onAccountTryLogin", true)      -- Cliente → Servidor
addEvent("onAccountTryRegister", true)   -- Cliente → Servidor
addEvent("onPlayerEnterArea", true)      -- Cliente → Servidor

-- Cliente
addEvent("onAccountLogged", true)        -- Servidor → Cliente
addEvent("onAccountRegister", true)      -- Servidor → Cliente
```

### Comunicação Cliente-Servidor

```lua
-- Cliente envia dados ao servidor
triggerServerEvent("onAccountTryLogin", localPlayer, username, password)

-- Servidor processa e responde ao cliente
triggerClientEvent(player, "onAccountLogged", player, userData)
```

**Importante:** Por segurança, toda validação crítica ocorre no servidor.

---

## 🗄️ BANCO DE DADOS MTA

### Conexão MySQL

O MTA:SA suporta MySQL através da função `Connection()`:

```lua
-- Class/Database.lua
connection = Connection(
    "mysql",                                    -- Tipo
    "dbname=db_gangwar;host=127.0.0.1;port=3306", -- String de conexão
    "dba_gangwar",                              -- Usuário
    "ianitolindo",                              -- Senha
    "share=1"                                   -- Opções
)
```

### Queries Assíncronas MTA

```lua
-- Query com callback
local query = dbQuery(connection, "SELECT * FROM tbl_users WHERE id = ?", userId)
dbPoll(query, 100, function(queryHandle)
    local result = dbPoll(queryHandle, 0)
    if result then
        -- Processar resultado
    end
end)
```

**Problema Atual:** O gamemode usa `dbPoll(query, -1)` que é **síncrono** e bloqueia a thread principal.

---

## 🎨 INTERFACE GRÁFICA (DX)

### DirectX Drawing (DX)

O MTA usa funções DX para renderização de interface:

```lua
-- Renderização na tela
addEventHandler("onClientRender", root, function()
    -- Desenhar retângulo
    dxDrawRectangle(x, y, width, height, tocolor(r, g, b, a))
    
    -- Desenhar texto
    dxDrawText(text, x, y, width, height, color, scale, font)
    
    -- Desenhar imagem
    dxDrawImage(x, y, width, height, imagePath)
end)
```

### Framework de UI Customizado

O gamemode usa um framework OOP customizado para UI:

```lua
-- hud/client/login/LoginZ.lua
LoginZ = inherit(Panel)

function LoginZ:init()
    Panel.init(self)
    
    self:setBounds(500, 300, 400, 300)
    self:setBackground(0, 0, 0, 200)
    
    -- Adicionar campos
    local btn = Button()
    btn:setText("Login")
    self:add(btn)
end
```

---

## 🚗 ELEMENTOS MTA

### Tipos de Elementos

```lua
-- Veículos
local vehicle = createVehicle(modelID, x, y, z, rx, ry, rz)
setVehicleColor(vehicle, r1, g1, b1, r2, g2, b2)

-- Objetos
local object = createObject(modelID, x, y, z, rx, ry, rz)
setObjectScale(object, scale)

-- Pickups
local pickup = createPickup(x, y, z, pickupType, weaponID)

-- Markers
local marker = createMarker(x, y, z, type, size, r, g, b, a)

-- Blips
local blip = createBlipAttachedTo(element, icon)

-- ColShapes (Zonas de Colisão)
local colShape = createColRectangle(x, y, width, height)
```

### Hierarquia de Elementos

```
root (elemento raiz)
├── resourceRoot (raiz do resource)
├── Players
│   ├── player1
│   └── player2
├── Vehicles
│   ├── vehicle1
│   └── vehicle2
└── Objects
    ├── object1
    └── object2
```

---

## 👥 SISTEMA DE TEAMS MTA

### Gangues como Teams

```lua
-- Criar team (gangue)
local team = createTeam(gangName, r, g, b)

-- Adicionar jogador à team
setPlayerTeam(player, team)

-- Obter team do jogador
local team = getPlayerTeam(player)

-- Obter jogadores da team
local players = getPlayersInTeam(team)

-- Definir cor da team
setTeamColor(team, r, g, b)
```

**No Gang War:** Cada gangue é um Team do MTA, permitindo:
- Identificação visual por cores
- Friendly fire control
- Scoreboard agrupado
- Chat de gangue

---

## 🔐 SISTEMA ACL MTA (Controle de Acesso)

### ACL Groups

O MTA possui sistema ACL nativo para permissões:

```xml
<!-- acl.xml -->
<group name="Admin">
    <acl name="Admin"></acl>
    <object name="user.Admin"></object>
    <object name="resource.admin"></object>
</group>

<group name="Moderator">
    <acl name="Moderator"></acl>
</group>
```

### Verificar Permissões

```lua
-- Verificar se jogador está no grupo ACL
if isObjectInACLGroup("user." .. accountName, aclGetGroup("Admin")) then
    -- Jogador é admin
end

-- Verificar permissão específica
if hasObjectPermissionTo(player, "function.kickPlayer") then
    -- Tem permissão para kickar
end
```

**Observação:** O Gang War não usa ACL nativo, implementa sistema próprio de ranks de gangue.

---

## 📦 ESTRUTURA DE RESOURCE MTA

### meta.xml - Manifesto do Resource

```xml
<meta>
    <!-- Informações do resource -->
    <info author="..." description="..." version="..." type="gamemode" />
    
    <!-- Habilitar OOP -->
    <oop>true</oop>
    
    <!-- Scripts servidor -->
    <script src="path/file.lua" type="server" />
    
    <!-- Scripts cliente -->
    <script src="path/file.lua" type="client" />
    
    <!-- Scripts compartilhados -->
    <script src="path/file.lua" type="shared" />
    
    <!-- Arquivos de dados -->
    <file src="path/image.png" />
    
    <!-- Exports (funções públicas) -->
    <export function="getDatabase" type="server" />
    
    <!-- Includes (dependências) -->
    <include resource="scoreboard" />
    
    <!-- Configurações -->
    <settings>
        <setting name="*maxplayers" value="128" />
    </settings>
</meta>
```

### Exports - API Pública

```lua
-- Definir export em meta.xml
<export function="getDatabase" type="server" />

-- Implementação
function getDatabase()
    return Database.getInstance()
end

-- Usar de outro resource
local db = exports["mta-gangwar"]:getDatabase()
```

---

## ⚡ PERFORMANCE EM MTA:SA

### Limitações da Plataforma

| Aspecto | Limite | Recomendação |
|---------|--------|--------------|
| **Jogadores** | 128 max | 50-100 ideal |
| **Veículos** | 1000+ | 200-500 ideal |
| **Objetos** | 1000+ | 500-1000 ideal |
| **Markers** | Ilimitado | < 100 visíveis |
| **FPS Servidor** | 60 FPS | Manter acima de 40 |
| **Tick Rate** | 100ms | Mínimo |

### Boas Práticas de Performance

#### 1. **Renderização DX**
```lua
-- ❌ RUIM - Renderiza sempre
addEventHandler("onClientRender", root, function()
    dxDrawText(...)
end)

-- ✅ BOM - Renderiza apenas quando visível
if isVisible then
    addEventHandler("onClientRender", root, renderFunction)
else
    removeEventHandler("onClientRender", root, renderFunction)
end
```

#### 2. **Timers**
```lua
-- ❌ RUIM - Timer muito rápido
setTimer(updateFunction, 10, 0)  -- A cada 10ms

-- ✅ BOM - Timer adequado
setTimer(updateFunction, 1000, 0)  -- A cada 1s
```

#### 3. **Eventos**
```lua
-- ❌ RUIM - Listener em root
addEventHandler("onClientRender", root, function()
    -- Todo render
end)

-- ✅ BOM - Listener específico
addEventHandler("onClientRender", getRootElement(), function()
    -- Apenas quando necessário
end, true, "low")  -- Baixa prioridade
```

### FPS Limit

```lua
-- Inits/main.lua
setFPSLimit(60)  -- Limita servidor a 60 FPS
```

---

## 🌐 NETWORKING MTA

### Latência e Sincronização

```lua
-- Obter ping do jogador
local ping = getPlayerPing(player)

-- Obter packetloss
local packetLoss = getPlayerPacketLoss(player)

-- Sincronização de elementos
setElementSyncer(vehicle, player)  -- Define quem sincroniza o veículo
```

### Element Data (Dados Sincronizados)

```lua
-- Definir dado sincronizado
setElementData(player, "money", 10000)

-- Obter dado
local money = getElementData(player, "money")

-- Remover sincronização automática (melhor performance)
setElementData(player, "money", 10000, false)  -- Não sincroniza
```

**Importante:** Element data consome bandwidth. Evitar para dados sensíveis.

---

## 🔒 SEGURANÇA EM MTA:SA

### Client-Side vs Server-Side

```lua
-- ❌ NUNCA confie no cliente
-- Cliente envia:
triggerServerEvent("giveMeMoney", localPlayer, 999999999)

-- Servidor DEVE validar:
addEvent("giveMeMoney", true)
addEventHandler("giveMeMoney", root, function(amount)
    -- VALIDAR!
    if amount > 0 and amount <= 1000 then
        givePlayerMoney(client, amount)
    else
        -- Possível cheater
        banPlayer(client, false, false, true, "Cheat attempt")
    end
end)
```

### Source e Client

```lua
-- Em eventos do servidor:
-- source = elemento que disparou o evento
-- client = jogador que triggerou (se veio do cliente)

addEvent("buyItem", true)
addEventHandler("buyItem", root, function(itemID)
    local player = client  -- Jogador que chamou
    -- Validar player
    if not player or getElementType(player) ~= "player" then
        return false
    end
    -- Processar compra...
end)
```

### Anti-Cheat Nativo

```lua
-- Detectar modificações
addEventHandler("onPlayerModInfo", root, function(filename, modList)
    -- Jogador tem mods instalados
    outputDebugString("Player " .. getPlayerName(source) .. " has mods")
end)

-- Verificar screenshots
takePlayerScreenShot(player, 800, 600, "screenshots", 10)
```

---

## 🎯 BOAS PRÁTICAS PARA GAMEMODES MTA

### 1. **Sempre Validar no Servidor**

```lua
-- ✅ CORRETO
-- Cliente solicita
triggerServerEvent("createGang", localPlayer, gangName, color)

-- Servidor valida TUDO
addEvent("createGang", true)
addEventHandler("createGang", root, function(gangName, color)
    if not client then return end
    if type(gangName) ~= "string" then return end
    if #gangName < 3 or #gangName > 20 then return end
    -- ... outras validações
    Gang:create(client, gangName, color)
end)
```

### 2. **Usar OOP do MTA**

```lua
-- Habilitar no meta.xml
<oop>true</oop>

-- Usar classes
local super = Class("MyClass", LuaObject, function()
    -- Inicialização estática
end)

function MyClass:init()
    -- Construtor
end
```

### 3. **Gerenciar Memória**

```lua
-- Destruir elementos não utilizados
if isElement(vehicle) then
    destroyElement(vehicle)
end

-- Remover event handlers não utilizados
removeEventHandler("onClientRender", root, renderFunction)

-- Limpar timers
if isTimer(myTimer) then
    killTimer(myTimer)
end
```

### 4. **Logs Estruturados**

```lua
-- Usar outputDebugString com níveis
outputDebugString("[INFO] Player logged in", 3, 0, 255, 0)     -- Verde (info)
outputDebugString("[WARNING] Low health", 2, 255, 165, 0)      -- Laranja (warning)
outputDebugString("[ERROR] Database failed", 1, 255, 0, 0)     -- Vermelho (erro)
```

### 5. **Async Database**

```lua
-- ❌ EVITAR - Síncrono
local result = dbPoll(dbQuery(...), -1)  -- Bloqueia servidor!

-- ✅ USAR - Assíncrono
local query = dbQuery(...)
dbPoll(query, 100, function(queryHandle)
    local result = dbPoll(queryHandle, 0)
    -- Processar resultado
end)
```

---

## 📚 RECURSOS E FERRAMENTAS MTA

### Ferramentas Oficiais

| Ferramenta | Descrição |
|------------|-----------|
| **MTA Server** | Servidor dedicado |
| **MTA Client** | Cliente para jogadores |
| **Map Editor** | Editor de mapas visual |
| **Resource Browser** | Navegador de resources |
| **Admin Panel** | Painel de administração |

### Debugging

```lua
-- Console do servidor
outputServerLog("Message")
outputDebugString("Debug message")

-- Console do cliente
outputConsole("Client message")
outputChatBox("Chat message")

-- Inspect
iprint(table)  -- Mostra conteúdo de tabela
```

### Comunidade

- **Wiki Oficial:** https://wiki.multitheftauto.com/
- **Forum:** https://forum.multitheftauto.com/
- **Discord:** Comunidade MTA
- **GitHub:** Resources compartilhados

---

## ✅ CHECKLIST DE COMPATIBILIDADE MTA

### Antes de Deploy

- [ ] Versão MTA Server >= 1.5.3
- [ ] Todos os resources incluídos instalados
- [ ] meta.xml corretamente configurado
- [ ] Banco de dados MySQL configurado
- [ ] ACL configurado (se necessário)
- [ ] FPS limit definido (60 recomendado)
- [ ] Max players configurado
- [ ] Porta do servidor aberta (default: 22003)
- [ ] Resources de dependência baixados
- [ ] Testes com múltiplos jogadores

### Performance Checks

- [ ] FPS servidor > 40
- [ ] Latência < 100ms
- [ ] Packet loss < 1%
- [ ] Uso de RAM < 2GB
- [ ] CPU < 80%
- [ ] Queries async implementadas
- [ ] Element data otimizado
- [ ] Timers otimizados

---

## 🚀 COMANDOS MTA ÚTEIS

### Console do Servidor

```bash
# Iniciar resource
start mta-gangwar

# Parar resource
stop mta-gangwar

# Reiniciar resource
restart mta-gangwar

# Listar resources
list

# Mostrar jogadores
who

# Kickar jogador
kick playerName reason

# Banir jogador
ban playerName reason

# Desbanir
unban banID
```

### In-Game (Admin)

```
/start mta-gangwar     - Iniciar gamemode
/stop mta-gangwar      - Parar gamemode
/restart mta-gangwar   - Reiniciar gamemode
/refresh               - Recarregar lista de resources
/debugscript 3         - Habilitar debug (nível 3)
```

---

## 📊 ESTATÍSTICAS DO GAMEMODE

### Requisitos MTA

| Requisito | Valor |
|-----------|-------|
| **MTA Server** | 1.5.3+ |
| **MTA Client** | 1.5.3+ |
| **MySQL** | 5.7+ ou MariaDB 10+ |
| **RAM** | 1-2 GB |
| **CPU** | 2+ cores |
| **Largura de Banda** | 10 Mbps+ (50 jogadores) |
| **Espaço em Disco** | 500 MB |

### Capacidade

| Métrica | Valor |
|---------|-------|
| **Jogadores Suportados** | 50-100 (recomendado) |
| **Gangues Simultâneas** | Ilimitado (limitado por DB) |
| **Territórios** | 60+ configurados |
| **Bases** | 5 disponíveis |
| **Veículos Simultâneos** | 200+ |

---

## 🎓 CONCLUSÃO MTA:SA

O **Gang War Gamemode** é um **gamemode completo e profissional para MTA:SA** que:

✅ Segue arquitetura padrão MTA (cliente-servidor)  
✅ Usa sistema de recursos modular  
✅ Implementa OOP do MTA corretamente  
✅ Utiliza eventos nativos e customizados  
✅ Integra com múltiplos resources externos  
✅ Suporta 50-100 jogadores  

⚠️ Requer melhorias de segurança antes de produção  
⚠️ Queries síncronas devem ser convertidas para async  
⚠️ Credenciais devem ser movidas para configuração externa  

**Com as correções sugeridas, este gamemode está pronto para ser um dos principais servidores de Gang War no MTA:SA Brasil.**

---

**Documento preparado por:** GitHub Copilot Agent  
**Data:** 18/02/2026  
**Plataforma:** MTA:SA 1.5.3+  
**Versão:** 1.0
