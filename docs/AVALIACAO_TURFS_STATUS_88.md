# Avaliação de Viabilidade — Sistema de Zonas/Turfs (Status 88%)

## Contexto

Esta avaliação cobre a viabilidade das duas melhorias apontadas como faltantes e críticas para UX:

1. **Persistência imediata** da posse da zona (evitar perda em crash).
2. **Cooldown de ataque** para evitar efeito ping-pong (recaptura sem janela de descanso).

Baseado no código atual:

- `Class/Area.lua`
- `Class/Database.lua`

---

## Resumo Executivo

### É possível fazer?
**Sim, é totalmente possível** com mudanças localizadas e baixo risco arquitetural.

### Esforço estimado
- **Persistência imediata:** baixo/médio (1 ponto de gravação central + tratamento de erro).
- **Cooldown de ataque:** baixo/médio (1 variável de estado + 1 guarda no início do ataque/dominação + feedback ao jogador).

### Impacto no sistema atual
- Não exige reescrever lógica de combate.
- Aproveita fluxo já existente de `setOwner(...)`, que é o melhor ponto de centralização.

---

## 1) Persistência imediata (dbExec/db update no momento da conquista)

### Situação atual

No estado atual, o owner muda em memória via `self:setOwner(...)` e a persistência principal ocorre no ciclo de `onResourceStop` (`Class/Area.lua`).  
Resultado: se o servidor/resource cair antes do stop salvar, conquistas recentes podem não estar no banco.

### Viabilidade técnica

**Alta.** Já existe camada `Database` pronta (`Area.database`) e tabela `tbl_gang_areas`.

### Onde implementar (recomendado)

**Melhor ponto: dentro de `Area:setOwner(team)`**, porque:

- todo fluxo de troca de dono passa por ele;
- evita duplicação de persistência em múltiplos caminhos (`startAttack`, casos sem owner, etc.);
- reduz chance de esquecer algum cenário.

### O que precisa ser feito

1. Criar método dedicado para persistência, por exemplo:
   - `Area:persistOwnerNow()`
2. Chamar esse método no final de `setOwner(...)` sempre que owner for alterado.
3. Persistir no `tbl_gang_areas` por `name` da área:
   - atualizar `owner` (incluindo `NULL` quando sem dono)
   - opcional: manter também `type` por consistência.
4. Tratar retorno/erro de execução e logar falhas de persistência.

### Observação importante

Persistir no `onTeamFinishDomination` **não cobre corretamente todos os casos**:

- `onTeamFinishDomination` encerra Fase 1.
- Em áreas já ocupadas, o owner final só é decidido no fim da Fase 2.

Por isso, persistir em `setOwner(...)` é tecnicamente mais correto.

---

## 2) Cooldown de ataque (anti ping-pong)

### Situação atual

Não há proteção temporal pós-conquista no sistema de zonas:

- existe bloqueio de ataque simultâneo via `isAttacking`;
- existem requisitos de XP por tipo de zona;
- mas não existe janela de descanso após troca de dono.

### Viabilidade técnica

**Alta.** A classe `Area` já centraliza:

- entrada no colshape (`onColShapeHit`);
- início de dominação (`startDomination`);
- troca de owner (`setOwner`).

Isso permite inserir cooldown sem alterar arquitetura global.

### O que precisa ser feito (conforme proposta)

1. Adicionar em `Area`:
   - `self.lastCaptureTick` (tick da última captura).
2. Definir constante de cooldown, ex.:
   - `Area.CAPTURE_COOLDOWN = 60000` (1 minuto).
3. Atualizar `lastCaptureTick` quando a posse mudar de fato (em `setOwner`).
4. No `onColShapeHit` (antes de `startDomination`), validar:
   - se `getTickCount() - self.lastCaptureTick < CAPTURE_COOLDOWN`, bloquear ataque.
5. Enviar feedback ao jogador com tempo restante de bloqueio.

### Decisão de persistência do cooldown

Para a variável proposta (`self.lastCaptureTick`):

- **em memória**: simples e suficiente para evitar ping-pong durante sessão.
- **persistido em DB**: necessário se quiser manter cooldown mesmo após restart/crash.

Se o objetivo for proteção estrita “mesmo após reboot”, será preciso coluna adicional, por ex.:

- `last_capture_tick` (ou timestamp datetime) em `tbl_gang_areas`.

---

## Dependências e riscos

### Dependências
- Nenhuma lib externa nova.
- Usa infra já existente (`Database`, `Area`).

### Riscos técnicos
1. **Persistência síncrona em alta frequência**  
   Mitigação: gravar apenas quando owner muda (evento raro), não em cada tick.

2. **Mensagens de cooldown sem contexto de tempo**  
   Mitigação: exibir segundos restantes ao atacante.

3. **Cooldown só em memória**  
   Mitigação: documentar comportamento pós-restart; persistir no DB se regra exigir.

---

## Plano de implementação sugerido (ordem)

1. Implementar persistência imediata em `setOwner(...)`.
2. Validar conquistas consecutivas e crash simulation local (quando possível).
3. Adicionar `lastCaptureTick` + guarda de cooldown no `onColShapeHit`.
4. Adicionar feedback de tempo restante.
5. (Opcional) Persistir cooldown no banco se requisito for sobreviver a reinício.

---

## Conclusão

As duas melhorias propostas são **viáveis** e **compatíveis com a arquitetura atual**.

- **Persistência imediata**: recomendada e prioritária para integridade de dados.
- **Cooldown anti ping-pong**: recomendada para qualidade de experiência e equilíbrio.

Com essas duas entregas, o status de 88% é coerente e há caminho claro para evolução com baixo risco.
