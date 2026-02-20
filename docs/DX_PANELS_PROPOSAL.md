# 🎨 Proposta de Painéis DX — Gang War MTA:SA

> **Objetivo:** Identificar todos os sistemas do gamemode que poderiam ou deveriam ter painéis DX criados (ou melhorados), tornando a experiência mais fácil, dinâmica e visualmente bonita.  
> **Nenhuma alteração de código foi realizada neste documento.**

---

## 📋 Índice

- [Contexto](#-contexto)
- [Sistemas com Painéis Existentes](#-sistemas-com-painéis-existentes-mas-que-podem-ser-melhorados)
- [Sistemas sem Painéis DX](#-sistemas-sem-painéis-dx-prioridade-de-criação)
- [Resumo Geral](#-resumo-geral)
- [Prioridade de Implementação](#-prioridade-de-implementação)

---

## 🔍 Contexto

O gamemode utiliza um framework OOP (Orientado a Objetos) próprio para DX, localizado em `hud/` e acessado via `exports.hud:callHud(...)`. Os painéis são construídos com componentes como `Container`, `Panel`, `Label`, `Button`, `TextField`, `Image`, `ProgressBar`, etc.

Vários sistemas já possuem painéis DX. Porém, existem sistemas inteiramente gerenciados por **comandos de chat** (`/comando`) ou **mensagens de chatbox** sem qualquer interface visual dedicada. Esses sistemas são os candidatos principais para criação de painéis DX.

---

## ✅ Sistemas com Painéis Existentes (mas que podem ser melhorados)

### 1. 🏦 Sistema Bancário — `hud/client/bank/BankSystem.lua`

**Estado atual:** Painel funcional com botões de Depositar, Sacar e Transferir.

**Melhorias sugeridas:**
- Adicionar **histórico de transações** — um painel auxiliar listando as últimas N operações (depósito, saque, transferência, com data/hora e valor).
- Exibir **barra de progresso** mostrando quanto do saldo bancário foi utilizado em relação ao limite.
- Adicionar **animações de transição** (fade/slide) ao alternar entre os sub-painéis de depósito, saque e transferência.
- Campo de busca no painel de transferência com **autocomplete** de jogadores online.
- Feedback visual em tempo real (campo fica vermelho se o valor inserido exceder o saldo disponível).

---

### 2. 🔐 Tela de Login e Registro — `hud/client/login/LoginZ.lua` e `RegisterZ.lua`

**Estado atual:** Painéis básicos com campos de texto e botões, fundo preto e blur shader ativo.

**Melhorias sugeridas:**
- Substituir o **fundo preto puro** por um painel com imagem de fundo temática (screenshot do mapa, arte da gang war) com transparência.
- Adicionar **animação de entrada** do painel ao carregar (slide vindo de cima ou fade-in).
- Mostrar uma **tela de boas-vindas** diferenciada para quem já tem conta (retornando) versus quem é novo.
- Incluir **indicadores visuais de erro** diretamente no campo (borda vermelha + ícone) quando login/senha estiver incorreto, em vez de apenas mensagem no chat.
- Mostrar **dicas de jogo** na lateral direita enquanto o player aguarda o carregamento.

---

### 3. 👗 Seletor de Spawn/Skin — `hud/client/login/SpawnSelector.lua`

**Estado atual:** Painel com categorias de skins e botões de navegação (<<, SPAWN, >>).

**Melhorias sugeridas:**
- Adicionar **preview em 3D da skin** atual do jogador (câmera fixa sobre o personagem com rotação lenta).
- Mostrar o **número da skin** e o **nome da categoria** selecionada com estilo visual.
- Indicar quais skins são **exclusivas de VIP** (ícone de cadeado ou cor diferente para skins bloqueadas).
- Substituir a lista plana de categorias por uma **grade visual** de thumbnails das skins (mini-imagem de cada modelo).
- Botão de confirmação mais visível e animado ao selecionar spawn.

---

### 4. ⚔️ Painel de Ataque de Território — `hud/client/turf/AttackTerritory.lua`

**Estado atual:** Painel mostrando nome da zona, gangues envolvidas, pontos, mortes, players na área e tempo restante.

**Melhorias sugeridas:**
- Substituir os labels de pontos por **barras de progresso** coloridas com as cores das gangues, mostrando proporção visual dos pontos.
- Adicionar **mini-mapa embutido** no painel mostrando a área do território sendo disputado (zona destacada no radar).
- Usar **efeito de piscar/highlight** quando uma gangue estiver prestes a vencer (últimos 30 segundos).
- Animar o contador de tempo (ficar vermelho ao se aproximar do fim).
- Mostrar **avatares ou ícones** das gangues com suas cores ao lado dos nomes.

---

### 5. 🗺️ Painel de Informação de Território — `hud/client/turf/DominationTerritory.lua`

**Estado atual:** Painel 3D exibindo tipo, nome da área e gangue dominante, com barra de progresso de dominação.

**Melhorias sugeridas:**
- Aplicar **cor dinâmica de fundo** baseada na cor da gangue dominante (fundo torna-se levemente colorido com a cor da gang).
- Exibir **ícone do tipo de território** (ícone diferente para Território, Gang Zona, Villa).
- Adicionar **XP gerado** pelo território para servir como informação estratégica.
- Mostrar há **quantos minutos o território está sob domínio** atual.

---

### 6. 📱 Telefone — `hud/client/phone/`

**Estado atual:** Interface de smartphone com apps: Informações, Configurações, Banco App, Maps, War.

**Melhorias sugeridas:**
- **InfoApp:** Conectar os campos à dados reais do jogador pesquisado (kills, deaths, gang, dinheiro, VIP) em vez de dados estáticos. Adicionar botão de enviar mensagem.
- **HomeApp:** Implementar funcionalidade real nos apps de "Telefone" (ligar para outros players), "Banco App" (abrir BankSystem), "Maps" (exibir mapa com territórios coloridos).
- **ConfigApp:** Implementar as opções visuais de personalização (troca de papel de parede funcional), configuração de HUD e painel de VIP com benefícios listados.
- Adicionar app de **Chat de Gang** diretamente no telefone.
- Adicionar app de **Rankings** (top 5 gangues por XP, top players por kills).
- Exibir **notificações de badge** nos ícones dos apps (ex.: novo evento de guerra, território sob ataque).

---

## 🆕 Sistemas sem Painéis DX (Prioridade de Criação)

### 7. 🏴 Sistema de Gangues — `Class/Gang.lua` + comandos `/gang`

**Estado atual:** 100% gerenciado via comandos de chat:  
`/gang create`, `/gang invite`, `/gang kick`, `/gang promote`, `/gang demote`, `/gang info`, `/gang members`, `/gang color`, `/gang slogan`, `/gang leave`

**Por que criar um painel DX:**  
Navegar entre todas as opções via chat é confuso para novos jogadores. Um painel centralizado de gestão de gang tornaria tudo mais intuitivo e acessível.

**O que o painel deveria conter:**

**Aba "Minha Gang"**
- Nome da gang, tag, cor (prévia colorida), slogan editável.
- XP atual com barra de progresso até o próximo nível/desbloqueio.
- Lista de membros com nick, nível hierárquico (ícone/cor por nível: Convidado, Membro, Comandante, Líder), e opções de promoção/expulsão (visíveis apenas para líderes/comandantes).
- Botão "Sair da Gang".

**Aba "Criar Gang"** (para quem não tem gang)
- Campo de nome, tag (máx. 4 chars), seletor de cor RGB com preview ao vivo.
- Custo visível ($400.000) com saldo atual do jogador.
- Botão de confirmação.

**Aba "Convidar"**
- Lista de jogadores online (com busca) para convidar.

**Aba "Informações"**
- Ranking das gangues ativas por XP.
- Territórios dominados pela gang atual.

---

### 8. 🏠 Sistema de Propriedades — `Class/Properties.lua` + `hud/client/gameplay/Properties_c.lua`

**Estado atual:** Exibe informações (nome, preço, lucro, dono) via `dxDrawText` em 3D no mundo, e utiliza comandos de chat (`/comprar`, `/vender`) ao entrar na colshape da propriedade.

**Por que criar um painel DX:**  
Interação por comando de chat é pouco intuitiva. Um painel visual ao entrar na área da propriedade comunica as informações com mais clareza e reduz erros do jogador.

**O que o painel deveria conter:**
- **Ativado automaticamente** ao entrar na colshape da propriedade (mesmo comportamento do banco).
- Nome e tipo da propriedade (com ícone temático: cassino, loja, hotel...).
- Preço de compra e valor de lucro passivo por ciclo.
- Status: "Disponível" (verde) ou "Pertence a [NomeJogador]" (vermelho/amarelo).
- Seu saldo atual × preço (feedback visual se tem dinheiro suficiente).
- Botões: **Comprar** / **Vender** (visível somente se for o dono).
- Lista de todas as propriedades do jogador acessível via telefone (app "Propriedades").

---

### 9. 🏗️ Sistema de Bases — `Class/Base.lua`

**Estado atual:** Não há interface visual. A compra e informações sobre bases são gerenciadas exclusivamente via marcador (marker) e eventos no servidor, sem nenhum painel DX dedicado.

**Por que criar um painel DX:**  
Comprar uma base é uma das ações mais importantes e custosas do servidor ($450k–$1M). O jogador merece uma interface clara com todas as informações antes de confirmar.

**O que o painel deveria conter:**
- **Ativado ao entrar no marker** da base.
- Nome e imagem/ícone da base.
- Preço de compra e gang atual dona (se houver).
- Lista de veículos incluídos (com ícones dos modelos).
- Veículo especial exclusivo da base (destaque visual).
- Botão "Comprar Base" (com confirmação via segundo clique ou janela modal).
- Botão "Sair" para fechar o painel.
- Se a gang já possui uma base, mostrar aviso de que só é permitida uma base por gang.

---

### 10. 📊 Painel de Ranking / Leaderboard

**Estado atual:** O jogo usa o resource externo `scoreboard` para exibir kills, deaths, ratio e dinheiro por jogador. Não há ranking de gangues por XP visível na interface.

**Por que criar um painel DX:**  
Um painel de ranking bonito e animado motiva a competitividade e é um elemento estético marcante para o servidor.

**O que o painel deveria conter:**
- **Aba Gangues:** Top 10 gangues por XP, mostrando posição, nome com cor da gang, XP, quantidade de membros, territórios dominados.
- **Aba Jogadores:** Top 10 jogadores por kills, com nick colorido pela gang, kills, deaths, K/D ratio.
- Destaque visual (gold/silver/bronze) para as 3 primeiras posições.
- Atualização periódica suave (sem recriar o painel, apenas atualizar os labels).
- Atalho via tecla (`F10` ou configurável) e também acessível pelo app de telefone.

---

### 11. 🔔 Sistema de Notificações (Toast/Popup)

**Estado atual:** Toda comunicação ao jogador é feita via `outputChatBox()` — mensagens de propriedade comprada, territórios atacados, gangue dominante, dinheiro recebido de renda etc. aparecem misturadas no chat.

**Por que criar um painel DX:**  
Notificações visuais temporárias (estilo "toast notification") são infinitamente mais visíveis e elegantes do que mensagens no chat.

**O que o sistema deveria exibir via toast:**
- **Território sob ataque** (nome do território, gangue atacante, cor da gang).
- **Renda de propriedades recebida** (valor em verde).
- **Convite para gang** recebido (com botões Aceitar/Recusar no próprio toast).
- **Desbloqueio de XP** (gang avançou de nível / novo tipo de território acessível).
- **Jogador morto por você** (nick, arma utilizada).
- **Base capturada** (por qual gang).
- Cada toast aparece no canto da tela, empilhado, e desaparece após ~4 segundos com fade-out.

---

### 12. 💀 Tela de Wasted (Morte do Jogador)

**Estado atual:** Usa a tela padrão de wasted do GTA:SA / MTA, sem personalização.

**Por que criar um painel DX:**  
Uma tela de morte customizada é um elemento visual de alto impacto que valoriza a experiência e pode fornecer informações úteis.

**O que a tela deveria conter:**
- Overlay escuro gradual com texto "WASTED" estilizado (fonte temática, cor da gang que te matou).
- Nick do jogador que te matou, com a arma usada (ícone da arma).
- Suas estatísticas da última vida: kills feitas, tempo vivo.
- Contador de respawn (ex.: "Respawnando em 4s...").
- Botão de spawn acelerado (para VIPs).

---

### 13. 🚗 Painel de Veículos Especiais — `Class/specialVehicle.lua`

**Estado atual:** Não há interface visual. O cooldown de 10 minutos dos veículos especiais (Hunter, Hydra, Rhino, Seasparrow) e seu status de disponibilidade não são exibidos ao jogador.

**Por que criar um painel DX:**  
Sem feedback visual, jogadores não sabem se o veículo especial está disponível ou em cooldown, causando frustração.

**O que o painel deveria conter:**
- Exibido **apenas para membros da gang** que possui aquela base.
- Ícone do veículo especial (imagem do modelo) com seu nome.
- Status: "Disponível" (verde) ou "Em cooldown — Xx min restantes" (vermelho + barra de progresso).
- Ativado ao entrar na base, desativado ao sair.

---

### 14. 🛡️ Painel de Administração

**Estado atual:** Não há painel de administração visual no código do gamemode. Administração é feita via console/comandos.

**Por que criar um painel DX:**  
Um painel de admin visual aumenta produtividade e reduz erros na gestão do servidor.

**O que o painel deveria conter:**
- Lista de jogadores online com informações rápidas (nick, gang, dinheiro, nível).
- Botões de ação: Kick, Ban, Mute, Teleport, Dar Dinheiro, Mudar Gang.
- Lista e gestão de gangues (deletar gang, alterar cor/tag, editar XP).
- Lista de propriedades com filtro por dono.
- Logs de ações recentes (últimas 50 ações de admin).
- Acesso restrito por ACL (apenas admins visualizam o painel).

---

### 15. 🧭 HUD Principal (Durante o Gameplay)

**Estado atual:** O jogo exibe o HUD padrão do GTA:SA (HP, armadura, dinheiro, arma etc). Não há HUD customizado em DX para o gamemode.

**Por que criar um painel DX:**  
Um HUD customizado é a identidade visual do servidor. Elimina elementos do HUD padrão e substitui por uma interface coesa e temática.

**O que o HUD deveria exibir:**
- **HP e Armadura** com barras DX coloridas (verde→amarelo→vermelho de acordo com a vida).
- **Dinheiro em mão** (em tempo real via `getData("money")`).
- **Saldo bancário** (valor no banco).
- **Gang e Tag** do jogador (com cor da gang).
- **Nível hierárquico** (Convidado, Membro, Comandante, Líder).
- **XP da gang** e barra de progresso até o próximo marco.
- **Área atual** (nome do território/gang zona que o jogador está pisando).
- HUD deve ser **minimizável** (tecla H) para não atrapalhar visibilidade.

---

## 📊 Resumo Geral

| # | Sistema | Tem Painel DX? | Prioridade |
|---|---------|----------------|-----------|
| 1 | Sistema Bancário | ✅ Sim (melhorias) | 🟡 Média |
| 2 | Login / Registro | ✅ Sim (melhorias) | 🟡 Média |
| 3 | Seletor de Skin/Spawn | ✅ Sim (melhorias) | 🟡 Média |
| 4 | Ataque de Território | ✅ Sim (melhorias) | 🟡 Média |
| 5 | Info de Território | ✅ Sim (melhorias) | 🟢 Baixa |
| 6 | Telefone / Apps | ✅ Sim (melhorias) | 🟡 Média |
| 7 | **Sistema de Gangues** | ❌ **Não** | 🔴 **Alta** |
| 8 | **Sistema de Propriedades** | ❌ **Não** | 🔴 **Alta** |
| 9 | **Sistema de Bases** | ❌ **Não** | 🔴 **Alta** |
| 10 | **Ranking / Leaderboard** | ❌ **Não** | 🟠 Média-Alta |
| 11 | **Notificações Toast** | ❌ **Não** | 🟠 Média-Alta |
| 12 | **Tela de Wasted** | ❌ **Não** | 🟠 Média-Alta |
| 13 | **Veículos Especiais** | ❌ **Não** | 🟡 Média |
| 14 | **Painel Admin** | ❌ **Não** | 🟡 Média |
| 15 | **HUD Principal** | ❌ **Não** | 🔴 **Alta** |

---

## 🎯 Prioridade de Implementação

### 🔴 Alta Prioridade (maior impacto na experiência do jogador)

1. **HUD Principal** — Impacto constante em toda partida; ausência faz o servidor parecer "genérico".
2. **Sistema de Gangues (Painel)** — A gang é o coração do gamemode; gerenciar via chat é confuso.
3. **Sistema de Propriedades (Painel)** — Compra/venda via comando de chat é frustrante e não intuitivo.
4. **Sistema de Bases (Painel)** — Decisão de alto valor financeiro precisa de interface clara.

### 🟠 Média-Alta Prioridade (melhoria significativa de usabilidade)

5. **Notificações Toast** — Reduz poluição no chat; melhora feedback de eventos importantes.
6. **Ranking / Leaderboard** — Elemento competitivo essencial para engajamento dos jogadores.
7. **Tela de Wasted** — Polimento visual de alto impacto com implementação relativamente simples.

### 🟡 Média Prioridade (melhorias incrementais nos sistemas existentes)

8. **Painel de Gangues — Melhorias nos painéis existentes** (histórico de membros, preview de cor).
9. **Veículos Especiais** — Feedback do cooldown melhora a estratégia dos jogadores.
10. **Telefone — Apps funcionais** (especialmente InfoApp e BankApp).
11. **Painel Admin** — Útil para gestão, mas não afeta diretamente os jogadores comuns.

### 🟢 Baixa Prioridade (polimento fino)

12. **Login/Registro** — Já funciona bem; melhorias são cosméticas.
13. **Seletor de Skin/Spawn** — Melhorias de UX que não impactam o gameplay principal.
14. **Info de Território** — Já exibe as informações essenciais; cor dinâmica seria bônus.

---

## 💡 Notas Técnicas

- **Framework DX existente:** Todo painel novo deve seguir o padrão OOP já estabelecido (usar `Class`, herdar de `Container` ou `Panel`, usar `singleton` via `LuaObject.getSingleton`).
- **Arquivos de HUD:** Novos painéis de cliente devem ser adicionados em `hud/client/` na pasta correspondente ao sistema.
- **Comunicação servidor-cliente:** Para painéis que precisam de dados do servidor (gang info, propriedades, bases), usar `triggerClientEvent` e `triggerServerEvent` seguindo o padrão dos sistemas existentes.
- **Escalabilidade de resolução:** Sempre usar `Graphics.getInstance():getSize()` para obter dimensões de tela e calcular posicionamento relativo, garantindo compatibilidade com diferentes resoluções.
- **CSS do framework:** Utilizar o método `:css()` para estilizar botões e componentes de forma centralizada, mantendo consistência visual entre os painéis.

---

*Documento gerado em análise de código — fevereiro/2026*
