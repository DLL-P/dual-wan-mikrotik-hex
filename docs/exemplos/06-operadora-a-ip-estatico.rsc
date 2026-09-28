# =====================================================================
#  Fallback: Operadora A com IP estatico (usar SO se a ether1 ficar em
#  "searching" no /ip dhcp-client print, ou seja, modem da Operadora A sem DHCP).
#  Ajuste a faixa se o modem nao usar 192.168.10.x.
# =====================================================================

/ip dhcp-client disable [find where comment=OPA]
/ip address add address=192.168.10.2/24 interface=ether1-OPA comment=OPA
/ip route set [find where comment="OPA-CHECK"] gateway=192.168.10.1
