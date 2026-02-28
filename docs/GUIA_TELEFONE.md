# 📱 Guia do Telefone (Abrir, Fechar e Usar)

## Objetivo

Este guia explica, de forma prática, como usar o telefone in-game no estado atual do projeto.

---

## 1) Como abrir o telefone

Atualmente, o telefone inicia oculto e é controlado pelo comando:

```txt
/phone
```

Na prática:

1. Entre no servidor normalmente.
2. Digite `/phone` no chat.
3. O telefone aparece no lado direito da tela com o mouse livre para clicar.

> Referência técnica: `hud/client/phone/Phone.lua` (`addCommandHandler("phone", ...)`).

---

## 2) Como fechar o telefone

Para fechar/ocultar, digite novamente:

```txt
/phone
```

- O comando funciona em modo toggle (abre/fecha).
- Ao fechar, o cursor também é ocultado.

---

## 3) Como usar os apps

Na tela inicial (Home), clique nos cards:

- **Informações**
  - Abre o app de busca de jogador online.
  - Você pode pesquisar por nome exato ou parte do nome.
  - Exibe dados reais: conta, kills, deaths, gang, dinheiro, banco, VIP e K/D.

- **Telefone**
  - Mostra mensagem de status no chat (módulo de chamadas ainda em desenvolvimento).

- **Config**
  - Abre a tela de configurações visuais existentes.

- **Informações Gang War**
  - Mostra orientação rápida no chat sobre comandos/painéis do sistema.

- **Banco App**
  - Abre o painel bancário já existente.
  - Permite: depósito, saque e transferência.

- **Maps**
  - Mostra orientação para abrir o mapa do jogo (`F11`).

- **Guerra**
  - Mostra status da gang atual no chat e orientação de uso do painel de guerra.

---

## 4) Navegação (botão voltar)

- O botão inferior do aparelho (área de “voltar”) chama a ação definida pelo app atual.
- Exemplos:
  - Em **Informações**, volta para a Home.
  - Em **Config**, volta para a Home.

---

## 5) Observações importantes

- Este guia descreve o comportamento atual da implementação.
- O botão físico inferior do aparelho continua funcionando como **voltar de app**.
