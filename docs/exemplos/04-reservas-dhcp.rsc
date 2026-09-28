# =====================================================================
#  IP fixo por reserva no DHCP (impressoras, ponto, DVR, APs das salas)
#  Faixas reservadas (fora do pool automatico .100-.250):
#    172.16.10.11 - .49  -> equipamentos Wi-Fi das salas (sala N = .1N)
#    172.16.10.50 - .79  -> impressoras e equipamentos fixos
#  Troque MAC, IP e comentario pelos valores reais.
# =====================================================================

# Descobrir o MAC: ligue o aparelho e procure na lista
/ip dhcp-server lease print

# Opcao 1: transformar um aparelho ja conectado em fixo
/ip dhcp-server lease make-static [find where mac-address="AA:BB:CC:DD:EE:01"]
/ip dhcp-server lease set [find where mac-address="AA:BB:CC:DD:EE:01"] address=172.16.10.50 comment="Impressora sala 1"

# Opcao 2: cadastrar direto pelo MAC
/ip dhcp-server lease add server=dhcp-LAN mac-address=AA:BB:CC:DD:EE:02 address=172.16.10.51 comment="Impressora sala 2"
/ip dhcp-server lease add server=dhcp-LAN mac-address=AA:BB:CC:DD:EE:11 address=172.16.10.11 comment="AP sala 1"

# Depois: desligar e ligar o aparelho e conferir
/ip dhcp-server lease print where comment~"Impressora|AP"
