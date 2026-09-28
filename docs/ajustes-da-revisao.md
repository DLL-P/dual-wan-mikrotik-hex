# Ajustes da revisão (26/09/2026)

Complementos ao guia. Onde houver conflito, vale o que está aqui.

## 1. Fase A feita NA EMPRESA (o hEX está lá)

Em casa, antes de sair:
- Baixar o Winbox (winbox64.exe).
- Plano B para atualização: baixar em mikrotik.com/download o RouterOS stable,
  arquitetura **MMIPS** (hEX RB750Gr3), "Main package" (`routeros-7.x-mmips.npk`).
  Se o hEX não tiver internet, arrastar o .npk em Files e reiniciar.

Ordem na empresa:
1. **B1 primeiro** (levantamento, foto do rack, faixas de IP, MACs das impressoras). Nada muda na rede.
2. **Fase A numa mesa, hEX sozinho:**
   - hEX na fonte, notebook na **ether2** (config de fábrica), Winbox pelo MAC.
     Senha, se pedir: etiqueta embaixo do aparelho.
   - Internet para atualizar: **ether1 numa porta LAN livre do roteador da Operadora A** (direto no roteador, não no switch).
   - A4, A5, A6, A7.
   - **Depois do reset, notebook vai para a ether4** (a ether2 vira Operadora B).
   - A8, A9.
3. **B2 em diante**, como no guia.

Cuidados:
- Com a **config de fábrica**, NUNCA ligar ether2 a ether5 no switch ou em roteador:
  o hEX distribui 192.168.88.x e derruba a empresa. Só a ether1 vai na rede.
- **Depois do reset**, só ligar a ether3 no switch no B2 (ela já distribui 172.16.10.x).
- Se Operadora A e Operadora B estiverem na mesma faixa (B1), mudar a LAN da Operadora B antes do B2.

## 2. Portas do hEX

| Porta  | Liga em |
|--------|---------|
| ether1 | Porta LAN do roteador **Operadora A** (DHCP, **não é PPPoE** — "PoE in" na etiqueta é alimentação) |
| ether2 | Porta LAN do roteador **Operadora B** (DHCP) |
| ether3 | Switch de distribuição — **um cabo só** (3 e 4 no switch = laço) |
| ether4/5 | Notebook para teste |

- Links em **DHCP client** (o script já faz). Não configurar PPPoE, não mexer no modo dos roteadores das operadoras.
- Só usar estático se a ether1 ficar em "searching" no B3 (roteador da Operadora A sem DHCP):
  ```
  /ip dhcp-client disable [find where comment=OPA]
  /ip address add address=192.168.10.2/24 interface=ether1-OPA comment=OPA
  /ip route set [find where comment="OPA-CHECK"] gateway=192.168.10.1
  ```

## 3. B4 — ordem corrigida (configuração manual do roteador da sala)

Trocar o IP de LAN primeiro corta o acesso. Fazer assim:
1. **Wi-Fi**: SSID e senha únicos, WPA2-PSK (AES) em todos, mesmo nome em 2,4 e 5 GHz.
   Canais 2,4 GHz: 1/6/11 alternando; 5 GHz: variar (36/44/149).
2. **DHCP**: desativar (o notebook mantém o IP atual, não perde a página).
3. **LAN**: IP 172.16.10.1N por último. Passar o cabo do switch da WAN para uma LAN.

Dicas:
- **Reaproveitar o SSID e a senha mais usados hoje**: todo mundo (e impressoras Wi-Fi) reconecta sozinho.
- Em modo "Access Point" de alguns roteador da Operadora B/Intelbras o AP pega IP por DHCP: se 172.16.10.1N
  não responder, procurar em IP > DHCP Server > Leases e reservar.
- Um único cabo do switch por sala (sem laço).
- Conferir depois de alguns dias se a Operadora A não religou o Wi-Fi remotamente.

## 4. Impressoras (B5)

- Impressora em **DHCP + reserva no MikroTik pelo MAC** (não IP fixo no painel).
- Cabo **ou** Wi-Fi, não os dois (MACs diferentes = dois IPs). Preferir cabo; desligar Wi-Fi e Wi-Fi Direct.
- No B1: imprimir a folha de configuração de rede de cada uma e anotar o MAC em uso.
- Reservas (fora do pool .100–.250):
  ```
  /ip dhcp-server lease add server=dhcp-LAN mac-address=AA:BB:CC:DD:EE:01 address=172.16.10.50 comment="Impressora sala 1"
  /ip dhcp-server lease add server=dhcp-LAN mac-address=AA:BB:CC:DD:EE:02 address=172.16.10.51 comment="Impressora sala 2"
  ```
  Depois desligar/ligar cada impressora e conferir com `/ip dhcp-server lease print`.
- Impressora só Wi-Fi: reconectar no SSID novo pelo painel ou WPS (a menos que o SSID antigo seja reaproveitado).
- Nos PCs: trocar a porta para `IP_172.16.10.50` (B5). Porta WSD costuma seguir sozinha.
- Impressora USB compartilhada por um PC: a reserva é do **PC**.
- Com a rede unificada, qualquer PC de qualquer sala imprime nas duas.

## 5. Levar
2–3 cabos curtos extras, Winbox no notebook, checklist impresso.

## 6. Lições da implantação em campo (26/09/2026)

- **`hw-offload=yes` removido da regra de fasttrack**: no hEX RB750Gr3 com RouterOS 7.23.7
  o parâmetro não existe e o script parava ali ("bad parameter hw-offload").
- **hEX vindo com RouterOS 6**: `channel=stable` não sobe do 6 para o 7. Usar
  `/system package update set channel=upgrade`, depois `check-for-updates` e `install`.
  Com o RouterOS 6 conectar pelo **Winbox 3** (o Winbox 4 travava no login).
- **Script no RouterOS 7**: enviar para `flash/failover.rsc` e resetar com
  `run-after-reset=flash/failover.rsc` (fora da `flash` o arquivo pode sumir no reboot).
- **Reset pelo botão segurado demais** cai no modo CAP (bridge `bridgeLocal`, sem DHCP server).
  Não atrapalha: o A7 apaga tudo.
- **Notebook sem porta de rede**: acesso pelo lado LAN com um roteador Wi-Fi ligado numa
  porta da bridge (ether3) e IP fixo no Wi-Fi do notebook:
  `netsh interface ip set address name=Wi-Fi static 172.16.10.9 255.255.255.0 172.16.10.1`
  e `netsh interface ip set dns name=Wi-Fi static 172.16.10.1`. Desfazer com `... dhcp`.
- **Faixas reais**: Operadora A = 192.168.10.x, Operadora B (roteador) = 192.168.20.x.
- **Gerência pelo Wi-Fi do roteador da Operadora B (salas fechadas)**: o hEX tem o IP fixo extra
  `192.168.20.250/24` na ether2-OPB e aceita Winbox/SSH vindos de 192.168.20.0/24
  (regra `GERENCIA-VIA-OPB` antes de "IN: dropa o resto (WAN)"). Conectar no Wi-Fi
  do roteador da Operadora B (Wi-Fi da Operadora B) e abrir o Winbox em `192.168.20.250`. Manter senha forte no Wi-Fi do roteador da Operadora B.
- **Failover testado em campo**: Operadora A → Operadora B → volta à Operadora A (IP público mudou nos dois sentidos).
