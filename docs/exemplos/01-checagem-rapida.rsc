# =====================================================================
#  Checagem rapida do estado da rede (somente leitura, nao altera nada)
#  Onde: Winbox > New Terminal (acesso em 172.16.10.1 ou 192.168.20.250)
# =====================================================================

# As duas operadoras precisam estar em "bound"
/ip dhcp-client print

# Qual operadora esta em uso: a rota com a letra A esta ativa
/ip route print where comment~"DEFAULT|CHECK"

# Monitor de qualidade da Operadora A: precisa estar "up"
/tool netwatch print

# IP publico atual (muda quando a internet troca de operadora)
/tool fetch url="https://ifconfig.me/ip" output=user

# Aparelhos que receberam IP do hEX (salas, impressoras, celulares)
/ip dhcp-server lease print

# Ultimos eventos (quedas, trocas de operadora, logins)
/log print where topics~"warning|error|critical"
