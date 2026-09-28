# =====================================================================
#  Alerta de DHCP intruso: avisa no Log se algum roteador de sala
#  voltar a distribuir IP na rede interna (ex.: roteador resetado).
# =====================================================================

/ip dhcp-server alert add interface=bridge-LAN alert-timeout=1h on-alert=":log warning \"DHCP INTRUSO na rede - verificar roteadores das salas\""

# Ver alertas
/log print where message~"DHCP INTRUSO"
