# Auditoria de `[extras]` vs `meta.xml`

Data da análise: 2026-02-21  
Recurso analisado: `/home/runner/work/mta-gangwar/mta-gangwar`

## Objetivo

Verificar se os resources de `/home/runner/work/mta-gangwar/mta-gangwar/[extras]` necessários para o funcionamento do gamemode estão citados no `meta.xml` raiz.

## Escopo e método

Análise feita por:
- Leitura de `/home/runner/work/mta-gangwar/mta-gangwar/meta.xml`
- Leitura dos `meta.xml` dos resources dentro de `[extras]`
- Busca de dependências explícitas em código (`exports.*`, `getResourceFromName`, `call(...)`) em `Class/` e `Inits/`

## Dependências reais encontradas no gamemode

### Dependências explícitas do core

1. `hud`  
   - Usado em:
     - `Inits/bank/BankSystem_c.lua`
     - `Inits/login/Account_c.lua`
     - `Inits/login/SpawnSelector_c.lua`
   - Situação no `meta.xml`: **incluído** ✅

2. `systemID`  
   - Usado em:
     - `Class/Gang.lua` (`exports.systemID:getPlayerFromID(...)`)
   - Situação no `meta.xml`: **incluído** ✅

### Dependência transitiva entre extras

3. `scoreboard`  
   - Usado por:
     - `[extras]/systemID/main.lua` (`exports.scoreboard:addScoreboardColumn(...)`)
   - Situação no `meta.xml`: **incluído** ✅

## Comparação: includes atuais vs resources disponíveis

### Includes que existem localmente (OK)

- `systemID`, `ruas`, `scoreboard`, `wasted`, `realdriveby`, `modern_radar`, `hud_player`, `maximap`, `deaths_tags`, `nametag`, `ammunation`, `burguer`, `vehicleShop`, `deathpickups`  
- `[map-gang-war-bases]` também existe na raiz do projeto

### Pontos que **devem ser alterados/verificados**

1. `glue`  
   - Em `meta.xml`: incluído  
   - No repositório: existe apenas `"[extras]/glue.zip"` (não há pasta/resource `glue` com `meta.xml`)  
   - Risco: erro de include no start, se o servidor não tiver `glue` instalado externamente.

2. `heligrab`  
   - Em `meta.xml`: incluído  
   - No repositório: existe apenas `"[extras]/heligrab.zip"` (não há pasta/resource `heligrab` com `meta.xml`)  
   - Risco: erro de include no start, se o servidor não tiver `heligrab` instalado externamente.

3. `pickuphandler`  
   - Em `meta.xml`: incluído  
   - No repositório: **não foi encontrado** resource local `pickuphandler` nem zip correspondente  
   - Risco: include quebrado em ambiente limpo.

## Resources em `[extras]` não citados no `meta.xml`

`Down-Animation`, `PainelVeiculo`, `comandos`, `golzin`, `newInterior`, `pirate`, `radar_gta_v`, `skins`

Observação: o README descreve `[extras]` como opcionais. Então ausência de include **não é erro por si só**. Só devem entrar no `meta.xml` se forem requisitos funcionais obrigatórios do servidor.

## O que deveria ser alterado

### Alteração obrigatória (consistência de deploy)

Escolher **uma** estratégia para os includes abaixo:
- `glue`
- `heligrab`
- `pickuphandler`

#### Opção A (recomendada): manter includes e garantir resources reais
- Extrair/instalar os resources faltantes como pastas válidas (com `meta.xml`) no diretório de resources do servidor.
- Ideal para manter funcionalidades planejadas.

#### Opção B: remover include até o resource existir
- Comentar/remover no `meta.xml` os includes que não existem no ambiente.
- Evita falha de start por dependência ausente.

## Sugestão de ajuste mínimo no `meta.xml` (se optar pela Opção B)

```xml
<!-- <include resource="glue" minversion="1.5.2"/> -->
<!-- <include resource="heligrab" minversion="1.5.2"/> -->
<!-- <include resource="pickuphandler" minversion="1.5.2"/> -->
```

## Conclusão

- Dependências essenciais encontradas por código (`hud`, `systemID`, `scoreboard`) já estão corretamente incluídas.
- O principal problema atual é de **consistência de disponibilidade** para `glue`, `heligrab` e `pickuphandler`.
- Extras não incluídos parecem opcionais e não exigem alteração automática no `meta.xml` sem decisão funcional do servidor.
