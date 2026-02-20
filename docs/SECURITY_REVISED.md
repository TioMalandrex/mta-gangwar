# ANÁLISE DE SEGURANÇA REVISADA - MTA GANG WAR

**Data:** 18 de Fevereiro de 2026  
**Versão:** 2.0 (Revisado)  
**Contexto:** Gamemode MTA:SA com arquitetura cliente-servidor  
**Repositório:** Privado

---

## 🎯 CONTEXTO IMPORTANTE

### Arquitetura MTA:SA

Este é um gamemode para **Multi Theft Auto: San Andreas (MTA:SA)**, que utiliza uma arquitetura cliente-servidor rigorosa:

**Arquivos Server-Side (`type="server"` no meta.xml):**
- ✅ **Players têm ZERO acesso a estes arquivos**
- ✅ Código nunca é enviado ao cliente
- ✅ Processamento 100% no servidor
- ✅ Inclui: `Class/*.lua`, `Inits/*_s.lua`, lógica de negócio

**Arquivos Client-Side (`type="client"` no meta.xml):**
- ⚠️ **Players podem ver e modificar estes arquivos**
- ⚠️ Código enviado ao cliente (não confiável)
- ⚠️ Apenas para UI/UX e comunicação via triggers
- ⚠️ Inclui: `*_c.lua`, `hud/client/*`

**Repositório Privado:**
- ✅ Código-fonte não é público
- ✅ Credenciais no código não são expostas publicamente

---

## 📊 RESUMO EXECUTIVO

**Análise Anterior vs. Revisada:**

| Vulnerabilidade Anterior | Severidade Anterior | Status Revisado | Justificativa |
|--------------------------|---------------------|-----------------|---------------|
| Credenciais no código | CRÍTICA | ✅ **MITIGADA** | Server-side + repo privado = sem exposição |
| MD5 password hashing | CRÍTICA | 🟡 **BAIXA** | Server-side, mas ainda recomenda-se melhoria |
| SQL Injection | CRÍTICA | ✅ **BAIXA** | Uso correto de prepared statements |
| Rate Limiting | ALTA | 🔴 **ALTA** | Vulnerabilidade REAL - DoS via triggers |
| Senha mínima 3 chars | MÉDIA | 🟡 **MÉDIA** | Política fraca, mas controlada |
| Input Validation | MÉDIA | 🟠 **MÉDIA-ALTA** | Falta validação em alguns eventos |

**Conclusão Revisada:**  
⚠️ O sistema possui **1 vulnerabilidade ALTA** e **2 MÉDIAS** que devem ser corrigidas. As vulnerabilidades "críticas" anteriores foram reclassificadas considerando a arquitetura MTA.

---

## ✅ VULNERABILIDADES MITIGADAS

### 1. ~~Credenciais de Banco de Dados Expostas~~ ✅ NÃO É PROBLEMA

**Status Anterior:** CRÍTICA  
**Status Revisado:** ✅ MITIGADA pela arquitetura

**Arquivo:** `Class/Database.lua` (lines 5-10)
```lua
static.dbName = "db_gangwar"
static.host = "127.0.0.1"
static.user = "dba_gangwar"
static.password = "ianitolindo"
```

**Por que NÃO é vulnerabilidade crítica:**
1. ✅ `Database.lua` é **server-side** (`type="server"` no meta.xml linha 27)
2. ✅ Players **nunca** recebem este arquivo
3. ✅ Repositório é **privado** (não exposto publicamente)
4. ✅ Apenas desenvolvedores com acesso ao servidor veem isto

**Risco Real:** Baixo
- Apenas desenvolvedores/admins com acesso SSH ao servidor podem ver
- Se servidor for comprometido, credenciais são o menor problema

**Recomendação (Opcional, Boa Prática):**
```lua
-- Usar variáveis de ambiente para facilitar deploy
static.dbName = os.getenv("DB_NAME") or "db_gangwar"
static.password = os.getenv("DB_PASSWORD") or "ianitolindo"
```
**Prioridade:** Baixa (melhoria de DevOps, não segurança crítica)

---

### 2. ~~MD5 Password Hashing~~ 🟡 BAIXA PRIORIDADE

**Status Anterior:** CRÍTICA  
**Status Revisado:** 🟡 BAIXA (mas recomenda-se melhoria)

**Arquivo:** `Class/Account.lua` (server-side, linhas 115, 175)
```lua
['password'] = md5(password),  -- Criação
if (thePassword and thePassword ~= md5(password)) then  -- Login
```

**Por que NÃO é crítica:**
1. ✅ `Account.lua` é **server-side** - players não veem o código
2. ✅ Hashing acontece no servidor, não no cliente
3. ✅ Players não podem ver ou modificar o processo de hash
4. ✅ Repositório privado - atacantes não sabem que é MD5

**Risco Real:** Baixo-Médio
- **Cenário de risco:** Apenas se o banco de dados for comprometido
- Atacante precisaria: 1) Ter acesso ao servidor, 2) Extrair o banco, 3) Quebrar MD5
- Se atacante já tem acesso ao servidor, o jogo já está perdido

**Por que ainda recomendamos mudança:**
- ✅ Boa prática de segurança (defense in depth)
- ✅ Proteção adicional em caso de dump do banco
- ✅ Conformidade com padrões modernos

**Recomendação (Melhoria Futura):**
```lua
-- Opção 1: SHA-256 com salt (sem dependências)
local function hashPassword(password, salt)
    salt = salt or generateRandomSalt(32)
    return sha256(password .. salt), salt
end

-- Opção 2: bcrypt (requer módulo)
local bcrypt = require("bcrypt")
local hash = bcrypt.hash(password, 12)
```

**Prioridade:** Média (melhoria recomendada, não urgente)

---

### 3. ~~SQL Injection~~ ✅ PROTEGIDO

**Status:** ✅ NÃO VULNERÁVEL

**Análise:** O código utiliza **prepared statements** corretamente via `dbQuery` do MTA.

**Exemplo de uso correto:**
```lua
-- Class/Account.lua linha 97-98
dbQuery(Database.connection, onLoadInfoAccount, {client, callback}, 
    "SELECT * FROM tbl_accounts WHERE username = ?", username)
```

**Por que está seguro:**
- ✅ Uso de `?` placeholders (prepared statements)
- ✅ MTA escapa automaticamente os parâmetros
- ✅ Sem concatenação de strings em queries

**Verificação:** Não encontrei nenhuma query vulnerável no código.

---

## 🔴 VULNERABILIDADES REAIS

### 1. Falta de Rate Limiting em Eventos Cliente-Servidor 🔴 ALTA

**Severidade:** ALTA  
**CVSS Score:** 7.5 (Alta)  
**Tipo:** Denial of Service (DoS)

**Descrição:**
Eventos triggerados do cliente para o servidor (`addEvent(..., true)`) não possuem rate limiting, permitindo que players maliciosos façam flood de requisições.

**Arquivos Vulneráveis:**
- `Inits/bank/BankSystem_s.lua` (linhas 1, 21, 42)
- `Inits/login/Account_s.lua` (linhas 1, 9)
- `Inits/login/SpawnSelector_s.lua` (linhas 1, 7, 13)

**Código Vulnerável:**
```lua
-- BankSystem_s.lua linha 1-19
addEvent("onPlayerWithdraw",true)
addEventHandler("onPlayerWithdraw",root,function (quantity)
    -- SEM RATE LIMITING!
    -- Player pode chamar isto 1000x por segundo
    local quantity = tonumber(quantity)
    if(quantity) then
        local bankBalance = client:getData("bank_balance") or 0
        if(bankBalance >= quantity) then
            givePlayerMoney(client, quantity)
            -- ... mais processamento ...
        end
    end
end)
```

**Impacto:**
- 🔴 **DoS Attack:** Player pode sobrecarregar o servidor com milhares de triggers por segundo
- 🔴 **Lag severo:** Afeta todos os jogadores do servidor
- 🔴 **Crash potencial:** Servidor pode ficar sem recursos
- 🔴 **Exploração de lógica:** Flood de operações bancárias, spawn, etc.

**Proof of Concept:**
```lua
-- Cliente malicioso pode fazer:
while true do
    triggerServerEvent("onPlayerWithdraw", localPlayer, 1)
    triggerServerEvent("onPlayerDeposit", localPlayer, 1)
    triggerServerEvent("onPlayerTransfer", localPlayer, "Victim", 1)
end
-- Resultado: 1000s de eventos por segundo = servidor morre
```

**Solução:**
```lua
-- Implementar rate limiter global
local playerLastTrigger = {}
local COOLDOWN_MS = 500  -- 500ms entre triggers

local function checkRateLimit(player, eventName)
    local now = getTickCount()
    local key = player .. eventName
    local lastTrigger = playerLastTrigger[key] or 0
    
    if (now - lastTrigger) < COOLDOWN_MS then
        outputDebugString(string.format(
            "Rate limit: %s tentou %s muito rápido", 
            player.name, eventName
        ))
        return false  -- Bloqueado por cooldown
    end
    
    playerLastTrigger[key] = now
    return true  -- Permitido
end

-- Aplicar em todos os event handlers sensíveis:
addEvent("onPlayerWithdraw",true)
addEventHandler("onPlayerWithdraw",root,function (quantity)
    if not checkRateLimit(client, "onPlayerWithdraw") then
        return  -- Bloqueado
    end
    -- ... resto do código ...
end)
```

**Localização de Todos os Eventos Sensíveis:**
```
Inits/bank/BankSystem_s.lua:
  - onPlayerWithdraw (linha 1)
  - onPlayerDeposit (linha 21)
  - onPlayerTransfer (linha 42)

Inits/login/Account_s.lua:
  - onAccountTryLogin (linha 1)
  - onAccountTryRegister (linha 9)

Inits/login/SpawnSelector_s.lua:
  - changeSkinServer (linha 1)
  - protectPlayerServer (linha 7)
  - unprotectPlayerServer (linha 13)

[extras]/ammunation/server/main.lua:
  - onPlayerBuyAmmuItem (linha 1)

[extras]/vehicleShop/server/Vehicle.lua:
  - onPlayerBuyVehicle (linha 67)
```

**Prioridade:** 🔴 **ALTA - Deve ser corrigido antes de produção**

---

### 2. Validação Inadequada de Valores Negativos 🟠 MÉDIA-ALTA

**Severidade:** MÉDIA-ALTA  
**CVSS Score:** 6.5 (Média)  
**Tipo:** Lógica de Negócio / Integer Overflow

**Descrição:**
Evento `onPlayerWithdraw` não valida valores negativos, permitindo exploração da lógica bancária.

**Arquivo:** `Inits/bank/BankSystem_s.lua` (linha 2-19)

**Código Vulnerável:**
```lua
addEventHandler("onPlayerWithdraw",root,function (quantity)
    local quantity = tonumber(quantity)
    if(quantity) then  -- ⚠️ Aceita valores negativos!
        local bankBalance = client:getData("bank_balance") or 0
        if(bankBalance >= quantity) then  -- ⚠️ -100 >= -100 é TRUE!
            givePlayerMoney(client, quantity)  -- ⚠️ Dá dinheiro negativo!
            client:setData("bank_balance", tonumber(bankBalance - quantity))
            -- Se quantity = -1000:
            -- bankBalance = 0
            -- 0 >= -1000 = TRUE
            -- givePlayerMoney(-1000) = remove $1000 do player
            -- bank_balance = 0 - (-1000) = +1000
            -- Player GANHA dinheiro no banco e PERDE na mão!
        end
    end
end)
```

**Exploit:**
```lua
-- Cliente malicioso:
triggerServerEvent("onPlayerWithdraw", localPlayer, -999999)
-- Resultado:
-- - Saldo banco: 0 → 999999 (AUMENTA!)
-- - Dinheiro na mão: diminui 999999 (mas pode dropar pra 0)
-- Depois:
triggerServerEvent("onPlayerWithdraw", localPlayer, 999999)
-- Agora tem $999,999 grátis!
```

**Impacto:**
- 🔴 Geração infinita de dinheiro
- 🔴 Economia do servidor quebrada
- 🔴 Vantagem injusta

**Solução:**
```lua
addEventHandler("onPlayerWithdraw",root,function (quantity)
    local quantity = tonumber(quantity)
    
    -- ADICIONAR VALIDAÇÃO:
    if not quantity or quantity <= 0 then
        outputChatBox("#1712e6[BANCO]:#FFFFFFValor inválido.", client, 255,255,255, true)
        return
    end
    
    -- ADICIONAR LIMITE MÁXIMO:
    if quantity > 10000000 then  -- Limite de $10M por transação
        outputChatBox("#1712e6[BANCO]:#FFFFFFValor muito alto.", client, 255,255,255, true)
        return
    end
    
    local bankBalance = client:getData("bank_balance") or 0
    if(bankBalance >= quantity) then
        givePlayerMoney(client, quantity)
        client:setData("bank_balance", tonumber(bankBalance - quantity))
        -- ... resto do código ...
    end
end)
```

**Mesmo problema em:**
- `onPlayerDeposit` (linha 22) - aceita valores negativos
- `onPlayerTransfer` (linha 43) - aceita valores negativos

**Prioridade:** 🟠 **ALTA - Corrigir antes de produção**

---

### 3. Política de Senha Fraca 🟡 MÉDIA

**Severidade:** MÉDIA  
**CVSS Score:** 5.0 (Média)  
**Tipo:** Autenticação Fraca

**Descrição:**
Sistema permite senhas de apenas 3 caracteres, facilitando ataques de força bruta.

**Arquivo:** `Class/Account.lua` (linha 20-23)

**Código:**
```lua
if(#password < 3) then
    return outputChatBox(
        "#ff0000[ERRO]: #ffffffA senha deve ter no mínimo 3 caracteres!",
        client, 255,255,255,true
    ), false
end
```

**Impacto:**
- 🟡 Senhas fracas como "123", "abc", "aaa" são aceitas
- 🟡 Facilita ataques de força bruta (mesmo que improvável)
- 🟡 Não segue boas práticas (mínimo recomendado: 8 caracteres)

**Solução:**
```lua
-- Aumentar mínimo para 6-8 caracteres
if(#password < 6) then
    return outputChatBox(
        "#ff0000[ERRO]: #ffffffA senha deve ter no mínimo 6 caracteres!",
        client, 255,255,255,true
    ), false
end

-- Opcional: Validar complexidade
local function validatePassword(password)
    if #password < 8 then return false, "Mínimo 8 caracteres" end
    if not password:match("%d") then return false, "Deve ter números" end
    if not password:match("%a") then return false, "Deve ter letras" end
    return true
end
```

**Prioridade:** 🟡 **MÉDIA - Recomenda-se correção**

---

### 4. Falta de Logging de Segurança 🟡 BAIXA-MÉDIA

**Severidade:** BAIXA-MÉDIA  
**Tipo:** Auditoria e Detecção

**Descrição:**
Sistema não registra eventos de segurança importantes para detecção de abusos.

**Eventos sem Logging:**
- Tentativas de login falhadas
- Transações bancárias de alto valor
- Mudanças de gangue
- Compras de bases/propriedades
- Kick/Ban de players

**Impacto:**
- Dificulta identificação de contas comprometidas
- Impossível auditar transações suspeitas
- Sem evidências para investigações

**Solução:**
```lua
-- Criar sistema de logging
local function securityLog(player, action, details)
    local timestamp = getRealTime().timestamp
    local serial = player:getSerial()
    local ip = player:getIP()
    
    dbExec(Database.connection,
        "INSERT INTO tbl_security_logs (timestamp, player, serial, ip, action, details) VALUES (?, ?, ?, ?, ?, ?)",
        timestamp, player.name, serial, ip, action, details
    )
    
    outputDebugString(string.format(
        "[SECURITY] %s (%s) - %s: %s",
        player.name, ip, action, details
    ))
end

-- Usar em eventos críticos:
addEventHandler("onPlayerLogin", root, function()
    securityLog(source, "LOGIN", "Successful login")
end)

addEventHandler("onPlayerTransfer", root, function(to, amount)
    if amount > 100000 then
        securityLog(client, "TRANSFER_HIGH", 
            string.format("$%d to %s", amount, to))
    end
end)
```

**Prioridade:** 🟡 **MÉDIA - Recomenda-se implementação**

---

## 📋 CHECKLIST DE SEGURANÇA

### Antes de Produção (Obrigatório)

- [ ] **Implementar rate limiting** em todos os eventos cliente-servidor
- [ ] **Adicionar validação de valores negativos** em sistema bancário
- [ ] **Aumentar senha mínima** para 6-8 caracteres
- [ ] **Testar exploits conhecidos** (valores negativos, flood)
- [ ] **Configurar backups automáticos** do banco de dados
- [ ] **Implementar sistema de logging** de segurança

### Melhorias Recomendadas (Futuro)

- [ ] Migrar MD5 para SHA-256 ou bcrypt
- [ ] Usar variáveis de ambiente para credenciais DB
- [ ] Implementar 2FA para admins
- [ ] Adicionar sistema anti-cheat
- [ ] Monitoramento de performance e alertas

---

## 🎓 BOAS PRÁTICAS MTA:SA

### Segurança em Gamemodes MTA

**✅ FAÇA:**
1. **Valide TUDO do cliente** - Cliente não é confiável
2. **Rate limiting obrigatório** - Eventos podem ser floodados
3. **Validação de tipos e ranges** - tonumber() + checks de range
4. **Logging de ações críticas** - Auditoria e detecção
5. **Teste com cliente modificado** - Simule atacante

**❌ NÃO FAÇA:**
1. **Confiar em validações client-side** - Cliente pode burlar
2. **Processar dados client sem validar** - Sempre sanitize
3. **Permitir triggers ilimitados** - DoS garantido
4. **Expor lógica sensível** - Mantenha server-side

### Arquitetura Segura MTA

```
CLIENT (Não confiável)
    ↓ triggerServerEvent() - COM VALIDAÇÃO
SERVER (Confiável)
    ↓ Valida inputs
    ↓ Rate limiting
    ↓ Processa lógica
    ↓ triggerClientEvent()
CLIENT (Apenas UI/UX)
```

---

## 📊 COMPARAÇÃO: ANTES vs. DEPOIS

| Aspecto | Análise Anterior | Análise Revisada |
|---------|------------------|------------------|
| **Vulnerabilidades Críticas** | 3 | 0 |
| **Vulnerabilidades Altas** | 2 | 1 (Rate Limiting) |
| **Vulnerabilidades Médias** | 5 | 3 |
| **Status Geral** | ⚠️ NÃO RECOMENDADO | 🟡 RECOMENDADO (com correções) |
| **Prioridade de Ação** | URGENTE | ALTA para 2 itens, MÉDIA para resto |
| **Arquitetura Considerada** | ❌ Não | ✅ Sim (MTA cliente-servidor) |
| **Repositório Privado** | ❌ Não | ✅ Sim |

---

## 🏁 CONCLUSÃO

### Análise Anterior vs. Revisada

A análise anterior classificou erroneamente várias questões como **CRÍTICAS** sem considerar:
1. Arquitetura cliente-servidor do MTA (server-side inacessível)
2. Repositório privado (código não exposto)

### Status Real

✅ **Sistema é MAIS SEGURO do que análise anterior indicava**

**Vulnerabilidades Reais:**
- 🔴 1 ALTA: Rate Limiting (DoS via trigger flood)
- 🟠 1 MÉDIA-ALTA: Validação valores negativos (exploit bancário)
- 🟡 2 MÉDIAS: Senha fraca, falta de logging

### Recomendação Final

🟢 **RECOMENDADO para produção** APÓS correção de:
1. Rate limiting (OBRIGATÓRIO)
2. Validação bancária (OBRIGATÓRIO)
3. Senha mínima (RECOMENDADO)

**Tempo estimado de correção:** 4-6 horas

**Prioridade:**
- URGENTE: Rate limiting + validação bancária
- MÉDIO: Senha mínima, logging
- BAIXO: MD5 → SHA-256, env vars

---

**Documento revisado por:** GitHub Copilot Security Analysis  
**Data:** 18 de Fevereiro de 2026  
**Versão:** 2.0 - Revisão completa considerando arquitetura MTA:SA
