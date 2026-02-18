# GUIA RÁPIDO DE DESENVOLVIMENTO - MTA GANG WAR

**Versão:** 1.0  
**Data:** 18/02/2026  

---

## 📋 ÍNDICE RÁPIDO

1. [Estrutura do Projeto](#estrutura-do-projeto)
2. [Como Adicionar Features](#como-adicionar-features)
3. [Comandos Úteis](#comandos-úteis)
4. [Troubleshooting](#troubleshooting)
5. [Boas Práticas](#boas-práticas)

---

## 📁 ESTRUTURA DO PROJETO

```
mta-gangwar/
├── Class/              # Classes principais (Database, Account, Gang, etc.)
├── Inits/              # Inicialização e event handlers
│   ├── login/          # Sistema de login/registro
│   ├── gameplay/       # Veículos, pickups, mensagens
│   ├── turf/           # Territórios e dominação
│   └── bank/           # Sistema bancário
├── hud/                # Interface do usuário (DX)
│   └── client/         # Todas as UIs do cliente
├── Shared/             # Código compartilhado cliente-servidor
├── [extras]/           # Recursos opcionais modulares
├── [map-gang-war-bases]/  # Objetos do mapa
├── meta.xml            # Configuração do resource
└── README.md           # Documentação básica
```

---

## 🚀 COMO ADICIONAR FEATURES

### Adicionar Nova Gangue

**Não é necessário código!** As gangues são criadas dinamicamente pelos jogadores no jogo usando `/gang create`.

Para modificar custos ou regras:
```lua
-- Editar: Class/Gang.lua

-- Linha 4: Custo de criação
if(getPlayerMoney(player) < 400000) then  -- Altere 400000
```

---

### Adicionar Novo Território

**Arquivo:** `Inits/turf/shared/data.lua`

```lua
-- Adicionar ao final do array Areas.data:
{
    ["name"] = "Novo Território",
    ["x"] = 2000.0,      -- Coordenada X
    ["y"] = 1500.0,      -- Coordenada Y
    ["width"] = 200.0,   -- Largura
    ["height"] = 200.0,  -- Altura
    ["owner"] = nil      -- null = neutro
}
```

**Nota:** Use o Map Editor do MTA para obter coordenadas precisas.

---

### Adicionar Nova Base

**Arquivo:** `Class/Base.lua`

```lua
-- Adicionar ao array Base.data:
{
    ["name"] = "Minha Base",
    ["cost"] = 750000,  -- Preço em $
    ["x"] = 2500.0,     -- Posição X
    ["y"] = 2000.0,     -- Posição Y
    ["z"] = 10.0,       -- Posição Z
    
    -- Portão (opcional)
    ["gate"] = {
        ["model"] = 980,  -- ID do objeto
        ["x"] = 2500.0,
        ["y"] = 2000.0,
        ["z"] = 10.0,
        ["rotX"] = 0,
        ["rotY"] = 0,
        ["rotZ"] = 90
    },
    
    -- Veículos da base
    ["vehicles"] = {
        {["id"] = 411, ["x"] = 2510, ["y"] = 2010, ["z"] = 10},
        {["id"] = 415, ["x"] = 2520, ["y"] = 2010, ["z"] = 10},
        -- Adicione mais veículos...
    },
    
    -- Pickups de armas
    ["pickups"] = {
        {["weapon"] = 31, ["x"] = 2505, ["y"] = 2005, ["z"] = 10},
        {["weapon"] = 29, ["x"] = 2508, ["y"] = 2005, ["z"] = 10},
        -- Adicione mais pickups...
    }
}
```

---

### Adicionar Nova Propriedade

**Arquivo:** `Class/Properties.lua`

```lua
-- Adicionar ao array Properties.data (linha 6+):
{
    ["name"] = "Minha Loja",
    ["price"] = 150000,      -- Preço de compra
    ["income"] = 5000,       -- Renda por ciclo (10 min)
    ["x"] = 1000.0,          -- Coordenada X
    ["y"] = 1000.0,          -- Coordenada Y
    ["z"] = 10.0,            -- Coordenada Z
    ["type"] = "shop"        -- Tipo: shop, hotel, casino, etc.
}
```

---

### Adicionar Novo Comando

**Arquivo:** Criar em `Inits/` ou usar `[extras]/comandos/comandos.lua`

```lua
-- Exemplo de comando simples
addCommandHandler("meucomando", function(player, cmd, ...)
    local args = {...}
    
    -- Verificar permissão (opcional)
    local account = Account.getInstance()
    if not account:isLogged(player) then
        outputChatBox("Você precisa estar logado!", player)
        return
    end
    
    -- Lógica do comando
    outputChatBox("Comando executado!", player)
end)
```

---

### Adicionar Nova Tela (HUD)

**Localização:** `hud/client/`

**Estrutura básica:**
```lua
-- Criar: hud/client/meu_sistema/MinhaUI.lua

MinhaUI = inherit(Panel)

function MinhaUI:init()
    Panel.init(self)
    
    self:setBounds(500, 300, 400, 300)  -- X, Y, Width, Height
    self:setBackground(0, 0, 0, 200)     -- R, G, B, Alpha
    
    -- Adicionar botão
    local btn = Button()
    btn:setBounds(10, 10, 100, 30)
    btn:setText("Clique Aqui")
    btn:onClick(function()
        outputChatBox("Botão clicado!")
    end)
    self:add(btn)
    
    self:setVisible(false)
end

-- Instanciar
local minhaUI = MinhaUI()

-- Mostrar/ocultar
addCommandHandler("minhaui", function()
    minhaUI:setVisible(not minhaUI:isVisible())
    showCursor(minhaUI:isVisible())
end)
```

**Não esqueça:** Adicionar ao `meta.xml`:
```xml
<script src="hud/client/meu_sistema/MinhaUI.lua" type="client"/>
```

---

## 🔧 COMANDOS ÚTEIS

### Comandos de Gangue
```
/gang create [nome] [cor]     - Cria nova gangue ($400k)
/gang invite [jogador]        - Convida jogador para gangue
/gang kick [jogador]          - Expulsa jogador da gangue
/gang promote [jogador]       - Promove membro
/gang demote [jogador]        - Rebaixa membro
/gang members                 - Lista membros
/gang color [R] [G] [B]       - Muda cor da gangue
/gang slogan [texto]          - Define slogan
/gang leave                   - Sair da gangue
/gang info                    - Informações da gangue
```

### Comandos de Admin (extras/comandos)
```
/fly                          - Modo voo
/god                          - Modo imortal
/car [id]                     - Spawnar veículo
/weapon [id] [munição]        - Dar arma
/givemoney [player] [valor]   - Dar dinheiro
/goto [player]                - Teleportar para jogador
/gethere [player]             - Trazer jogador
/kick [player]                - Expulsar jogador
/ban [player]                 - Banir jogador
/heal [player]                - Curar jogador
/fix                          - Reparar veículo
```

---

## 🔍 TROUBLESHOOTING

### ❌ Erro: "DB Connected" não aparece no console

**Problema:** Banco de dados não conectou

**Solução:**
1. Verificar se MySQL está rodando
2. Verificar credenciais em `Class/Database.lua`
3. Verificar se database existe: `CREATE DATABASE db_gangwar;`
4. Verificar permissões do usuário MySQL

```sql
-- MySQL
CREATE USER 'dba_gangwar'@'localhost' IDENTIFIED BY 'suasenha';
GRANT ALL PRIVILEGES ON db_gangwar.* TO 'dba_gangwar'@'localhost';
FLUSH PRIVILEGES;
```

---

### ❌ Erro: "Login system not saved xml config file"

**Problema:** Bug conhecido no README

**Explicação:** Não é um bug real. O sistema usa MySQL, não XML config files. O sistema de login funciona normalmente.

---

### ❌ Jogador não spawna após login

**Solução:**
1. Verificar se tabela `tbl_users_data` existe
2. Verificar se dados do jogador foram salvos:
```sql
SELECT * FROM tbl_users_data WHERE id_account = [id];
```
3. Verificar console do servidor para erros

---

### ❌ Território não muda de cor

**Problema:** Gang não tem team criada ou cor inválida

**Solução:**
1. Verificar se gangue existe: `/gang info`
2. Recriar team: Líder deve usar `/gang color R G B`
3. Verificar console para erros

---

### ❌ Veículos não spawnam na base

**Problema:** Base não foi inicializada ou dados incorretos

**Solução:**
1. Verificar coordenadas em `Class/Base.lua`
2. Verificar IDs de veículos (devem ser válidos do SA-MP)
3. Reiniciar resource: `/restart mta-gangwar`

---

### ❌ Resource não inicia

**Problema:** Erro de sintaxe ou dependência faltando

**Solução:**
1. Verificar console do servidor para erros
2. Verificar `meta.xml` - todos os arquivos existem?
3. Verificar recursos incluídos estão instalados:
```xml
<include resource="hud"/>
<include resource="systemID" />
<!-- etc... -->
```
4. Instalar recursos faltantes ou comentar linhas no meta.xml

---

## ✅ BOAS PRÁTICAS

### 1. Sempre Testar em Ambiente Local

```bash
# Clonar repositório
git clone https://github.com/TioMalandrex/mta-gangwar.git

# Configurar banco de dados local
mysql -u root -p
> CREATE DATABASE db_gangwar_test;
> USE db_gangwar_test;

# Modificar Database.lua para usar banco de teste
```

---

### 2. Usar Branches para Features

```bash
# Criar branch para nova feature
git checkout -b feature/novo-territorio

# Fazer mudanças...
git add .
git commit -m "Adiciona território Grove Street"

# Push e criar Pull Request
git push origin feature/novo-territorio
```

---

### 3. Comentar Código Complexo

```lua
-- ✅ BOM
-- Calcula XP baseado no tempo de domínio e número de membros
local xp = (dominationTime / 60) * memberCount * XP_MULTIPLIER

-- ❌ RUIM
local xp = (t/60)*m*xpm  -- ???
```

---

### 4. Validar Inputs do Usuário

```lua
-- ✅ BOM
function Gang:create(player, gangName, color)
    if type(gangName) ~= "string" or #gangName == 0 then
        return false, "Nome inválido"
    end
    if #gangName < 3 or #gangName > 20 then
        return false, "Nome deve ter 3-20 caracteres"
    end
    -- ... resto da validação
end

-- ❌ RUIM
function Gang:create(player, gangName, color)
    -- Assume que inputs são válidos
end
```

---

### 5. Usar Constantes ao Invés de Magic Numbers

```lua
-- ✅ BOM
local GANG_CREATION_COST = 400000
local MAX_GANG_NAME_LENGTH = 20
local MIN_PASSWORD_LENGTH = 8

if getPlayerMoney(player) < GANG_CREATION_COST then
    -- ...
end

-- ❌ RUIM
if getPlayerMoney(player) < 400000 then  -- O que é 400000?
    -- ...
end
```

---

### 6. Fechar Recursos Adequadamente

```lua
-- ✅ BOM
function saveToFile(data)
    local file = fileCreate("data.txt")
    if not file then return false end
    
    fileWrite(file, data)
    fileClose(file)  -- Sempre fechar!
    return true
end

-- ❌ RUIM
function saveToFile(data)
    local file = fileCreate("data.txt")
    fileWrite(file, data)
    -- Esqueceu de fechar!
end
```

---

### 7. Tratar Erros de Banco de Dados

```lua
-- ✅ BOM
local result = Database("tbl_users"):select("*"):where("id", userId):getSingle()
if not result then
    outputDebugString("Erro ao buscar usuário ID: " .. userId, 1)
    return false
end

-- ❌ RUIM
local result = Database("tbl_users"):select("*"):where("id", userId):getSingle()
local username = result.username  -- Crash se result for nil!
```

---

## 📚 RECURSOS ADICIONAIS

### IDs de Veículos
https://wiki.multitheftauto.com/wiki/Vehicle_IDs

### IDs de Armas
https://wiki.multitheftauto.com/wiki/Weapons

### IDs de Skins
https://wiki.multitheftauto.com/wiki/Character_Skins

### Documentação MTA
https://wiki.multitheftauto.com/

### SQL Tutorial
https://www.w3schools.com/sql/

---

## 🐛 REPORTAR BUGS

**GitHub Issues:** https://github.com/TioMalandrex/mta-gangwar/issues

**Template de Bug Report:**
```
**Descrição do Bug:**
[Descreva o problema]

**Como Reproduzir:**
1. Faça login como jogador
2. Execute comando /gang create
3. Observe o erro

**Comportamento Esperado:**
[O que deveria acontecer]

**Screenshots/Logs:**
[Cole logs do console ou screenshots]

**Ambiente:**
- Versão MTA: 1.5.9
- Sistema Operacional: Windows 10
- Versão do Gamemode: 1.0
```

---

## 📞 CONTATO

**Desenvolvedores:**
- Iaan Mesquita (Ianito) - Líder do projeto
- ZoLo - Suporte
- Shinigami - Desenvolvimento
- iNeewbie - Scripting
- Boypaki - Testes

**Website:** www.maingames.com.br (mencionado no código)

---

**Última Atualização:** 18/02/2026  
**Versão do Guia:** 1.0
