# Implantação em campo · 26/09/2026

Registro do que foi feito no local, na ordem real, com os problemas encontrados e como foram resolvidos. O plano original está no [guia](guia/guia-implantacao.html) e nos [ajustes da revisão](ajustes-da-revisao.md); onde houver diferença, **vale este documento**.

## Situação encontrada

![Cenário antes](img/cenario-antes.svg)

- Duas operadoras (Operadora A e Operadora B), cada uma com seu roteador. O modem da Operadora A estava ligado na LAN do roteador da Operadora B: **duas redes misturadas**, dois DHCPs.
- Sem troca automática entre operadoras.
- O switch de 24 portas previsto não existia mais; usado um **switch de 8 portas**.
- hEX com **RouterOS 6.49.20** e configuração anterior desconhecida.
- Notebook de campo **só com Wi-Fi** (sem porta de rede).
- Contêineres fechados (sem acesso físico às salas).

## Sequência executada

| # | Etapa | Resultado |
|---|---|---|
| 1 | Levantamento: faixas das operadoras | Operadora A `192.168.10.x`, Operadora B `192.168.20.x`: sem conflito |
| 2 | Reset pelo botão | Caiu em **modo CAP** (bridge `bridgeLocal`); sem problema, o A7 apaga tudo |
| 3 | Isolar o modem da Operadora A (sem cabo para o roteador da Operadora B) e acessar pelo Wi-Fi da Operadora A | Acesso por IP depois de reiniciar o hEX (o IP antigo era da faixa da Operadora B) |
| 4 | Upgrade **6.49.20 → 7.23.7** (`channel=upgrade`) | OK, via Winbox 3 |
| 5 | Firmware 7.23.7 | `current-firmware = upgrade-firmware` |
| 6 | Envio do `failover.rsc` para `flash/` e reset com `run-after-reset` | Script **parou** em `hw-offload` (ver abaixo) |
| 7 | Acesso pelo lado LAN: roteador da Operadora B ligado na `ether3` + IP fixo `172.16.10.9` no Wi-Fi do notebook | Log lido, restante da configuração aplicado à mão |
| 8 | Usuário administrativo próprio criado | OK |
| 9 | Cabos na posição final (Operadora A `ether1`, roteador da Operadora B `ether2`, switch `ether3`) | Cabo `ether3` ↔ switch **defeituoso**, trocado |
| 10 | Acesso de manutenção pelo Wi-Fi do roteador da Operadora B (`192.168.20.250`) | Salas fechadas: única forma de administrar daqui |
| 11 | Testes (links, rotas, failover, sala de ponta a ponta) | Todos aprovados |
| 12 | `admin` desativado, backup `config-final`, notebook de volta ao DHCP | OK |

## Problemas e soluções

| Problema | Causa | Solução |
|---|---|---|
| `bad parameter hw-offload` no run-after-reset | Parâmetro de fasttrack não existe no RB750Gr3 | Removido do [`failover.rsc`](../failover.rsc); resto aplicado manualmente |
| Winbox 4 travava no login | hEX ainda no RouterOS 6 | Winbox 3 só até concluir o upgrade |
| `channel=stable` não oferecia a v7 | No RouterOS 6 o salto para o 7 é pelo canal `upgrade` | `set channel=upgrade` → install → depois `stable` |
| Neighbors mostrava o hEX, mas ping/Winbox por IP falhavam | hEX com IP de outra faixa (lease antigo) | Reiniciar o hEX para renovar o DHCP |
| Script podia sumir no reboot | No RouterOS 7 desse modelo, arquivos fora de `flash/` ficam em RAM | Mover para `flash/failover.rsc` antes do reset |
| Notebook sem porta de rede | — | Roteador Wi-Fi ligado na bridge + IP fixo no Wi-Fi (desfeito ao final) |
| Sem luz na porta hEX ↔ switch | Cabo defeituoso | Cabo substituído |
| Salas trancadas, sem Wi-Fi delas | — | Regra `GERENCIA-VIA-OPB` ([exemplo 03](exemplos/03-gerencia-via-operadora-b.rsc)) |

## Validação

| Teste | Resultado |
|---|---|
| DHCP das duas operadoras | `bound` / `bound` |
| Rota principal | Operadora A ativa, Operadora B em espera |
| Queda simulada da Operadora A | Troca automática para a Operadora B; IP público mudou |
| Retorno | Volta automática para a Operadora A |
| Wi-Fi de uma sala | IP `172.16.10.250` do hEX; caminho `172.16.10.1 → 192.168.10.1 → internet` |
| Netwatch / firewall | `up` / 9 regras |

Representação dos testes em [operacao.md](operacao.md). Os valores deste documento são ilustrativos.

## Estado final

![Topologia final](img/topologia.svg)

A configuração lógica está concluída. A organização física (tirar os equipamentos do chão, cabos curtos, etiquetas, nobreak) ficou como próximo passo; ver [README](../README.md#próximos-passos).
