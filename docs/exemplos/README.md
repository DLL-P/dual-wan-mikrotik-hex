# Exemplos de scripts

Scripts prontos para o **New Terminal do Winbox**. Leia o cabeçalho de cada arquivo antes de colar: alguns só consultam, outros alteram a configuração.

| Arquivo | Altera? | Para que serve |
|---|---|---|
| [`01-checagem-rapida.rsc`](01-checagem-rapida.rsc) | Não | Estado das operadoras, rota ativa, netwatch, IP público, aparelhos e log |
| [`02-teste-failover.rsc`](02-teste-failover.rsc) | Temporário | Simula a queda da Operadora A e desfaz. Rode um bloco de cada vez |
| [`03-gerencia-via-operadora-b.rsc`](03-gerencia-via-operadora-b.rsc) | Sim | Acesso de manutenção pelo Wi-Fi do roteador da Operadora B (`192.168.20.250`). **Já aplicado** |
| [`04-reservas-dhcp.rsc`](04-reservas-dhcp.rsc) | Sim | IP fixo por MAC para impressoras e APs das salas |
| [`05-alerta-dhcp-intruso.rsc`](05-alerta-dhcp-intruso.rsc) | Sim | Aviso no Log se algum roteador de sala voltar a distribuir IP |
| [`06-operadora-a-ip-estatico.rsc`](06-operadora-a-ip-estatico.rsc) | Sim | Fallback se o modem da Operadora A parar de entregar DHCP |
| [`07-backup.rsc`](07-backup.rsc) | Não | Gera `.rsc` e `.backup` para baixar |

Todos usam os nomes definidos em [`failover.rsc`](../../failover.rsc): interfaces `ether1-OPA`, `ether2-OPB`, `bridge-LAN`, servidor `dhcp-LAN` e comentários das rotas (`OPA-DEFAULT`, `OPB-DEFAULT`, `OPA-CHECK`, `OPB-CHECK`).
