# =====================================================================
#  Acesso de manutencao pelo Wi-Fi do roteador da Operadora B (Operadora B)
#  Uso: quando nao ha como chegar na rede das salas (salas fechadas,
#  notebook so com Wi-Fi). Aplicado em campo em 26/09/2026.
#
#  Depois de aplicado: notebook no Wi-Fi do roteador da Operadora B -> Winbox em 192.168.20.250
#  Seguranca: aceita gerencia SOMENTE da rede 192.168.20.0/24 (LAN do roteador da Operadora B).
#  Mantenha senha forte no Wi-Fi do roteador da Operadora B.
# =====================================================================

/ip address add address=192.168.20.250/24 interface=ether2-OPB comment=GERENCIA-VIA-OPB
/ip firewall filter add chain=input action=accept in-interface=ether2-OPB src-address=192.168.20.0/24 comment=GERENCIA-VIA-OPB place-before=[find where comment="IN: dropa o resto (WAN)"]
/ip service set winbox address=172.16.10.0/24,192.168.20.0/24
/ip service set ssh address=172.16.10.0/24,192.168.20.0/24

# ---------- Para remover este acesso ----------
# /ip firewall filter remove [find where comment=GERENCIA-VIA-OPB]
# /ip address remove [find where comment=GERENCIA-VIA-OPB]
# /ip service set winbox address=172.16.10.0/24
# /ip service set ssh address=172.16.10.0/24
