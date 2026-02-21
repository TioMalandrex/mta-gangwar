# Análise Técnica — Respostas Detalhadas às 7 Perguntas (Zonas, Combate, XP e HUD)

> Base desta análise: leitura direta do código atual do repositório (sem suposições externas).
> Observação: menções a “93 zonas” neste arquivo aparecem por contexto das perguntas originais; a contagem correta atual documentada aqui é **70 zonas**.

---

## 1) Onde estão as “93 zonas”? Já estão mapeadas com coordenadas/tamanho ou precisam ser criadas?

### Resposta curta
As zonas **já estão mapeadas no código**, em tabela Lua com nome, posição e tamanho, mas o código atual contém **70 zonas**, não 93.

### Evidência técnica
- Fonte principal: `Class/Area.lua` em `static.DATA`.
  - Estrutura por entrada:
    - `name`
    - `x, y, z`
    - `width, height`
    - `xp`
    - `type` (`territorio`, `gangzona`, `villa`)
- A mesma lista também aparece em `Inits/turf/shared/data.lua` (duplicada).

### Contagem real no código
- `territorio`: **58**
- `gangzona`: **8**
- `villa`: **4**
- **Total: 70**

### Conclusão
- **Não precisam ser mapeadas “uma a uma” do zero**, porque já existe tabela pronta.
- Porém, se a meta de design for realmente **93 zonas**, faltam **23 zonas** no dataset atual.

---

## 2) Qual é o motor de armazenamento? Quando uma gangue conquista uma zona, onde isso é guardado?

### Resposta curta
O projeto usa uma camada `Database` configurada para **MySQL** por padrão.  
A posse das zonas é mantida em memória durante runtime e persistida na tabela `tbl_gang_areas` no ciclo de recurso (start/stop).

### Evidência técnica
- `Class/Database.lua`:
  - `static.typeConnection = "mysql"`
  - conexão para `db_gangwar` em `127.0.0.1:3306`
  - existe fallback SQLite no código, mas não é o modo padrão ativo.
- `Class/Area.lua`:
  - cria tabela `tbl_gang_areas (id, name, owner, type)`
  - no `onResourceStart`, carrega owner salvo para cada área e aplica com `instance:setOwner(...)`
  - no `onResourceStop`, grava/atualiza owner/type de todas as áreas.

### Observação importante de precisão
- Durante a execução, o owner também vive em:
  - `Area.instances` (objetos em memória)
  - `colShape` data (`owner`, `isAttacking`, etc.)
- Persistência não é “a cada conquista” em escrita imediata no DB; o padrão visto é salvar no evento de stop do recurso.

### Conclusão
- **Não é XML/JSON nem só RAM**.
- É **MySQL + estado em memória** (com persistência no ciclo do recurso).

---

## 3) A Fase 1 (Dominação) já existe? Há detecção de entrada na área e contador de 260s?

### Resposta curta
**Sim, existe e está implementada no servidor.**

### Evidência técnica
- `Class/Area.lua`:
  - `Area.DOMINATION_TIME = 260000` (260 segundos em ms).
  - `addEventHandler("onColShapeHit", self.colShape, self.onPlayerHitArea)` detecta entrada na área.
  - quando válido, chama `self:startDomination(team)`.
  - `startDomination` inicia `Timer(..., 1000, 0)` e dispara progresso para clientes por `onTeamStartDomination`.

### Fluxo real
1. Jogador entra no `colShape`.
2. Se não for owner e cumprir regras de tipo/xp mínimo, inicia dominação.
3. Timer reduz tempo restante e envia atualização para HUD.
4. Ao completar, dispara `onTeamFinishDomination` e começa Fase 2 (`startAttack`).

### Conclusão
Fase 1 está codificada e funcional no fluxo principal.

---

## 4) A aceleração por membros funciona (conta membros da mesma gangue e reduz tempo automaticamente)?

### Resposta curta
**Sim, funciona no cálculo principal da dominação.**

### Evidência técnica
- Em `Class/Area.lua`, dentro de `startDomination`:
  - a cada segundo: `dominationTime = dominationTime - (500 * #self:getAllPlayersTeam(team))`
  - `getAllPlayersTeam(team)` conta jogadores daquela team dentro do colshape.

### Interpretação operacional
- Mais membros da gang atacante dentro da zona => maior redução por segundo => captura mais rápida.

### Observações de implementação
- Existe também um cálculo de `dominationTime` local no evento de entrada (`2000 - (5*#teamPlayers)`) enviado ao cliente, mas a lógica determinante de captura é a do timer da Fase 1.
- O cancelamento por ausência de membros é tratado no `onColShapeLeave` (quando zero jogadores da team, timer é destruído).

### Conclusão
A aceleração dinâmica por membros está implementada no servidor e usada no tempo de dominação.

---

## 5) A Fase 2 (Batalha de Pontos) está programada? Kills (+300) em tempo real existem?

### Resposta curta
**Sim.** A fase de ataque com pontuação por presença + kills existe e envia atualização contínua ao HUD.

### Evidência técnica
- `Class/Area.lua`:
  - `Area.ATTACK_TIME = 200000` (200s).
  - `startAttack(team)` cria `self.war` com:
    - atacante/defensor
    - score inicial defensor = `Area.POINTS_DEFENSER` (500)
  - Timer de ataque:
    - soma pontos por presença na área (`+ #players na área` por tick)
    - emite `onTeamRefreshAttack` com score/deaths/time.
- `onPlayerWasted` (handler global no mesmo arquivo):
  - se morte dentro da área durante ataque, adiciona **+300** ao lado rival.
  - atualiza contadores de mortes e placar conforme atacante/defensor.

### HUD em tempo real da Fase 2
- Cliente recebe `onTeamStartAttack`, `onTeamRefreshAttack`, `onTeamFinishAttack` em:
  - `hud/client/turf/AttackTerritory.lua`
- Painel mostra:
  - nome das gangs
  - pontos
  - mortes
  - players na área
  - tempo restante

### Conclusão
Fase 2 está implementada com lógica de pontuação, kills e atualização em tempo real.

---

## 6) Como o XP da gangue é calculado hoje? Soma de zonas dominadas ou valor fixo/manual?

### Resposta curta
Hoje existe um modelo **híbrido**, com regra de batalha em tempo real e reconciliação por soma de zonas.

### Evidência técnica (duas camadas)

### A) Durante batalhas
- `Class/Area.lua` em `startAttack`:
  - Defesa bem-sucedida: `winnerGang:incrementXP(1000)`
  - Vitória do atacante: `winnerGang:incrementXP(self.xp)` e `loserGang:decrementXP(self.xp)`

### B) Persistência/reconciliação
- `Class/Area.lua` define `Area.getOwnerXp(gangName)`, que soma `instance.xp` de todas as áreas cujo owner = gang.
- `Class/Gang.lua` no `onResourceStop`:
  - atualiza `tbl_gangs.xp` usando **`Area.getOwnerXp(gang.name)`**.
  - ou seja, ao salvar, o XP persistido é recalculado a partir das zonas controladas.

### Interpretação prática
- Em runtime, XP sobe/desce por eventos de combate.
- No salvamento do recurso, há reconciliação baseada na posse atual de áreas (soma dos XPs das zonas dominadas).

### Conclusão
Não é somente valor manual fixo; há:
1) dinâmica de guerra em tempo real  
2) recalculo por domínio territorial na persistência.

---

## 7) O HUD das zonas já comunica com o servidor? Há barra/avisos visuais quando começa dominação?

### Resposta curta
**Sim, a integração HUD ↔ servidor já existe e está ativa.**

### Evidência técnica
- Servidor (`Class/Area.lua`) dispara eventos:
  - `onPlayerEnterArea` / `onPlayerExitArea`
  - `onTeamStartDomination` / `onTeamFinishDomination`
  - `onTeamStartAttack` / `onTeamRefreshAttack` / `onTeamFinishAttack`
- Cliente (`hud/client/turf/DominationTerritory.lua`):
  - exibe informações da área (tipo, nome, dominante)
  - exibe barra de progresso da dominação.
- Cliente (`hud/client/turf/AttackTerritory.lua`):
  - exibe painel completo da batalha de pontos
  - mostra updates contínuos (tempo, pontos, mortes, players em área)
  - mensagens de chat sobre ataque/defesa/domínio.

### Conclusão
Essa parte visual **não está solta**: já está ligada ao script server-side por eventos.

---

## Perguntas adicionais (atualização solicitada)

### 8) Se o servidor crashar agora, as zonas conquistadas na última hora são perdidas?

### Resposta curta
**Podem ser perdidas, sim.**

### Por que isso acontece no código atual
- A troca de owner da área ocorre em memória com `self:setOwner(...)` (`Class/Area.lua`).
- A persistência para `tbl_gang_areas` é feita no ciclo do recurso, principalmente em `onResourceStop` (`Class/Area.lua`).
- Não existe gravação explícita imediata no banco logo após cada conquista/fim de ataque.

### Impacto prático
- Se houver **crash/queda** antes de o recurso executar o `onResourceStop`, as mudanças recentes de owner podem não ter sido persistidas.

### Sobre “implementar dbExec no onTeamFinishDomination”
- Esse ponto precisa de nuance técnica:
  - `onTeamFinishDomination` marca fim da **Fase 1** e inicia `startAttack` (Fase 2).
  - Em zonas já com dono, o owner final só é definido no fim do ataque (`onTeamFinishAttack`/`self:setOwner(winner)`).
- Portanto, para cobertura correta de persistência, o melhor gatilho é o momento em que o owner realmente muda (fluxo de `setOwner`/fim do ataque), não apenas `onTeamFinishDomination`.

### Conclusão
Sim, existe risco de perda após crash. A recomendação é persistir imediatamente quando a posse for alterada de fato.

---

### 9) Existe “Proteção de Novato” que impeça uma gang de ser atacada 1 minuto após conquistar zona?

### Resposta curta
**Não existe, no sistema de zonas.**

### Evidência técnica
- Em `Class/Area.lua` não há:
  - timestamp de “última conquista” por área;
  - cooldown de bloqueio pós-conquista (ex.: 60s);
  - condição de bloqueio no `onColShapeHit` para impedir novo ataque por tempo.
- O que existe:
  - restrições por XP mínimo para atacar `gangzona`/`villa`;
  - flag `isAttacking` para evitar ataques simultâneos;
  - timers de dominação/ataque.
- Há “proteção” em outros contextos, mas não de turf pós-conquista:
  - proteção de spawn/login (`SpawnSelector_*`);
  - cooldown de veículos especiais (`Class/specialVehicle.lua`).

### Conclusão
Atualmente não há proteção de 1 minuto (ou similar) para zona recém-conquistada.

---

## Resumo executivo final

1. O core de territórios/combate existe e está funcional em boa parte.
2. A lista de zonas no código atual é 70 (não 93).
3. Persistência de zonas usa MySQL (`tbl_gang_areas`) com estado em memória durante runtime.
4. Fase 1 e Fase 2 existem com:
   - timer
   - aceleração por presença
   - score por presença
   - +300 por mortes em área
   - HUD atualizado em tempo real.
5. XP é híbrido: dinâmica de batalha + reconciliação por soma de áreas dominadas no salvamento.
6. Há risco de perda de conquistas recentes em caso de crash antes da persistência de stop.
7. Não existe hoje cooldown de proteção pós-conquista (ex.: 1 minuto) para impedir novo ataque.
