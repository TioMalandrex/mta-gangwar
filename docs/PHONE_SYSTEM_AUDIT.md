# Auditoria Completa do Sistema de Telefone

## Objetivo

Este documento registra uma verificação técnica completa do sistema de telefone do projeto, cobrindo:

- o que está funcional;
- o que não está funcional;
- o que integra (e não integra) com os demais sistemas;
- o que é necessário para o telefone funcionar corretamente de ponta a ponta.

---

## Escopo analisado

### Arquivos do telefone

- `hud/client/phone/Phone.lua`
- `hud/client/phone/App.lua`
- `hud/client/phone/HomeApp.lua`
- `hud/client/phone/InfoApp.lua`
- `hud/client/phone/ConfigApp.lua`

### Arquivos de integração relevantes

- `hud/meta.xml` (registro/carregamento de scripts e assets)
- `hud/client/bank/BankSystem.lua`
- `Inits/bank/BankSystem_c.lua`
- `Inits/bank/BankSystem_s.lua`
- `Inits/login/Account_c.lua`
- `Inits/login/Account_s.lua`
- `Class/Account.lua`
- `hud/client/exports.lua`

---

## Diagnóstico geral (estado atual)

### Status macro: o sistema de telefone NÃO está ativo em produção

Em `hud/meta.xml`, o bloco **Windows Phone System** está comentado.  
Resultado: os scripts e assets do telefone não carregam no recurso HUD, portanto nenhum app do telefone é executado em runtime.

---

## O que está funcional (quando o módulo é ativado)

Apesar de desativado no `meta.xml`, a base estrutural existe e funciona parcialmente:

1. **Container principal do telefone**
   - Renderização da moldura do aparelho, barra superior e botão de voltar (`Phone.lua`).
   - Navegação entre apps via `Phone:loadApp(...)`.

2. **App inicial (`HomeApp`)**
   - Abertura do app **Informações**.
   - Abertura do app **Config**.
   - Efeitos de hover e layout dos ícones/apps.

3. **App de informações (`InfoApp`)**
   - Interface pronta (campo de busca + labels + avatar).
   - Botão “Pesquisar” com efeito visual de hover.

4. **App de configurações (`ConfigApp`)**
   - Estrutura visual das seções (Sistema, Conta, Personalização, VIP).
   - Efeitos de hover.

5. **Sistema de banco (fora do telefone)**
   - Banco já funciona de forma independente em painel próprio (`hud/client/bank/BankSystem.lua` + `Inits/bank/*`).
   - Eventos de depósito/saque/transferência e atualização de saldo estão implementados.

---

## O que NÃO está funcional (ou está incompleto)

1. **Telefone desativado no carregamento**
   - Bloco comentado em `hud/meta.xml` impede execução.

2. **Apps sem ação funcional real no Home**
   - Ícones “Telefone”, “Banco App”, “Maps”, “Guerra” e bloco “Informações Gang War” não têm `mousePressed` com fluxo completo.

3. **InfoApp sem backend**
   - `InfoApp:loadPlayerInfo(...)` está vazio.
   - Dados exibidos são estáticos/hardcoded (kills, deaths, dinheiro, etc.).
   - Não existe evento server-side específico para consulta de dados do jogador via telefone.

4. **ConfigApp apenas visual**
   - Seções não executam ações, não salvam preferências, não abrem subpáginas.

5. **Sem integração nativa do telefone com sistemas já existentes**
   - Banco existe, mas não há fluxo “abrir banco pelo app do telefone”.
   - Não há integração de “Maps” e “Guerra” com os painéis/turfs reais.
   - Não há integração com chat/mensagens/chamadas.

---

## Integrações que existem hoje

### 1) Banco (fora do telefone)

- Cliente do banco dispara:
  - `onPlayerWithdraw`
  - `onPlayerDeposit`
  - `onPlayerTransfer`
- Servidor processa e retorna atualização:
  - `updatePlayerInfoBank`
- Entrada/saída de marcador abre/fecha painel de banco:
  - `onPlayerBankHit`
  - `onPlayerBankLeave`

Arquivos: `Inits/bank/BankSystem_s.lua`, `Inits/bank/BankSystem_c.lua`, `hud/client/bank/BankSystem.lua`.

### 2) Login/conta

- Fluxo de login/register funciona e aciona HUD via `exports.hud:callHud(...)`.
- Dados de conta (inclusive `bank_balance`, gang, kills/deaths) já existem em `Class/Account.lua`.

Arquivos: `Inits/login/Account_s.lua`, `Inits/login/Account_c.lua`, `Class/Account.lua`.

---

## Integrações que NÃO existem hoje (lacunas)

1. **Telefone ↔ Banco**
   - Sem `BankApp` funcional dentro do telefone.
   - Sem reutilização direta do fluxo do banco dentro da UI do telefone.

2. **Telefone ↔ Dados de jogador (InfoApp)**
   - Sem evento dedicado cliente-servidor para pesquisa e retorno dinâmico.

3. **Telefone ↔ Guerra/Territórios**
   - App “Guerra” não consome dados de turf/ataques.

4. **Telefone ↔ Mapa**
   - App “Maps” sem lógica de renderização ou consumo de dados.

5. **Telefone ↔ Configurações persistentes**
   - Sem persistência de wallpaper/tema/preferências.

---

## O que é necessário para funcionar corretamente com todos os sistemas

### Fase 1 — Ativação mínima do módulo

1. Descomentar o bloco do telefone em `hud/meta.xml`.
2. Validar carregamento sem erro dos assets `gfx/phone/*`.

### Fase 2 — Tornar os apps clicáveis e com fluxo real

1. Implementar `mousePressed` nos apps que hoje são só ícone.
2. Criar telas mínimas para:
   - Telefone (placeholder funcional);
   - Banco (atalho para fluxo bancário);
   - Guerra/Mapa (placeholder inicial com status).

### Fase 3 — Integrar InfoApp com backend

1. Implementar evento client→server (ex.: busca por conta/nome).
2. Buscar dados reais no servidor a partir de `Account`/dados do player:
   - kills, deaths, gang, saldo, VIP, etc.
3. Retornar dados server→client e preencher labels do `InfoApp`.

### Fase 4 — Integrar Banco no telefone

Opções viáveis:

- **A)** Reusar painel bancário atual ao clicar em “Banco App”; ou
- **B)** Criar `BankApp` nativo do telefone reaproveitando os eventos já existentes.

### Fase 5 — Integração com guerra/mapa

1. Expor dados de turf e estado de ataques para o app “Guerra”.
2. Definir escopo real do app “Maps” (teleporte? visão de bases? pontos de interesse?).

### Fase 6 — Persistência e UX final

1. Salvar preferências de config (tema/wallpaper) por conta.
2. Padronizar botão voltar e ciclo de vida dos apps.
3. Revisar feedback visual/erros e estados vazios.

---

## Critérios de “telefone funcional”

Considerar o telefone funcional quando, no mínimo:

1. O módulo carregar automaticamente no HUD (sem comentários no `meta.xml`).
2. Todos os apps visíveis no Home responderem ao clique.
3. InfoApp mostrar dados reais de jogador (sem hardcode).
4. App de Banco permitir operações reais (ou abrir painel bancário existente).
5. App de Guerra/Mapa exibir dados reais do servidor.
6. Configurações do telefone persistirem entre sessões.

---

## Resumo executivo

- O telefone atual está **estruturalmente iniciado**, porém **desativado no carregamento** e com várias partes de UI ainda sem lógica.
- As bases dos sistemas principais (conta, banco, dados do jogador) **já existem** e podem ser reaproveitadas.
- O caminho mais eficiente é: **ativar módulo + ligar apps ao backend existente + implementar integrações faltantes por fases**.
