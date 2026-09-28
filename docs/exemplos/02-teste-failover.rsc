# =====================================================================
#  Teste de failover: simula a queda da Operadora A e depois desfaz
#  Onde: Winbox > New Terminal. Rode UM bloco de cada vez.
#  Resultado esperado (validado em 26/09/2026):
#    - antes: OPA-DEFAULT com "A" e IP publico da Operadora A
#    - durante: OPA-DEFAULT com "X", OPB-DEFAULT com "A", IP publico da Operadora B
#    - depois: volta sozinho para a Operadora A em ~30 s
# =====================================================================

# 1) Situacao atual
/ip route print where comment~"DEFAULT"
/tool fetch url="https://ifconfig.me/ip" output=user

# 2) Simular a queda da Operadora A (bloqueia o host de checagem)
/ip firewall filter add chain=output dst-address=208.67.222.222 action=drop comment=TESTE-FAILOVER

# 3) Aguardar ~30 s e conferir a troca
/ip route print where comment~"DEFAULT"
/tool fetch url="https://ifconfig.me/ip" output=user

# 4) DESFAZER a simulacao (obrigatorio)
/ip firewall filter remove [find where comment=TESTE-FAILOVER]

# 5) Aguardar ~30 s: a OPA-DEFAULT volta a ficar ativa
/ip route print where comment~"DEFAULT"

# 6) Conferir que nao sobrou nada do teste (tem que vir vazio)
/ip firewall filter print where comment~"TESTE"
