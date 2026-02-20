# 🏴 Gang War — Prévia para Equipes | Servidor em Desenvolvimento

> **Este documento é destinado a líderes e organizadores de equipes grandes** que desejam entender o funcionamento estratégico do servidor antes do lançamento oficial.
>
> 🚧 *O servidor está em desenvolvimento ativo. Algumas features podem ser ajustadas antes do lançamento.*

---

## 📋 O que é o Gang War?

**Gang War** é um gamemode completo para **MTA:SA (Multi Theft Auto: San Andreas)** construído em torno de disputas territoriais entre gangues organizadas. O sistema foi projetado para recompensar equipes coesas, com hierarquia funcional, gestão de recursos e estratégia de expansão territorial.

Se a sua equipe tem organização, disciplina e quer dominar o mapa — este servidor foi feito para você.

---

## 🏗️ Estrutura da Gangue

### Criação
- **Custo:** $400.000 (in-game)
- **Requisito:** Jogador sem gang ativa

### Hierarquia de 4 Níveis

| Nível | Nome | Permissões |
|-------|------|-----------|
| 4 | **Líder** | Tudo — criação, tag, slogan, liderança, compra de base, deletar gang |
| 3 | **Comandante** | Convidar membros, expulsar, gerenciar levels, comprar base |
| 2 | **Membro** | Combate, dominar territórios, usar pickups e veículos da gang |
| 1 | **Convidado** | Acesso básico, combate |

### Personalização da Gang
- **Nome:** 4–20 caracteres, único por servidor
- **Tag:** Até 4 caracteres em maiúsculas (ex: `[GS]`, `PDU`), exibida no nametag dos membros
- **Cor RGB:** Define a cor do nametag, do radar e das áreas dominadas no mapa
- **Slogan:** Texto de até 20 caracteres exibido nas zonas dominadas

### Mecânica de Convites
- Convites enviados por ID do jogador (`/gang convite <id>`)
- Expiram automaticamente em **60 segundos** se não forem aceitos
- Apenas Líderes e Comandantes podem convidar

---

## 🗺️ Sistema de Territórios — 70 Zonas de Guerra

O coração do servidor. Toda a progressão da gangue é medida em **XP**, e o XP é obtido e mantido **dominando territórios**.

### Os 3 Tipos de Território

| Tipo | Quantidade | XP por Zona | XP Mínimo para Atacar | Benefício Extra |
|------|-----------|-------------|----------------------|-----------------|
| **Território** | 58 | 1.000 | Nenhum | — |
| **Gang Zona** | 8 | 5.000 | 6.000 XP da gang | Veículos + Pickups de Armas |
| **Villa** | 4 | 10.000 | 11.000 XP da gang | Bônus de respawn (ver abaixo) |

### Distribuição Geográfica
As 60 zonas de território cobrem toda a **San Andreas**:
- **Los Santos** — Las Colinas, East Beach, Ganton, Idlewood, Commerce, Verdant Bluffs, Market, Mulholland, Downtown, Vinewood, Richman, Glen Park, etc.
- **San Fierro** — Paradiso, Juniper Hollow, Esplanade East, Financial, Calton Heights, Downtown SF, Easter Basin, Red County, Garcia, Queens, Palisades, City Hall, etc.
- **Las Venturas** — Territórios dispersos pelo mapa

As **8 Gang Zonas** incluem localizações estratégicas em **Las Venturas**:
> Baseball · Airport LV · Bank · Come-A-Lot · Dime Motel · Docks · Rock Hotel · KACC

As **4 Villas** são:
> Fort Carson · Palomino Creek · Blueberry · DilliMore

---

## ⚔️ Mecânica de Domínio — Como Funciona na Prática

A captura de qualquer território ocorre em **duas fases**:

### Fase 1 — Dominação (Pré-Ataque)
> Quando um membro da sua gang entra em território inimigo e a zona **não está em modo de ataque**, começa a fase de dominação.

- **Tempo base:** 260 segundos (4 min 20s)
- **Acelerador:** −500ms por cada membro da gang na área por segundo
  - Com 5 membros na área: ~185 segundos (≈3 min)
  - Com 10 membros na área: ~110 segundos (≈1 min 50s)
- Durante esta fase, o defensor recebe **alerta** de que está sendo atacado
- Se todos os atacantes saírem da área, a dominação é cancelada

### Fase 2 — Ataque (Batalha de Pontos)
> Após a dominação ser concluída, começa a batalha real.

- **Duração:** 200 segundos (3 min 20s) fixos
- **Sistema de Pontos:**
  - Defensor começa com **500 pontos** de vantagem
  - Cada jogador na área gera pontos por segundo para sua gang
  - Cada **morte** de um membro da gang inimiga dentro da área vale **+300 pontos** para a gang adversária
- **Vencedor:** A gang com mais pontos ao final do tempo
- Se o **defensor vencer**, ganha **+1.000 XP** e mantém o território
- Se o **atacante vencer**, rouba o XP total da zona do defensor e ganha o XP

**→ Conclusão estratégica:** Ter mais membros na área não apenas acelera a dominação, mas também gera mais pontos durante o ataque. Equipes grandes têm vantagem direta.

---

## 🏢 Bases — O Topo da Progressão

Bases são instalações militares que a sua gang pode comprar e defender. Cada gang pode possuir **apenas uma base** simultâneamente.

### Requisitos para Comprar uma Base
- Gang com **10.000+ XP**
- Membro com nível **Líder ou Comandante**
- Dinheiro suficiente para o custo

### As 5 Bases Disponíveis

| Base | Preço | Veículo Especial | Localização |
|------|-------|-----------------|------------|
| **Area 51** | $1.000.000 | 🚁 **Hunter** (Helicóptero de Ataque) | Deserto |
| **Fabrica** | $525.000 | ✈️ **Hydra** (Caça VTOL) | Las Venturas Norte |
| **Departamento Militar** | $500.000 | 🛡️ **Rhino** (Tanque) | Las Venturas |
| **Construção** | $475.000 | 🚁 **Seasparrow** (Helicóptero Armado) | Las Venturas Leste |
| **Garagem** | $450.000 | 🚁 **Seasparrow** (Helicóptero Armado) | Las Venturas |

### O que cada base inclui:
- **Frota de veículos** exclusiva da gang (15–22 veículos, incluindo carros e motocicletas)
- **Pickups de armas**, saúde e armadura — acessíveis apenas para membros da gang dona
- **Portão animado** que abre automaticamente para membros da gang (fecha para inimigos)
- **Veículo especial** com acesso restrito + cooldown de 10 minutos após uso

### Mecânica de Venda/Compra de Base
- Se uma gang comprar uma base que pertence a outra, o **dinheiro vai para o membro de mais alto nível** da gang anterior que estiver online
- Ao comprar a base, a gang recebe **+10.000 XP** bônus
- A cor de todos os veículos da base é **atualizada automaticamente** com a cor da nova gang dona

---

## 🔄 Sistema de Respawn — Onde sua Gang Renasce

O ponto de respawn de um membro é determinado pela posição da gang:

```
Prioridade de Respawn:
1. Se a gang tem BASE → Renasce na base
2. Se a gang tem GANG ZONA → Renasce na gang zona de menor ID
3. Sem base e sem gang zona → Ponto aleatório em Las Venturas
```

### Bônus das Villas no Respawn
- **Fort Carson:** Gang dona recebe **+100 de armadura** ao nascer
- **Blueberry:** Gang dona recebe **+$25.000** ao nascer

---

## 🔫 Armas — Sistema de Spawn

Todo jogador ao nascer recebe um **pacote padrão aleatório** composto por:

| Categoria | Opções |
|-----------|--------|
| Pistola | Desert Eagle |
| Escopeta | Sawnoff, Shotgun, ou Combat Shotgun |
| Metralhadora | Micro UZI, MP5, ou TEC-9 |
| Fuzil | M4 ou AK-47 |

**Danos de armas (balanceados pelo servidor):**
- M4/AK-47: 18 de dano por tiro
- Desert Eagle: 15 por tiro
- Combat Shotgun/Espingarda: 8 por tiro
- MP5: 7 por tiro

### Pickups de Armas nas Bases/Gang Zonas
Disponíveis **somente para membros da gang dona** — incluem rifles de alto nível, escopetas e explosivos com munição limitada.

---

## 💰 Economia da Gang

### Dinheiro do Servidor
- Cada jogador tem **dinheiro em mão** (perde ao morrer: reset para $500) e **saldo bancário** (persiste entre mortes e sessões)
- Novo jogador começa com **$100.000 no banco**

### Banco
- Operações: Depósito, Saque, Transferência entre jogadores
- Saldo bancário salvo no banco de dados, não se perde
- Acesso físico (marcadores no mapa) ou via telefone *(em desenvolvimento, ainda não funcional)*

### Propriedades (Renda Passiva)
- **53 propriedades** disponíveis para compra individual (não da gang)
- Preços: $10.000 (Tatoo Shop) até $500.000 (Marine)
- **Renda passiva:** 10% do valor a cada 10 minutos
- Exemplos: Come-A-Lot ($180k → $18k/10min), Country Club ($180k → $18k/10min), Golf Club House ($125k → $12.5k/10min)

---

## 📍 Sistema de Marcação de Mapa

Líderes e Comandantes podem usar `/gang marcar` para criar um **blip exclusivo no mini-mapa**, visível apenas para membros da gang. Útil para coordenação tática durante ataques.

---

## 📊 XP — Progressão e Ranking

O XP da gang é **dinâmico**: reflete diretamente os territórios dominados no momento.

```
XP = soma de todos os territórios dominados atualmente pela gang
```

| Ao ganhar ataque | +XP do território |
| Ao defender | +1.000 XP fixo |
| Ao perder território | -XP do território |

**Limites de Acesso por XP:**

| Sistema | XP Mínimo |
|---------|-----------|
| Atacar Gang Zona | 6.000 XP |
| Atacar Villa | 11.000 XP |
| Comprar Base | 10.000 XP (+ 12.000 para manter acesso ao sistema) |

**Ranking:** Comando `/top` exibe o top 10 de gangues por XP, com nome em cor da gang e slogan.

---

## 📱 Ferramentas de Gestão In-Game

| Comando | Função | Nível Requerido |
|---------|--------|-----------------|
| `/gang criar <nome>` | Criar nova gang | Qualquer (sem gang) |
| `/gang convite <id>` | Convidar jogador | Líder / Comandante |
| `/gang aceitar` | Aceitar convite | Qualquer |
| `/gang recusar` | Recusar convite | Qualquer |
| `/gang kick <id>` | Expulsar membro | Nível superior ao alvo |
| `/gang level <id> <1-3>` | Promover/rebaixar | Nível superior ao alvo |
| `/gang lider <id>` | Transferir liderança | Líder |
| `/gang tag <tag>` | Definir tag | Líder |
| `/gang slogan <texto>` | Definir slogan | Líder |
| `/gang marcar` | Marcar ponto no mapa | Líder / Comandante |
| `/gang abandonar` | Sair da gang | Qualquer membro |
| `/gang deletar` | Dissolver a gang | Líder |
| `/top` | Ranking de gangues | Todos |
| `/gangzonas` | Lista gang zonas e donos | Todos |
| `/vilas` | Lista villas e donas | Todos |
| `/bases` | Lista bases e preços | Todos |

---

## 🏆 Estratégia para Equipes Grandes

Com base no funcionamento dos sistemas, estes são os pilares estratégicos para equipes que desejam dominar o servidor:

### 1. Priorize Gang Zonas antes de Villas
As 8 Gang Zonas fornecem **frota de veículos** e **pickups de armas** para a gang. Dominar ao menos 1 gang zona antes de tentar uma villa é essencial (já que o respawn estratégico depende delas).

### 2. Manter presença em área é tudo
Cada membro extra na zona acelera a dominação e gera pontos durante o ataque. **Organize incursões em grupo** — um soldado sozinho raramente captura uma zona disputada.

### 3. A base é um multiplicador de força
Uma base garante respawn centralizado, armas pesadas e veículos especiais. Focar em acumular **10.000 XP** o mais rápido possível para poder comprar uma base é uma jogada essencial.

### 4. Fort Carson + Blueberry = poder de sustentação
Controlar as duas villas principais garante que sua gang respawne com armadura completa E com dinheiro extra. Isso reduz drasticamente o tempo de recuperação em combate prolongado.

### 5. Hierarquia funciona — use-a
Ter Comandantes confiáveis que possam convidar e gerenciar membros sem depender do Líder é crítico para gangs grandes. Distribua o papel de Comandante estrategicamente.

### 6. Defender vale XP também
Não apenas conquiste — **defend suas zonas ativamente**. Uma defesa bem-sucedida rende **+1.000 XP** fixo, independente do valor da zona.

---

## 📬 Contato e Acesso Antecipado

> Este documento é uma prévia do servidor que está em desenvolvimento.  
> Para solicitar informações sobre acesso antecipado, recrutamento de equipes ou parcerias de divulgação, entre em contato com a administração do servidor.

---

*Gang War — Desenvolvido para a comunidade MTA:SA brasileira.*  
*Documento de prévia — fevereiro/2026*
