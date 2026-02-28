# Análise Completa: Sincronização em Tempo Real entre Servidor e Banco de Dados

> **Repositório:** mta-gangwar  
> **Data:** 2026-02-28  
> **Escopo:** Por que alterações no banco de dados não refletem no servidor (e vice-versa) imediatamente

---

## 1. Resumo Executivo

O servidor **não possui sincronização bidirecional em tempo real** com o banco de dados MySQL. Isso ocorre por uma razão arquitetural fundamental: o padrão adotado é **"carregar ao iniciar, salvar ao parar"** (_load-on-start, save-on-stop_). A maior parte dos dados vive em memória RAM durante a execução e é gravada no banco apenas quando o jogador desconecta ou o recurso encerra.

Esta análise descreve:
- O fluxo atual de cada sistema;
- O que **não** é salvo/lido em tempo real e por quê;
- O que **já** funciona em tempo real (exceções);
- O que é necessário para implementar sincronização completa nos dois sentidos.

---

## 2. Arquitetura Atual de Persistência

### 2.1 Padrão Dominante: Load-on-Start / Save-on-Stop

```
onResourceStart → ler todos os dados do DB → manter em memória RAM
(durante a sessão) → todas as mudanças ficam apenas em variáveis Lua
onPlayerQuit / onResourceStop → gravar dados de volta no DB
```

Este modelo é simples e eficiente em termos de performance (sem consultas contínuas ao banco), mas cria uma janela de inconsistência que pode durar **toda a sessão do servidor** entre o estado em memória e o estado persistido no banco.

### 2.2 Classes e seus mecanismos de persistência

| Sistema | Arquivo | Carrega no start? | Salva no quit/stop? | Salva em tempo real? |
|---|---|---|---|---|
| Account/Player | `Class/Account.lua` | ✅ (`onResourceStart` → `loadAccount`) | ✅ (`onPlayerQuit` + `onResourceStop`) | ❌ parcial |
| Gang (metadados) | `Class/Gang.lua` | ✅ (`onResourceStart`) | ❌ não há save no stop | ⚠️ apenas criar/deletar |
| Gang (XP) | `Class/Gang.lua` | ✅ (carregado junto com gang) | ❌ não há save no stop | ❌ |
| Territórios (owner) | `Class/Area.lua` | ✅ (`onResourceStart`) | ✅ (`onResourceStop`) | ✅ via `persistOwnerNow()` |
| Propriedades (owner) | `Class/Properties.lua` | ✅ (`onResourceStart`) | ✅ (`onResourceStop`) | ❌ |
| Bases (owner) | `Class/Base.lua` | ✅ (`onResourceStart`) | ⚠️ depende da impl. | ❌ |
| Banco (saldo) | `Inits/bank/BankSystem_s.lua` | ✅ (via `loadAccount`) | ✅ (via `saveData` no quit) | ❌ |

---

## 3. Análise por Sistema: Servidor → Banco de Dados

### 3.1 Dados do Jogador (Account/Player)

**Arquivo:** `Class/Account.lua`, função `Account:saveData(player)`

**O que é gravado:**
```
position, rotation, skin, health, armor, money, interior,
dimension, kills, deaths, clothes, weapons, gang, level,
bank_balance, vip
```

**Quando é gravado:**
- `onPlayerQuit` → salva apenas o jogador que saiu
- `onResourceStop` → salva todos os jogadores conectados

**Problema:** Qualquer mudança ocorrida durante a sessão (ganhar/perder kills, mudar de gang, ganhar dinheiro, mudar de skin) **não é persistida enquanto o jogador estiver conectado**. Se o servidor travar antes de `onPlayerQuit` ou `onResourceStop` ser chamado, todos os dados da sessão são perdidos.

**Trecho relevante:**
```lua
-- Account.lua linha 321-325
function Account:onPlayerQuit(player)
    outputDebugString("login: onPlayerQuit")
    self:saveData(player)  -- só salva ao sair
    return true
end
```

---

### 3.2 Gang XP

**Arquivo:** `Class/Gang.lua`, funções `Gang:setXP()`, `Gang:incrementXP()`, `Gang:decrementXP()`

**O que não é salvo:**
```lua
function Gang:incrementXP(xp)
    self.xp = self:getXP() + xp
    if(self.team) then
        self.team:setData("xp", self.xp)  -- só atualiza dados do elemento MTA
    end
    return true
    -- NENHUMA query ao banco de dados aqui!
end
```

**Consequência:** O XP de todas as gangs muda constantemente durante o jogo (territórios capturados, defesas), mas **nunca é salvo no banco** (`tbl_gangs.xp`) durante a sessão. Não há `onResourceStop` para Gang que persista o XP.

**Verificação — não existe save de XP no arquivo:**
```lua
-- Gang.lua não possui nenhum addEventHandler("onResourceStop", ...) que salve XP
```

---

### 3.3 Metadados da Gang (tag, slogan, cor)

**Arquivo:** `Class/Gang.lua`

**Funções afetadas:**
- `Gang:setTagName()` — atualiza `self.tag` e dados do team, mas **sem query ao banco**
- `Gang:setSlogan()` — atualiza `self.slogan` e dados do team, mas **sem query ao banco**
- `Gang:setColor()` — atualiza `self.color` e cor do team, mas **sem query ao banco**

**Consequência:** Um líder pode alterar a tag, slogan ou cor da gang durante o jogo. Se o servidor reiniciar, a gang voltará com os valores antigos do banco.

**Exceções (salvam em tempo real):**
- `Gang:dispose()` → deleta do banco imediatamente ✅
- Criação de gang (`/gang criar`) → insere no banco imediatamente ✅

---

### 3.4 Saldo Bancário

**Arquivo:** `Inits/bank/BankSystem_s.lua`

**O que acontece em cada transação:**
```lua
-- Saque
client:setData("bank_balance", tonumber(bankBalance - quantity))  -- só RAM

-- Depósito
client:setData("bank_balance", tonumber(bankBalance + quantity))  -- só RAM

-- Transferência
client:setData("bank_balance", tonumber(clientBalance - quantity))      -- só RAM
playerElement:setData("bank_balance", tonumber(playerBalance + quantity)) -- só RAM
```

**Problema:** Todas as transações bancárias alteram apenas `setData` (memória do servidor MTA). O saldo **só é salvo no banco** quando `Account:saveData()` é chamado (quit/stop). Uma transferência para um jogador que está online mas o servidor trava antes do quit resulta em perda da transação.

---

### 3.5 Propriedades (Owner)

**Arquivo:** `Class/Properties.lua`, função `Properties:setOwner()`

```lua
function Properties:setOwner(owner)
    if not owner then
        self.owner = nil
        self.pickup:setData("owner", nil)  -- só RAM
        self.blip:setIcon(31)
    else
        self.owner = owner
        self.pickup:setData("owner", self.owner)  -- só RAM
        self.blip:setIcon(32)
    end
    -- NENHUMA query ao banco!
end
```

**Quando é salvo:** Apenas em `Properties.onResourceStop()` (registrado em `onResourceStop`).

**Consequência:** Um jogador compra uma propriedade, mas se o recurso reiniciar sem passar pelo stop (crash), a propriedade volta ao estado anterior.

---

### 3.6 O que JÁ funciona em tempo real (Servidor → Banco)

#### Territórios (Area ownership)

**Arquivo:** `Class/Area.lua`, função `Area:persistOwnerNow()`

```lua
-- Area.lua linha 485-499
function Area:persistOwnerNow()
    local result = Area.database:select("name"):where("name", self.name):getSingle()
    if not result then
        return Area.database:insert({...}):execute()
    end
    return Area.database:update({
        ['owner'] = self.owner,
        ['type'] = self.type
    }):where("name", self.name):execute()
end
```

Esta função é chamada dentro de `Area:setOwner()` sempre que o owner muda, garantindo persistência imediata. **Este é o único sistema com sincronização completa no sentido Servidor → Banco.**

---

## 4. Análise: Banco de Dados → Servidor

### 4.1 Por que mudanças no banco não refletem no servidor

O servidor **nunca consulta o banco novamente** para dados já carregados. Não existe:
- Timer de polling que releia o banco periodicamente;
- Mecanismo de notificação do MySQL (triggers → callback Lua);
- Comando administrativo para forçar reload de dados específicos;
- Qualquer forma de "push" de alterações externas para o servidor.

**Ciclo de vida dos dados:**
```
1. onResourceStart → SELECT * FROM tabela → dados carregados para RAM
2. (servidor roda, dados vivem apenas em RAM)
3. DBA altera diretamente no banco → servidor NUNCA sabe disso
4. onResourceStop → dados da RAM são gravados de volta → sobrescrevem a alteração do DBA
```

**Isso significa que:**
- Dar XP a uma gang diretamente no banco → não tem efeito no servidor em execução
- Alterar o owner de um território diretamente no banco → não tem efeito (e será sobrescrito no stop)
- Banir/desbanir um jogador editando o banco → não desconecta o jogador em tempo real
- Alterar o saldo bancário de um jogador no banco → não tem efeito até o próximo login

### 4.2 Limitação técnica do MTA Lua

O módulo de banco de dados do MTA (`dbConnect`, `dbQuery`, `dbPoll`) é **completamente síncrono por demanda** — o servidor Lua só executa queries quando o código Lua as dispara. O MySQL não tem como "empurrar" dados para o servidor Lua.

---

## 5. Mapa Completo de Gaps de Sincronização

```
[Banco de Dados MySQL]          [Servidor MTA (RAM)]
        │                               │
        │  onResourceStart              │
        │ ─────────────────────────────>│  (leitura única)
        │                               │
        │                               │  kills++, money--, gang XP++
        │                               │  bank_balance--, properties change
        │                               │  (tudo só na RAM)
        │                               │
        │  onPlayerQuit (saveData)      │
        │ <─────────────────────────────│  (salva dados do jogador)
        │                               │
        │  ADMIN edita banco            │
        │ ─────────────────────────────X│  (servidor NUNCA recebe)
        │                               │
        │  onResourceStop               │
        │ <─────────────────────────────│  (salva tudo, sobrescreve edições do admin)
        │                               │
```

**Exceção:** Territórios (Area) → `persistOwnerNow()` faz a seta `RAM → DB` em tempo real.

---

## 6. O Que É Necessário Para Sincronização Completa

### 6.1 Servidor → Banco de Dados (imediato)

#### Prioridade Alta

**1. Gang XP — salvar após cada alteração**

Em `Gang:setXP()`, `Gang:incrementXP()`, `Gang:decrementXP()`:
```lua
function Gang:incrementXP(xp)
    self.xp = self:getXP() + xp
    if self.team then
        self.team:setData("xp", self.xp)
    end
    -- ADICIONAR:
    Gang.database:update({ ['xp'] = tostring(self.xp) }):where("name", self.name):execute()
    return true
end
```

**2. Saldo Bancário — salvar após cada transação**

Em `BankSystem_s.lua`, após cada `setData("bank_balance", ...)`:
```lua
-- Após alterar o saldo do cliente:
local accountClass = Account.getInstance()
accountClass:saveData(client)  -- ou uma função saveBalance(player) mais específica
```

**3. Metadados da Gang (tag, slogan, cor) — salvar ao alterar**

Em `Gang:setTagName()`, `Gang:setSlogan()`, `Gang:setColor()`:
```lua
function Gang:setTagName(tagName)
    -- lógica atual...
    -- ADICIONAR:
    Gang.database:update({ ['tag'] = self.tag }):where("name", self.name):execute()
end
```

#### Prioridade Média

**4. Propriedades — salvar ao trocar de dono**

Em `Properties:setOwner()`:
```lua
function Properties:setOwner(owner)
    self.owner = owner
    self.pickup:setData("owner", self.owner)
    self.blip:setIcon(owner and 32 or 31)
    -- ADICIONAR:
    local result = Properties.database:select("name"):where("name", self.name):getSingle()
    if not result then
        Properties.database:insert({ ['name'] = self.name, ['owner'] = self.owner }):execute()
    else
        Properties.database:update({ ['owner'] = self.owner or "NULL" }):where("name", self.name):execute()
    end
end
```

**5. Timer periódico de save para dados do jogador**

Criar um timer global que salva todos os jogadores conectados a cada 5 minutos:
```lua
-- Em Account.lua ou main.lua
setTimer(function()
    local accountClass = Account.getInstance()
    for _, player in pairs(getElementsByType("player")) do
        if player:getData("account") then
            accountClass:saveData(player)
        end
    end
    outputDebugString("[Account] Periodic save completed.")
end, 300000, 0) -- a cada 5 minutos
```

---

### 6.2 Banco de Dados → Servidor (leitura em tempo real)

Esta direção é fundamentalmente mais difícil no modelo MTA Lua. As opções viáveis são:

#### Opção A: Polling periódico (mais simples)

Criar um timer que relê dados críticos do banco a cada N segundos. Adequado para dados que mudam raramente via admin direto:

```lua
-- Exemplo: recarregar XP de gangs a cada 60 segundos
setTimer(function()
    local result = Gang.database:select():getAll()
    for _, row in pairs(result) do
        local gang = Gang.getFromName(row.name)
        if gang and tonumber(row.xp) ~= gang.xp then
            gang.xp = tonumber(row.xp)
            if gang.team then
                gang.team:setData("xp", gang.xp)
            end
        end
    end
end, 60000, 0)
```

**Prós:** Simples de implementar, sem dependências externas.  
**Contras:** Latência de até N segundos, overhead de queries contínuas.

#### Opção B: Comandos de reload administrativos

Adicionar comandos que forçam recarga de dados específicos do banco:

```lua
-- /reloadgang [nome] — recarrega dados de uma gang do banco
addCommandHandler("reloadgang", function(player, cmd, gangName)
    if not isAdmin(player) then return end
    local result = Gang.database:select():where("name", gangName):getSingle()
    if result then
        local gang = Gang.getFromName(gangName)
        if gang then
            gang.xp = tonumber(result.xp) or 0
            gang.tag = result.tag
            gang.slogan = result.slogan
            -- atualizar team data...
            player:outputChat("[ADMIN] Gang recarregada do banco.")
        end
    end
end)
```

**Prós:** Preciso, sem overhead contínuo, controlado pelo admin.  
**Contras:** Requer intervenção manual.

#### Opção C: HTTP webhook externo (avançado)

Criar um endpoint HTTP no servidor MTA (via `fetchRemote` / `httpRequestHandler`) que aceita chamadas externas (de um painel admin, script externo, etc.) e força atualizações em memória:

```lua
-- No servidor MTA:
addEventHandler("onResourceStart", resourceRoot, function()
    addHttpHandler("/reload-gang", function(request, response)
        -- recebe POST com { gangName, newXP, newTag, ... }
        -- atualiza dados em memória
    end)
end)
```

**Prós:** Totalmente automatizável, integrável com painel web.  
**Contras:** Requer configuração de servidor HTTP, segurança adicional necessária.

#### Opção D: MySQL EVENT/Trigger + tabela de notificações

Criar uma tabela `tbl_pending_updates` no banco. Quando um admin altera dados, um trigger MySQL insere nessa tabela. O servidor Lua faz polling somente nessa tabela leve:

```sql
-- Trigger MySQL (exemplo):
CREATE TRIGGER after_gang_update
AFTER UPDATE ON tbl_gangs
FOR EACH ROW
INSERT INTO tbl_pending_updates (type, entity, payload, created_at)
VALUES ('gang_update', NEW.name, JSON_OBJECT('xp', NEW.xp, 'tag', NEW.tag), NOW());
```

```lua
-- Lua polling a cada 5s apenas nessa tabela leve:
setTimer(function()
    local result = Database():custom("SELECT * FROM tbl_pending_updates WHERE processed = 0"):getAll()
    for _, row in pairs(result or {}) do
        -- processar atualização...
        Database():custom("UPDATE tbl_pending_updates SET processed=1 WHERE id=?", row.id):execute()
    end
end, 5000, 0)
```

**Prós:** Separação de responsabilidades limpa, baixo overhead.  
**Contras:** Requer acesso DDL ao banco, maior complexidade.

---

## 7. Tabela de Prioridades de Implementação

| Item | Direção | Impacto | Complexidade | Prioridade |
|---|---|---|---|---|
| Salvar Gang XP em tempo real | Servidor → DB | Alto (XP perdido em crash) | Baixa | 🔴 Alta |
| Salvar saldo bancário em tempo real | Servidor → DB | Alto (dinheiro perdido) | Baixa | 🔴 Alta |
| Timer periódico de save do jogador (5 min) | Servidor → DB | Alto (anti perda de progresso) | Baixa | 🔴 Alta |
| Salvar tag/slogan/cor da gang em tempo real | Servidor → DB | Médio | Baixa | 🟡 Média |
| Salvar ownership de propriedades em tempo real | Servidor → DB | Médio | Baixa | 🟡 Média |
| Comandos de reload administrativos | DB → Servidor | Médio | Baixa | 🟡 Média |
| Polling periódico de dados críticos | DB → Servidor | Médio | Média | 🟡 Média |
| HTTP webhook para atualizações externas | DB → Servidor | Alto | Alta | 🟢 Baixa |
| MySQL triggers + tabela de notificações | DB → Servidor | Alto | Alta | 🟢 Baixa |

---

## 8. Sistemas Já Corretos (Referência)

Os seguintes sistemas já possuem persistência correta em tempo real e servem de modelo para os demais:

### 8.1 Territórios (Area) — modelo de referência

```lua
-- Area.lua: setOwner() chama persistOwnerNow() imediatamente
function Area:setOwner(team)
    -- ... atualiza memória ...
    if previousOwner ~= self.owner and not Area.isBootstrapping then
        if not self:persistOwnerNow() then  -- ← grava no banco imediatamente
            outputDebugString("ERROR SAVE AREA OWNER: ...")
        end
    end
end
```

### 8.2 Criação e Deleção de Gangs

```lua
-- Gang.lua: INSERT imediato ao criar
Gang.database:insert({...}):execute()

-- Gang.lua: DELETE imediato ao deletar
Gang.database:delete():where("name", self.name):execute()
```

---

## 9. Resumo dos Gaps Encontrados no Código

### `Class/Gang.lua`
- ❌ `Gang:setXP()` / `Gang:incrementXP()` / `Gang:decrementXP()` — sem persistência
- ❌ `Gang:setTagName()` — sem persistência
- ❌ `Gang:setSlogan()` — sem persistência
- ❌ `Gang:setColor()` — sem persistência
- ❌ Ausência de `onResourceStop` para salvar XP/metadados

### `Class/Properties.lua`
- ❌ `Properties:setOwner()` — sem persistência imediata
- ⚠️ Só persiste em `onResourceStop`

### `Class/Account.lua`
- ⚠️ `Account:saveData()` chamado apenas em quit/stop
- ❌ Sem timer periódico de save

### `Inits/bank/BankSystem_s.lua`
- ❌ Transações bancárias não disparam `saveData()`

### Geral
- ❌ Nenhum mecanismo de reload de dados externos (DB → Servidor)

---

## 10. Conclusão

O servidor mta-gangwar usa um modelo de persistência **lazy** (preguiçoso): carrega tudo ao iniciar e salva apenas quando necessário (quit/stop). Isso é intencional na maioria dos servidores MTA para performance, mas cria os seguintes riscos:

1. **Perda de progresso** em caso de crash antes do save
2. **Inconsistência** entre o que o banco mostra e o que o servidor tem na memória
3. **Impossibilidade de administração externa** sem reiniciar o recurso

As correções de maior impacto e menor complexidade são:
1. Salvar Gang XP após cada mudança
2. Salvar saldo bancário após cada transação
3. Adicionar um timer de save periódico para dados do jogador (a cada 5 min)
4. Salvar metadados da gang (tag/slogan/cor) ao alterá-los
5. Salvar ownership de propriedades ao trocar de dono

O modelo de referência para persistência correta já existe no código: **`Area:persistOwnerNow()`** — basta aplicar o mesmo padrão aos demais sistemas.
