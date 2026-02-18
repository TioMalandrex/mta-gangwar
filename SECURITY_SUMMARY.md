# SUMÁRIO DE SEGURANÇA - MTA GANG WAR

**Data:** 18 de Fevereiro de 2026  
**Versão:** 1.0  
**Status:** ⚠️ VULNERABILIDADES CRÍTICAS IDENTIFICADAS

---

## 🔴 VULNERABILIDADES CRÍTICAS

### 1. Uso de MD5 para Hashing de Senhas

**Severidade:** CRÍTICA  
**CVSS Score:** 8.1 (Alto)  
**Arquivo:** `Class/Account.lua` (linhas 115, 175)

**Descrição:**
O sistema utiliza MD5 para fazer hash de senhas de usuários, um algoritmo criptográfico considerado quebrado desde 2004.

**Código Vulnerável:**
```lua
['password'] = md5(password),  -- Linha 115
if (thePassword and thePassword ~= md5(password)) then  -- Linha 175
```

**Riscos:**
- Rainbow tables podem reverter hashes MD5 em segundos
- Sem salt, senhas idênticas geram hashes idênticos
- Ataques de força bruta são extremamente eficientes
- Não atende padrões OWASP ou PCI-DSS
- Comprometimento total de credenciais em caso de leak do banco de dados

**Impacto:**
- ALTO: Todas as senhas de usuários estão vulneráveis
- Dados de ~100% dos usuários em risco

**Recomendação:**
```lua
-- Usar bcrypt (requer módulo externo) ou no mínimo SHA-256 com salt
local bcrypt = require("bcrypt")
local hash = bcrypt.hash(password, 12)  -- 12 rounds de hashing

-- Para verificação:
local valid = bcrypt.verify(password, storedHash)
```

**Alternativa sem dependências externas:**
```lua
-- Usar SHA-256 com salt único por usuário
local salt = generateRandomSalt(32)  -- 32 bytes aleatórios
local hash = sha256(password .. salt)
-- Armazenar: hash + salt (concatenados ou em colunas separadas)
```

**Prioridade:** URGENTE - Deve ser corrigido antes de qualquer deploy em produção

---

### 2. Credenciais de Banco de Dados Expostas no Código

**Severidade:** CRÍTICA  
**CVSS Score:** 9.0 (Crítico)  
**Arquivo:** `Class/Database.lua` (linhas 5-10)

**Descrição:**
Credenciais do banco de dados MySQL estão hardcoded no código-fonte.

**Código Vulnerável:**
```lua
static.dbName = "db_gangwar"
static.host = "127.0.0.1"
static.user = "dba_gangwar"
static.password = "ianitolindo"  -- ⚠️ SENHA EXPOSTA
static.port = "3306"
```

**Riscos:**
- Credenciais visíveis no repositório Git público
- Expostas em todo o histórico de commits
- Qualquer pessoa com acesso ao código tem acesso ao banco
- Violação de compliance (SOC 2, ISO 27001)
- Impossível rotacionar credenciais sem modificar código

**Impacto:**
- CRÍTICO: Acesso total ao banco de dados
- Possibilidade de exfiltração de todos os dados de usuários
- Modificação ou deleção de dados
- Comprometimento total do sistema

**Recomendação Imediata:**
```lua
-- Usar variáveis de ambiente
static.dbName = os.getenv("DB_NAME") or "db_gangwar"
static.host = os.getenv("DB_HOST") or "127.0.0.1"
static.user = os.getenv("DB_USER")
static.password = os.getenv("DB_PASSWORD")
static.port = os.getenv("DB_PORT") or "3306"

-- Validar que credenciais foram fornecidas
if not static.user or not static.password then
    error("Database credentials not configured!")
end
```

**OU criar arquivo de configuração externo:**
```lua
-- config/database.lua (adicionar ao .gitignore!)
return {
    dbName = "db_gangwar",
    host = "127.0.0.1",
    user = "dba_gangwar",
    password = "SuaSenhaAqui",
    port = "3306"
}

-- Em Database.lua:
local config = require("config.database")
static.dbName = config.dbName
-- etc...
```

**Ações Imediatas Necessárias:**
1. Rotacionar senha do banco de dados IMEDIATAMENTE
2. Adicionar config.lua ao .gitignore
3. Remover credenciais do histórico do Git (usando git filter-branch ou BFG Repo Cleaner)
4. Implementar variáveis de ambiente ou arquivo de configuração

**Prioridade:** CRÍTICA - Resolver AGORA

---

### 3. Injeção SQL Potencial

**Severidade:** ALTA  
**CVSS Score:** 7.5 (Alto)  
**Arquivo:** Múltiplos arquivos (`Gang.lua`, `Database.lua`)

**Descrição:**
Algumas queries usam concatenação de strings ao invés de prepared statements, abrindo potencial para SQL injection.

**Exemplo Vulnerável:**
```lua
-- Gang.lua:827
string.format([[UPDATE tbl_gangs SET xp ='%s',tag = %s WHERE name = '%s']], 
    Area.getOwnerXp(gang.name), gang.tag, gang.name)
```

**Riscos:**
- Injeção de SQL malicioso através de nomes de gangues
- Possível exfiltração de dados
- Modificação não autorizada de tabelas
- Deleção de dados

**Exemplo de Exploit:**
```lua
-- Se um jogador criar gangue com nome:
gangName = "MyGang'; DROP TABLE tbl_users; --"
-- A query se torna:
"UPDATE tbl_gangs SET ... WHERE name = 'MyGang'; DROP TABLE tbl_users; --'"
```

**Recomendação:**
```lua
-- Sempre usar placeholders
Gang.database:update({
    xp = Area.getOwnerXp(gang.name),
    tag = gang.tag
}):where("name", gang.name):execute()
```

**Mitigação Adicional:**
- Validar e sanitizar todos os inputs de usuário
- Limitar caracteres permitidos em nomes (alfanuméricos + espaços)
- Usar prepared statements exclusivamente

**Prioridade:** ALTA - Corrigir em 1-2 semanas

---

## 🟠 VULNERABILIDADES ALTAS

### 4. Ausência de Rate Limiting

**Severidade:** ALTA  
**CVSS Score:** 7.0  
**Arquivo:** `Inits/login/Account_s.lua`

**Descrição:**
Não há limitação de tentativas de login, permitindo ataques de força bruta.

**Riscos:**
- Atacante pode tentar milhares de senhas por minuto
- Dicionários de senhas comuns podem comprometer contas
- Degradação de performance do servidor

**Recomendação:**
```lua
local loginAttempts = {}
local MAX_ATTEMPTS = 5
local LOCKOUT_TIME = 300000  -- 5 minutos

function checkRateLimit(player)
    local serial = getPlayerSerial(player)
    if not loginAttempts[serial] then
        loginAttempts[serial] = {count = 0, lastAttempt = 0}
    end
    
    local now = getTickCount()
    if (now - loginAttempts[serial].lastAttempt) > LOCKOUT_TIME then
        loginAttempts[serial].count = 0
    end
    
    if loginAttempts[serial].count >= MAX_ATTEMPTS then
        outputChatBox("Muitas tentativas. Aguarde 5 minutos.", player)
        return false
    end
    
    loginAttempts[serial].count = loginAttempts[serial].count + 1
    loginAttempts[serial].lastAttempt = now
    return true
end
```

**Prioridade:** ALTA

---

### 5. Política de Senhas Fraca

**Severidade:** ALTA  
**CVSS Score:** 6.5  
**Arquivo:** `Class/Account.lua` (linha 92)

**Descrição:**
Senha mínima de apenas 3 caracteres, sem requisitos de complexidade.

**Código:**
```lua
if (#password < 3) then
    outputChatBox("A senha informada é muito pequena. (Min: 3)")
end
```

**Riscos:**
- Senhas triviais como "123" são aceitas
- Força bruta extremamente eficiente
- Usuários escolhem senhas fracas

**Recomendação:**
```lua
-- Requisitos mínimos de senha
local MIN_PASSWORD_LENGTH = 8
local REQUIRE_NUMBER = true
local REQUIRE_LETTER = true

function validatePassword(password)
    if #password < MIN_PASSWORD_LENGTH then
        return false, "Senha deve ter no mínimo 8 caracteres"
    end
    
    if REQUIRE_NUMBER and not password:match("%d") then
        return false, "Senha deve conter pelo menos um número"
    end
    
    if REQUIRE_LETTER and not password:match("%a") then
        return false, "Senha deve conter pelo menos uma letra"
    end
    
    -- Opcional: verificar contra lista de senhas comuns
    local commonPasswords = {"password", "123456", "qwerty", ...}
    for _, common in ipairs(commonPasswords) do
        if password:lower() == common then
            return false, "Senha muito comum, escolha outra"
        end
    end
    
    return true
end
```

**Prioridade:** ALTA

---

## 🟡 VULNERABILIDADES MÉDIAS

### 6. Falta de Validação de Tipos

**Severidade:** MÉDIA  
**CVSS Score:** 5.0

**Descrição:**
Funções não validam tipos de parâmetros, podendo causar erros ou comportamentos inesperados.

**Exemplo:**
```lua
function Account:login(player, name, password)
    -- Não verifica se player é elemento válido
    -- Não verifica tipos de name e password
end
```

**Recomendação:**
```lua
function Account:login(player, name, password)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false, "Invalid player"
    end
    if type(name) ~= "string" or type(password) ~= "string" then
        return false, "Invalid credentials"
    end
    if #name == 0 or #password == 0 then
        return false, "Empty credentials"
    end
    -- ... resto do código
end
```

**Prioridade:** MÉDIA

---

### 7. Ausência de Logs de Segurança

**Severidade:** MÉDIA  
**CVSS Score:** 4.5

**Descrição:**
Não há logging estruturado de eventos de segurança.

**Impacto:**
- Impossível detectar tentativas de invasão
- Sem auditoria de ações sensíveis
- Dificuldade em investigar incidentes

**Recomendação:**
```lua
-- Criar security_log.lua
function logSecurityEvent(eventType, player, details)
    local timestamp = getRealTime()
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)
    
    local logEntry = string.format(
        "[%s] %s | Player: %s | Serial: %s | IP: %s | Details: %s",
        timestamp, eventType, getPlayerName(player), 
        serial, ip, toJSON(details)
    )
    
    -- Escrever em arquivo
    local file = fileOpen("logs/security.log", true)
    fileSetPos(file, fileGetSize(file))
    fileWrite(file, logEntry .. "\n")
    fileClose(file)
end

-- Usar em eventos críticos:
logSecurityEvent("LOGIN_FAILED", player, {username = username, reason = "wrong_password"})
logSecurityEvent("GANG_CREATED", player, {gangName = name, cost = 400000})
logSecurityEvent("BASE_PURCHASED", player, {baseName = base, cost = price})
```

**Prioridade:** MÉDIA

---

### 8. Falta de Proteção CSRF em Eventos

**Severidade:** MÉDIA  
**CVSS Score:** 5.5

**Descrição:**
Eventos do cliente não validam origem, podendo ser forjados.

**Recomendação:**
- Validar que `source` do evento é o jogador esperado
- Verificar permissions antes de executar ações sensíveis
- Implementar tokens de sessão

**Prioridade:** MÉDIA

---

## 🟢 VULNERABILIDADES BAIXAS

### 9. Informações Sensíveis em Debug

**Severidade:** BAIXA  
**CVSS Score:** 3.0

**Descrição:**
outputDebugString pode expor informações sensíveis.

**Recomendação:**
- Usar níveis de log apropriados
- Não logar senhas ou dados sensíveis
- Desabilitar debug em produção

---

### 10. Limite de Contas por Serial Contornável

**Severidade:** BAIXA  
**CVSS Score:** 3.5

**Descrição:**
Limite de 2 contas por serial pode ser contornado alterando hardware ID.

**Recomendação:**
- Adicionar IP tracking
- Implementar CAPTCHA após múltiplos registros
- Sistema de verificação de email

---

## RESUMO DE PRIORIDADES

### URGENTE (Corrigir em 24-48h):
1. ✅ Rotacionar senha do banco de dados
2. ✅ Remover credenciais hardcoded
3. ✅ Implementar hashing seguro de senhas

### IMPORTANTE (Corrigir em 1-2 semanas):
4. Rate limiting em login
5. Validação contra SQL injection
6. Política de senhas forte

### RECOMENDADO (Corrigir em 1 mês):
7. Validação de tipos
8. Logging de segurança
9. Proteção CSRF

---

## CHECKLIST DE SEGURANÇA

- [ ] Substituir MD5 por bcrypt/SHA-256+salt
- [ ] Remover credenciais do código
- [ ] Rotacionar senha do banco
- [ ] Adicionar config.lua ao .gitignore
- [ ] Limpar histórico Git de credenciais
- [ ] Implementar rate limiting
- [ ] Fortalecer política de senhas (min 8 chars)
- [ ] Validar todos os inputs contra SQL injection
- [ ] Adicionar validação de tipos
- [ ] Implementar logging de segurança
- [ ] Revisar permissions de eventos
- [ ] Desabilitar debug logs em produção
- [ ] Implementar tokens de sessão
- [ ] Adicionar HTTPS/TLS (se aplicável)
- [ ] Revisar ACLs do servidor

---

## PRÓXIMOS PASSOS

1. **Imediato:** Rotacionar credenciais do banco de dados
2. **Esta Semana:** Implementar bcrypt e remover credenciais hardcoded
3. **Próximas 2 Semanas:** Rate limiting e validação de SQL
4. **Próximo Mês:** Implementar logging e melhorias gerais

---

**Status:** ⚠️ **NÃO RECOMENDADO PARA PRODUÇÃO** até correção das vulnerabilidades críticas.

**Data do Próximo Review:** 1 mês após implementação das correções

---

**Documento preparado por:** GitHub Copilot Security Agent  
**Data:** 18/02/2026  
**Versão:** 1.0
