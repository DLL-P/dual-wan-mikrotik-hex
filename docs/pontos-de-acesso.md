# Pontos de acesso das salas

Como transformar o roteador de cada contêiner em **ponto de acesso (AP)** da rede interna. É o que faz todas as salas virarem uma rede só, com o mesmo Wi-Fi, failover e acesso às impressoras de qualquer sala.

> Referência: o Wi-Fi da primeira sala convertida já opera assim. Quem conecta nela recebe `172.16.10.x` direto do hEX.

## Roteador x ponto de acesso

| | Modo roteador (antes) | Modo AP (objetivo) |
|---|---|---|
| Cabo do switch entra em | Porta **WAN** | Porta **LAN** |
| Quem entrega IP | O próprio roteador (rede separada) | O hEX (`172.16.10.x`) |
| Andar entre salas | Troca de IP | Mantém o IP |
| Ver impressoras de outra sala | Não | Sim |

## Passo a passo (em cada sala)

A ordem importa: trocar o IP de LAN primeiro corta o acesso ao painel.

1. **Entrar no painel.** Conecte no Wi-Fi da sala (ou cabo), rode `ipconfig` e abra o **Gateway** no navegador. Senha de admin: etiqueta do aparelho.
2. **Wi-Fi.** Mesmo **nome (SSID) e senha em todas as salas**, WPA2-PSK (AES), mesmo nome em 2,4 e 5 GHz.
   - Reaproveite o nome e a senha mais usados hoje: os aparelhos reconectam sozinhos.
   - Canais 2,4 GHz alternando **1 / 6 / 11** entre salas vizinhas; 5 GHz variando (36 / 44 / 149).
3. **DHCP: desativar.** O notebook mantém o IP atual e não perde a página.
4. **IP de LAN por último:** `172.16.10.1N` (sala 1 = `.11`, sala 2 = `.12`...), máscara `255.255.255.0`, gateway e DNS `172.16.10.1`.
5. **Cabo:** passe o cabo que vem do switch da porta **WAN** para uma porta **LAN**.
6. **Conferir** num notebook dessa sala: IPv4 `172.16.10.1xx` e gateway `172.16.10.1`.

Depois, reserve o IP do AP no hEX com [`04-reservas-dhcp.rsc`](exemplos/04-reservas-dhcp.rsc) e ative o alerta de [DHCP intruso](exemplos/05-alerta-dhcp-intruso.rsc).

## Observações

- Alguns TP-Link/Intelbras/Mercusys em "Modo Access Point" pegam IP por DHCP. Se `172.16.10.1N` não responder, procure o aparelho em `/ip dhcp-server lease print` e reserve.
- **Um cabo por sala**, sem laço.
- Se os APs das salas forem de uma linha com controladora (gerência centralizada), padronize o Wi-Fi por ela em vez de sala por sala.
- Conferir depois de alguns dias se nenhum roteador voltou a distribuir IP (reset, atualização remota).

## Sala do rack

Os Wi-Fi do modem da Operadora A e do roteador da Operadora B foram **mantidos** por decisão operacional (rotina dos usuários). Para ter a rede interna também ali, ligue um AP configurado como acima na **`ether4`** do hEX ou numa porta livre do switch.
