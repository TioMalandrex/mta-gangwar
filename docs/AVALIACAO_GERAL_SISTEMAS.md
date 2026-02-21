# Avaliação Geral de Todos os Sistemas do Projeto

## Objetivo

Este documento consolida uma auditoria técnica geral do projeto, no mesmo estilo do `AVALIACAO_TURFS_STATUS_88.md`, cobrindo:

- estado de cada sistema (funcional/parcial/incompleto);
- onde cada sistema se conecta;
- onde não se conecta;
- onde deveria se conectar;
- riscos e prioridades de evolução.

> Fonte: leitura direta dos arquivos do repositório (`meta.xml`, `hud/meta.xml`, classes core e scripts de init/client).

---

## 1) Mapa de sistemas carregados atualmente

## Núcleo do gamemode (server/shared)

Carregado por `meta.xml`:

- `Class/Database.lua`
- `Class/Account.lua`
- `Class/Gang.lua`
- `Class/Vehicle.lua`
- `Class/Pickup.lua`
- `Class/Spawn.lua`
- `Class/SpawnData.lua`
- `Class/Base.lua`
- `Class/Chat.lua`
- `Class/Area.lua`
- `Class/specialVehicle.lua`
- `Class/Properties.lua`

## Inits (ponte de eventos / inicialização)

- Login: `Inits/login/*`
- Turf: `Inits/turf/*`
- Gameplay geral: `Inits/gameplay/*`
- Banco: `Inits/bank/*`

## HUD próprio

Carregado por `hud/meta.xml`:

- Login UI
- Turf HUD (`DominationTerritory.lua`, `AttackTerritory.lua`)
- Banco UI
- Logo/UI utilitária

## Recursos extras incluídos via `meta.xml`

Exemplos:
- `scoreboard`, `modern_radar`, `realdriveby`, `deathpickups`, `nametag`,
- `ammunation`, `burguer`, `vehicleShop`, `maximap`, entre outros de `[extras]`.

---

## 2) Diagnóstico por sistema

## 2.1 Banco de Dados (Database)
- **Arquivos-chave:** `Class/Database.lua`
- **Status:** 🟢 Funcional
- **Como está:**
  - camada OOP (programação orientada a objetos) para `select/insert/update/delete`.
  - conexão padrão configurada para MySQL (`typeConnection = "mysql"`).
  - fallback SQLite existe no código.
- **Conecta com:** Account, Gang, Area, Base, Properties.
- **Não conecta com:** validações de domínio (a camada executa query, mas não aplica regra de negócio).
- **Onde deveria melhorar:**
  - padronizar tratamento de erro por operação crítica;
  - reduzir uso de concatenação em SQL custom quando possível.

---

## 2.2 Conta/Login
- **Arquivos-chave:** `Class/Account.lua`, `Inits/login/Account_s.lua`, `Inits/login/Account_c.lua`, HUD login.
- **Status:** 🟢 Funcional
- **Como está:**
  - registro/login com persistência de dados do jogador.
  - carrega gang, dinheiro, kills/deaths, banco, posição, armas, roupas.
  - integra com fluxo de spawn e gang no login.
- **Conecta com:** Spawn, Gang, Bank (saldo em data), Properties (indiretamente via owner name).
- **Não conecta com:** telefone (porque sistema phone está desativado no meta do HUD).
- **Onde deveria conectar melhor:**
  - notificações unificadas de estado de conta no HUD;
  - hardening de segurança (regra de senha/hash/rate-limit).

---

## 2.3 Gangues
- **Arquivos-chave:** `Class/Gang.lua`
- **Status:** 🟢 Funcional
- **Como está:**
  - hierarquia de níveis, XP, tag, slogan, cor, team ativa/inativa.
  - comandos de gestão de gang.
  - ranking/top por XP.
- **Conecta com:** Area (XP/domínio), Base (ownership), Chat (gang chat), Account (membro).
- **Não conecta com:** caixa/cofre de gang no sistema bancário.
- **Onde deveria conectar:**
  - banco da gang (conta coletiva);
  - relatórios de eventos de guerra por gang.

---

## 2.4 Zonas/Turfs (Area)
- **Arquivos-chave:** `Class/Area.lua`, HUD turf.
- **Status:** 🟢 Funcional com ajustes recentes aplicados
- **Como está:**
  - dominação (Fase 1), ataque por pontos (Fase 2), XP por área.
  - integração com HUD por eventos (`onTeamStartDomination`, `onTeamRefreshAttack` etc.).
  - posse de área por gang e coloração de radar.
  - persistência em `tbl_gang_areas`.
- **Conecta com:** Gang (XP e owner), Spawn (bônus de villas e respawn), HUD turf.
- **Não conecta com:** phone/map app (desativado).
- **Atualização recente já aplicada:**
  - persistência imediata de owner no `setOwner`;
  - cooldown anti ping-pong (1 min) com `lastCaptureTick`.
- **Onde deveria conectar melhor:**
  - telemetria/histórico de ataques;
  - painel consolidado de guerra para administração.

---

## 2.5 Bases
- **Arquivos-chave:** `Class/Base.lua`
- **Status:** 🟢 Funcional
- **Como está:**
  - 5 bases com custo, gate, marker, ownership.
  - compra/venda com regra de XP e permissão de nível.
  - altera controle de veículos/pickups ligados à base.
  - persistência em `tbl_bases`.
- **Conecta com:** Gang, Vehicle, Pickup, Account (dinheiro).
- **Não conecta com:** sistema de cofre/banco de gang.
- **Onde deveria conectar:**
  - cofre de base/gang;
  - histórico de aquisição/perda.

---

## 2.6 Veículos
- **Arquivos-chave:** `Class/Vehicle.lua`, `Class/specialVehicle.lua`, `Inits/gameplay/Vehicles_*`.
- **Status:** 🟢 Funcional
- **Como está:**
  - grande dataset de veículos por base/zona.
  - veículos especiais com controle de uso e cooldown de respawn (`forbidden`).
  - blips de veículo no cliente em stream in/out.
- **Conecta com:** Base, Area (gangzona indiretamente), Gang (cor/owner), Spawn/gameplay.
- **Não conecta com:** sistema econômico avançado (manutenção/tunagem).
- **Onde deveria conectar:**
  - logs e métricas de uso por gang;
  - integração opcional com loja/upgrade.

---

## 2.7 Pickups
- **Arquivos-chave:** `Class/Pickup.lua`, `Inits/gameplay/Pickup_c.lua`
- **Status:** 🟢 Funcional
- **Como está:**
  - pickups por base/zona para armas/vida/colete.
  - valida owner de base/gang antes de conceder item.
  - efeito visual (`addSparks`) no cliente.
- **Conecta com:** Base, Area, Gang.
- **Não conecta com:** inventário persistente por conta (modelo atual é runtime).
- **Onde deveria conectar:**
  - auditoria anti abuso de coleta;
  - balanceamento por horário/evento.

---

## 2.8 Spawn/Respawn
- **Arquivos-chave:** `Class/Spawn.lua`, `Class/SpawnData.lua`, `Inits/login/SpawnSelector_*`
- **Status:** 🟢 Funcional
- **Como está:**
  - respawn por regras de gang/base/gangzona.
  - bônus de villas aplicados no spawn (Fort Carson/Blueberry).
  - controle de blips de players.
  - seletor de spawn e proteção de dimension durante seleção.
- **Conecta com:** Account, Gang, Area, Base.
- **Não conecta com:** proteção temporal de pvp pós-spawn (além do fluxo de selector).
- **Onde deveria conectar:**
  - cooldown anti spawn-kill mais explícito;
  - feedback visual de bonus de spawn.

---

## 2.9 Propriedades (Economia passiva)
- **Arquivos-chave:** `Class/Properties.lua`, HUD properties client.
- **Status:** 🟢 Funcional
- **Como está:**
  - compra/venda de propriedades.
  - lucro periódico por timer (`timeReceiveLucre = 600000ms`, ou seja, 10 minutos).
  - persistência de owner em `tbl_properties`.
- **Conecta com:** Account (owner/money), Bank (conceitualmente, mas o lucro atual cai em money do player).
- **Não conecta com:** gangue (sem propriedade de gang).
- **Onde deveria conectar:**
  - opção de depositar lucro automaticamente no banco;
  - limite/config por jogador para balanceamento.

---

## 2.10 Banco
- **Arquivos-chave:** `Inits/bank/BankSystem_s.lua`, `Inits/bank/BankSystem_c.lua`, `hud/client/bank/BankSystem.lua`
- **Status:** 🟡 Parcial (funcional com pontos críticos)
- **Como está:**
  - depósito, saque, transferência;
  - trigger por markers no mapa;
  - UI no HUD com atualização por evento.
- **Conecta com:** Account (bank_balance), HUD.
- **Não conecta com:** Gang (cofre coletivo), phone app ativo.
- **Onde deveria conectar:**
  - conta da gang;
  - histórico de transações;
  - validações mais rígidas e proteção anti-spam.

---

## 2.11 Chat
- **Arquivos-chave:** `Class/Chat.lua`, `Inits/gameplay/MessagesRandom*.lua`
- **Status:** 🟡 Parcial
- **Como está:**
  - reformata chat global e de gang;
  - mensagens periódicas de servidor/top gang.
- **Conecta com:** Gang (chat team), Account (identidade/ID data).
- **Não conecta com:** telefone, sistema de PM estruturado, logs de moderação.
- **Onde deveria conectar:**
  - canais por contexto (guerra/base/evento);
  - rate-limit/filtro anti flood;
  - comandos de mensagem privada.

---

## 2.12 HUD
- **Arquivos-chave:** `hud/meta.xml`, `hud/client/*`
- **Status:** 🟢 Funcional no core visual (com um módulo desativado)
- **Como está:**
  - HUD de login, turf, banco, logo etc.
  - `exports.callHud` para executar comandos visuais.
- **Conecta com:** Login, Bank, Turf systems.
- **Não conecta com:** phone (desativado no meta).
- **Onde deveria conectar:**
  - central de notificações cross-sistema;
  - padronização de feedback visual em todos os módulos.

---

## 2.13 Telefone (HUD phone)
- **Arquivos-chave:** `hud/client/phone/*`, `hud/meta.xml`
- **Status:** 🔴 Desativado/Incompleto
- **Como está:**
  - scripts e assets de phone estão comentados no `hud/meta.xml`.
  - apps existem no código, mas sem integração completa backend.
- **Conecta com:** praticamente não conecta em produção (desativado).
- **Não conecta com:** Bank/Turf/Map/Chat em runtime real.
- **Onde deveria conectar:**
  - consultas de conta/gang/território;
  - app de banco integrado;
  - app de guerra/mapa ao estado real do servidor.

---

## 2.14 Extras ([extras] e recursos incluídos)
- **Status:** 🟡 Heterogêneo (misto de utilidades visuais e mecânicas)
- **Como está:**
  - múltiplos recursos terceiros/auxiliares adicionam radar, scoreboard, driveby, lojas etc.
- **Conecta com:** gamemode por include/start de recursos.
- **Não conecta com:** modelo unificado de telemetry/estado do core (em geral).
- **Onde deveria conectar:**
  - catálogo central de integrações (quais recursos escrevem em dados de player/gang);
  - revisão de impacto/performance por recurso ativo.

---

## 3) Matriz simplificada de conexão entre sistemas

Legenda: ✅ conectado | ⚠️ parcial | ❌ não conectado

| Sistema | Account | Gang | Area/Turf | Base | Bank | HUD | Phone |
|---|---|---|---|---|---|---|---|
| Account | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ✅ | ❌ |
| Gang | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠️ | ❌ |
| Area/Turf | ⚠️ | ✅ | ✅ | ⚠️ | ❌ | ✅ | ❌ |
| Base | ⚠️ | ✅ | ⚠️ | ✅ | ❌ | ⚠️ | ❌ |
| Bank | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Properties | ✅ | ❌ | ❌ | ❌ | ⚠️ | ⚠️ | ❌ |
| Spawn | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠️ | ❌ |
| Chat | ⚠️ | ✅ | ⚠️ | ❌ | ❌ | ⚠️ | ❌ |
| Phone | ❌ | ❌ | ❌ | ❌ | ❌ | ⚠️ | 🔴 desativado |

---

## 4) Principais lacunas de integração (prioridade)

## Alta
1. **Phone desativado e sem integração real** com sistemas core.
2. **Banco sem conta de gang** (sem cofre coletivo).
3. **Banco sem hardening completo** (regras e proteção de abuso podem ser reforçadas).

## Média
4. **Chat sem camadas de evento** (guerra/base/economia) mais estruturadas.
5. **Properties sem integração opcional com bank_balance** (hoje lucro cai em money).
6. **Extras sem matriz unificada de impacto** no core (governança técnica).

## Baixa
7. **Padronização de UX/HUD** entre módulos.
8. **Telemetria e histórico de eventos** para administração/balanceamento.

---

## 5) Recomendações práticas de evolução

1. **Consolidar integração econômica**
   - adicionar cofre de gang;
   - definir fluxo propriedades → banco (configurável).

2. **Consolidar integração de guerra**
   - feed de eventos turf/base no chat e HUD;
   - endpoints/eventos para um futuro app de phone/mapa.

3. **Reativar telefone por fases**
   - fase 1: ativar módulo + app de status;
   - fase 2: integrar banco/info de player;
   - fase 3: integrar turf/map/chat.
   - ação recomendada: abrir uma issue/epic única para "Reativação Phone" com checklist por fase.

4. **Hardening técnico**
   - reforçar validações de eventos críticos;
   - padronizar logs de erro e auditoria.

---

## 6) Conclusão Geral

O projeto possui **núcleo funcional sólido** (conta, gang, turf, base, spawn, veículos, pickups, propriedades), com integração principal operante entre os módulos de gameplay.

O maior gap hoje não é “falta de sistema”, mas sim:

- **integração incompleta entre sistemas econômicos/comunicação**;
- **módulo telefone desativado**;
- **necessidade de padronização de governança técnica** entre core e extras.

Com foco nesses pontos, o projeto avança de um estado “funcional com ilhas” para um estado “integrado e operacionalmente maduro”.
