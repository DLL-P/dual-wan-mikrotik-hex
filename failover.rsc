# =====================================================================
#  MikroTik hEX (RB750Gr3) - Failover OPERADORA A (primario) / OPERADORA B
#  RouterOS 7.x (>= 7.4, recomendado ultima stable)
#
#  Portas:
#    ether1 = OPERADORA A      (LAN do roteador da Operadora A -> DHCP)
#    ether2 = OPERADORA B  (LAN do roteador da Operadora B -> DHCP)
#    ether3..ether5 = LAN (APs / switch)
#
#  LAN: 172.16.10.0/24  (gateway 172.16.10.1)
#
#  Uso (recomendado): subir este arquivo em Files, mover para a pasta flash
#  e resetar com:
#    /file set [find name="failover.rsc"] name="flash/failover.rsc"
#    /system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=flash/failover.rsc
#  O script roda sozinho no boot. Confira no Log: "failover.rsc aplicado com sucesso"
#
#  Validado em campo em 26/09/2026 no RB750Gr3 com RouterOS 7.23.7 (long-term).
#  Acessos extras e exemplos por site ficam em docs/exemplos/.
# =====================================================================

# Aguarda as interfaces subirem (necessario no run-after-reset)
:delay 15s

# ---------- Identidade / relogio ----------
/system identity set name=MK-EMPRESA
/system clock set time-zone-name=America/Sao_Paulo

# ---------- Interfaces ----------
/interface ethernet
set [find default-name=ether1] name=ether1-OPA
set [find default-name=ether2] name=ether2-OPB

/interface bridge
add name=bridge-LAN comment="LAN unificada"

/interface bridge port
add bridge=bridge-LAN interface=ether3
add bridge=bridge-LAN interface=ether4
add bridge=bridge-LAN interface=ether5

/interface list
add name=WAN
add name=LAN

/interface list member
add list=WAN interface=ether1-OPA
add list=WAN interface=ether2-OPB
add list=LAN interface=bridge-LAN

# ---------- LAN / DHCP / DNS ----------
/ip address
add address=172.16.10.1/24 interface=bridge-LAN comment=LAN

/ip pool
add name=pool-LAN ranges=172.16.10.100-172.16.10.250

/ip dhcp-server
add name=dhcp-LAN interface=bridge-LAN address-pool=pool-LAN lease-time=8h

/ip dhcp-server network
add address=172.16.10.0/24 gateway=172.16.10.1 dns-server=172.16.10.1

# DNS do MikroTik. NAO usar aqui os IPs de monitoramento (208.67.222.222 / 9.9.9.9)
/ip dns
set servers=1.1.1.1,8.8.8.8 allow-remote-requests=yes cache-size=4096KiB

# ---------- Rotas recursivas (failover por disponibilidade) ----------
# Host de checagem da OPERADORA A: 208.67.222.222 (OpenDNS) - sempre sai pela Operadora A
# Host de checagem da OPERADORA B: 9.9.9.9 (Quad9)        - sempre sai pela Operadora B
# Gateways abaixo sao placeholders; o script do DHCP corrige sozinho.
/ip route
add dst-address=208.67.222.222/32 gateway=192.168.10.1 scope=10 comment=OPA-CHECK
add dst-address=9.9.9.9/32 gateway=192.168.20.1 scope=10 comment=OPB-CHECK
add dst-address=0.0.0.0/0 gateway=208.67.222.222 target-scope=11 check-gateway=ping distance=1 comment=OPA-DEFAULT
add dst-address=0.0.0.0/0 gateway=9.9.9.9 target-scope=11 check-gateway=ping distance=2 comment=OPB-DEFAULT

# ---------- WANs (DHCP client sem rota default) ----------
# O script atualiza o gateway da rota de checagem sempre que o DHCP renova,
# entao nao importa qual IP o roteador da operadora usa.
/ip dhcp-client
add interface=ether1-OPA add-default-route=no use-peer-dns=no use-peer-ntp=no comment=OPA \
    script=":if (\$bound=1) do={ /ip route set [find where comment=\"OPA-CHECK\"] gateway=\$\"gateway-address\" }"
add interface=ether2-OPB add-default-route=no use-peer-dns=no use-peer-ntp=no comment=OPB \
    script=":if (\$bound=1) do={ /ip route set [find where comment=\"OPB-CHECK\"] gateway=\$\"gateway-address\" }"

# ---------- NAT ----------
/ip firewall nat
add chain=srcnat out-interface=ether1-OPA action=masquerade comment="NAT OPA"
add chain=srcnat out-interface=ether2-OPB action=masquerade comment="NAT OPB"

# ---------- Firewall basico ----------
/ip firewall filter
add chain=input action=accept connection-state=established,related,untracked comment="IN: estabelecidas"
add chain=input action=drop connection-state=invalid comment="IN: invalidas"
add chain=input action=accept protocol=icmp comment="IN: ping"
add chain=input action=accept in-interface-list=LAN comment="IN: gerencia/DNS/DHCP so pela LAN"
add chain=input action=drop comment="IN: dropa o resto (WAN)"
add chain=forward action=fasttrack-connection connection-state=established,related comment="FW: fasttrack"
add chain=forward action=accept connection-state=established,related,untracked comment="FW: estabelecidas"
add chain=forward action=drop connection-state=invalid comment="FW: invalidas"
add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface-list=WAN comment="FW: bloqueia novas vindas da WAN"

# ---------- Hardening ----------
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set winbox address=172.16.10.0/24
set ssh address=172.16.10.0/24

/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
/ip neighbor discovery-settings set discover-interface-list=LAN

# ---------- NTP ----------
/system ntp client set enabled=yes
/system ntp client servers
add address=a.st1.ntp.br
add address=b.st1.ntp.br

# ---------- Netwatch (degradacao: perda/latencia) ----------
# Se a Operadora A ficar com >30% de perda ou media >300ms, desativa a rota dela.
# Em qualquer troca, limpa as conexoes para os apps reconectarem pelo link novo.
# Fica por ultimo e protegido: se der erro de sintaxe, o resto ja foi aplicado.
:do {
/tool netwatch add name=OPA-MON type=icmp host=208.67.222.222 interval=15s packet-count=10 packet-interval=200ms thr-avg=300ms thr-max=2s thr-jitter=1s thr-stdev=500ms thr-loss-percent=30% down-script="/ip route disable [find where comment=\"OPA-DEFAULT\"]; :delay 1s; /ip firewall connection remove [find]; :log warning \"OPERADORA A FORA/DEGRADADA -> usando OPERADORA B\"" up-script="/ip route enable [find where comment=\"OPA-DEFAULT\"]; :delay 1s; /ip firewall connection remove [find]; :log warning \"OPERADORA A OK -> voltando para OPERADORA A\""
:log info "NETWATCH OK"
} on-error={ :log error "NETWATCH FALHOU - criar manualmente (ver guia)" }

:log info "failover.rsc aplicado com sucesso"
