# SYSTEM_ANALYSIS.md

## 1) Resumo Executivo (análise atualizada)

Este documento é uma reanálise completa do estado atual do projeto **mta-gangwar** com base no código fonte vigente.

### Estado geral
- Arquitetura base: **cliente-servidor OOP** com classes centrais em `Class/`.
- Persistência: **MySQL** via `Class/Database.lua` (SQLite existe no código, mas não é o caminho principal).
- Núcleo jogável: **funcional** (conta/login, gangues, turfs, bases, veículos, pickups, spawn, propriedades, banco, chat).
- Módulo telefone: **desativado e não funcional em produção** (bloco comentado no `hud/meta.xml`).

### Pontos críticos atuais
1. **Segurança**: senha com MD5 e credenciais de DB hardcoded.
2. **Banco**: eventos financeiros sem hardening robusto (rate-limit/validações completas).
3. **Integração**: sistemas principais funcionam, porém há integrações faltantes (ex.: telefone com backend real).

---

## 2) Escopo analisado

### Entrada principal
- `meta.xml` (gamemode)
- `hud/meta.xml` (HUD)

### Classes centrais
- `Class/Database.lua`
- `Class/Account.lua`
- `Class/Gang.lua`
- `Class/Area.lua`
- `Class/Base.lua`
- `Class/Vehicle.lua`
- `Class/specialVehicle.lua`
- `Class/Pickup.lua`
- `Class/Spawn.lua`
- `Class/Properties.lua`
- `Class/Chat.lua`

### Inits relevantes
- `Inits/login/*`
- `Inits/turf/*`
- `Inits/bank/*`
- `Inits/gameplay/*`

---

## 3) Arquitetura técnica atual

### 3.1 Padrão de projeto
- Uso amplo de classes singleton e objetos orientados a eventos MTA.
- Regras de domínio concentradas em `Class/*`.
- Ponte cliente-servidor via eventos (`triggerServerEvent` / `triggerClientEvent`).

### 3.2 Persistência e dados
- Conexão primária: MySQL.
- Tabelas principais:
  - `tbl_users`, `tbl_users_data`
  - `tbl_gangs`
  - `tbl_gang_areas`
  - `tbl_bases`
  - `tbl_properties`
- Estratégia mista de persistência:
  - parte em tempo real em alguns fluxos críticos;
  - parte em `onResourceStop` para reconciliação.

---

## 4) Status por sistema

### 4.1 Login/Conta
**Status:** ✅ Funcional

#### Implementado
- Registro/login e carga de dados persistidos.
- Dados de progresso (kills, deaths, dinheiro, gang, etc.).
- Integração com spawn inicial.

#### Pontos fracos
- Hash de senha com **MD5** (obsoleto).
- Falta de hardening mais robusto contra abuso de eventos de autenticação.

---

### 4.2 Gangues
**Status:** ✅ Funcional

#### Implementado
- Hierarquia de cargos da gang.
- XP da gang, tag, slogan, cor.
- Operações de gestão de membros.

#### Integrações
- Turf (`Area`) para domínio/XP.
- Bases para ownership e controle de recursos.

#### Lacunas
- Sem cofre/banco coletivo nativo da gang.

---

### 4.3 Turfs / Territórios
**Status:** ✅ Funcional (com melhorias recentes aplicadas)

#### Quantidade correta de áreas
- **70 áreas no total**:
  - 58 `territorio`
  - 8 `gangzona`
  - 4 `villa`

#### Mecânica atual
- Fase 1 (dominação): temporizada, aceleração por membros em área.
- Fase 2 (ataque por pontos): pontos por presença + kills.

#### Configurações importantes
- `DOMINATION_TIME = 260000` ms
- `ATTACK_TIME = 200000` ms
- `CAPTURE_COOLDOWN = 60000` ms

#### Melhorias recentes já incorporadas no código
- Persistência imediata de ownership no fluxo de `setOwner`.
- Cooldown anti ping-pong por área (`lastCaptureTick`).

---

### 4.4 Bases
**Status:** ✅ Funcional

#### Implementado
- 5 bases compráveis com regras de XP e dinheiro.
- Controle de owner e impacto em veículos/pickups da base.
- Persistência de owner.

#### Lacunas
- Sem camada de economia coletiva (cofre de base/gang).

---

### 4.5 Veículos
**Status:** ✅ Funcional

#### Implementado
- Frota por base/zona.
- Veículos especiais com janela de indisponibilidade após respawn.
- Blips e lógica de stream no cliente.

#### Lacunas
- Sem sistema interno de upgrade/tunagem integrado ao core.

---

### 4.6 Pickups
**Status:** ✅ Funcional

#### Implementado
- Pickups de arma/vida/colete com validação por ownership.
- Lógica de coleta com timer e feedback visual.

#### Lacunas
- Sem inventário persistente por jogador (modelo atual é runtime).

---

### 4.7 Spawn/Respawn
**Status:** ✅ Funcional

#### Implementado
- Respawn baseado em estado de team/base/gangzona.
- Bônus condicionais por controle de villas específicas.

#### Lacunas
- Falta formalização explícita de anti-spawn repetitivo além do fluxo padrão de seleção.

---

### 4.8 Propriedades
**Status:** ✅ Funcional

#### Implementado
- Compra/venda de propriedades.
- Lucro periódico por timer.
- Persistência de owner.

#### Lacunas
- Integração econômica poderia evoluir para mais controle (ex.: políticas por gang).

---

### 4.9 Banco
**Status:** 🟡 Funcional com pontos críticos

#### Implementado
- Depósito, saque, transferência, painel de banco.

#### Lacunas críticas
- Hardening incompleto para cenário de abuso (rate limit e validação estrita de entrada).
- Sem extrato/transações detalhadas.
- Sem integração com cofre coletivo de gang.

---

### 4.10 Chat
**Status:** 🟡 Parcial

#### Implementado
- Chat global customizado e chat de gang.
- Mensagens periódicas automáticas.

#### Lacunas
- Falta camada mais robusta de moderação anti-flood/spam.
- Ausência de funcionalidades mais avançadas (PM estruturado, etc.).

---

### 4.11 HUD
**Status:** ✅ Funcional no core

#### Implementado
- Telas de login, turf HUD, bank HUD, etc.
- Export `callHud` para execução de trechos de UI.

#### Observação
- Alguns módulos visuais estão ativos, porém phone está desativado no `meta` do HUD.

---

### 4.12 Telefone
**Status:** 🔴 Desativado / incompleto

#### Situação
- Estrutura client-side existe (`hud/client/phone/*`).
- Bloco de carregamento está comentado no `hud/meta.xml`.
- Não há integração backend madura para tornar apps funcionais no runtime atual.

#### Conclusão
- Deve ser tratado como **em desenvolvimento, não funcional em produção**.

---

## 5) Matriz de integração (alto nível)

| Sistema | Account | Gang | Turf | Base | Banco | HUD |
|---|---|---|---|---|---|---|
| Account | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ✅ |
| Gang | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| Turf | ⚠️ | ✅ | ✅ | ⚠️ | ❌ | ✅ |
| Base | ⚠️ | ✅ | ⚠️ | ✅ | ❌ | ⚠️ |
| Banco | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ |
| HUD | ✅ | ⚠️ | ✅ | ⚠️ | ✅ | ✅ |

Legenda: ✅ integrado | ⚠️ parcial | ❌ ausente

---

## 6) Segurança (estado atual)

### 6.1 Riscos confirmados
1. **MD5 em senhas**.
2. **Credenciais de DB expostas no código**.
3. **Hardening incompleto em eventos financeiros**.

### 6.2 Recomendações prioritárias
1. Migrar hashing para algoritmo moderno (com salt).
2. Remover credenciais hardcoded (env/config externa).
3. Padronizar validações/rate-limit em eventos sensíveis.

---

## 7) Performance e operação

### 7.1 Pontos positivos
- Modelo por módulos facilita manutenção incremental.
- Grande parte da lógica pesada está no server-side.

### 7.2 Pontos de atenção
- Uso intenso de timers/eventos em áreas concorridas.
- Necessidade de telemetria operacional mais consolidada (erro/latência/eventos críticos).

---

## 8) Limitações conhecidas

1. Telefone não funcional em produção.
2. Integração econômica entre gang/base/banco ainda incompleta.
3. Ausência de camada mais madura de observabilidade (dashboards/alertas internos do core).

---

## 9) Recomendações de roadmap

### Curto prazo
1. Hardening de segurança (auth + banco).
2. Padronização de validações de eventos críticos.
3. Melhorias de observabilidade de erros no core.

### Médio prazo
1. Integração econômica de gang (cofre/fluxos dedicados).
2. Evolução do chat/moderação.
3. Reativação progressiva do telefone por fases (com backend real).

---

## 10) Conclusão

O servidor possui base sólida e jogável, com os sistemas centrais funcionando de forma consistente. O principal trabalho restante está em:
- segurança/hardening,
- integração entre módulos econômicos,
- e maturação de módulos incompletos (especialmente telefone).

Esta versão substitui análises antigas para refletir o estado atual do repositório.
