# Cola de comandos

Todos os comandos da implantação, por passo do [guia](guia/guia-implantacao.html). Cada bloco diz **onde** rodar.

> Blocos `RouterOS` vão no **New Terminal do Winbox**. Blocos `CMD`/`PowerShell` rodam no **notebook**. Troque os valores de exemplo (nomes, IPs, senhas) antes.

| Referência | Valor |
|---|---|
| Rede interna | `172.16.10.0/24` · gateway e DNS `172.16.10.1` |
| Portas | `ether1` Operadora A · `ether2` Operadora B · `ether3` switch |

## A2 · Salvar o script no notebook

O script completo está em [`failover.rsc`](../failover.rsc). Copie o conteúdo e grave com o PowerShell abaixo (evita caracteres invisíveis do Bloco de Notas).

**PowerShell · grava o que foi copiado**

```powershell
[IO.File]::WriteAllText("$env:USERPROFILE\Desktop\failover.rsc", (Get-Clipboard -Raw))
```

**PowerShell · conferir o arquivo**

```powershell
Get-Content "$env:USERPROFILE\Desktop\failover.rsc" -TotalCount 3
(Get-Content "$env:USERPROFILE\Desktop\failover.rsc").Count
```

## A4 · Atualizar o RouterOS

> **hEX vindo com RouterOS 6?** O canal `stable` não sobe do 6 para o 7. Use `set channel=upgrade`, instale, e depois repita com `channel=stable`. No RouterOS 6, conecte com o **Winbox 3**.

**RouterOS · Terminal**

```routeros
/system package update set channel=stable
/system package update check-for-updates
/system package update install
```

## A5 · Atualizar o firmware da placa

**RouterOS · Terminal**

```routeros
/system routerboard upgrade
/system reboot
```

## A7 · Resetar e aplicar o script no boot

> No hEX com RouterOS 7, arquivos fora da pasta `flash/` podem sumir no reboot. Mova o script para `flash/` antes do reset.

**RouterOS · Terminal · mesmo efeito**

```routeros
/file set [find name="failover.rsc"] name="flash/failover.rsc"
/system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=flash/failover.rsc
```

## A8 · Conferir se o script foi aplicado

**CMD · renovar IP e conferir**

```bat
ipconfig /release
ipconfig /renew
ipconfig | findstr /i "IPv4 Gateway"
```

**CMD · teste de navegação**

```bat
ping 8.8.8.8
nslookup google.com 172.16.10.1
curl.exe -s https://ifconfig.me/ip
```

## A9 · Criar seu usuário e desativar o admin

**RouterOS · Terminal · troque a senha antes de rodar**

```routeros
/user add name=suporte group=full password="TROQUE-ESTA-SENHA"
```

**RouterOS · Terminal · já logado como suporte**

```routeros
/user disable admin
```

## B1 · Levantamento rápido

**CMD · rode uma vez em cada operadora**

```bat
ipconfig | findstr /i "IPv4 Gateway"
```

**CMD · num PC dentro da sala**

```bat
ipconfig | findstr /i "IPv4 Gateway"
tracert -d -h 3 8.8.8.8
```

**CMD · varredura rápida (~30 s) + lista de MACs**

```bat
for /L %i in (1,1,254) do @ping -n 1 -w 100 192.168.10.%i | find "TTL"
arp -a
```

## B3 · Conferir os dois links

**RouterOS · Terminal · conferência rápida**

```routeros
/ip dhcp-client print
/ip route print where comment~"DEFAULT|CHECK"
/tool netwatch print
/tool fetch url="https://ifconfig.me/ip" output=user
```

## B4 · Converter o roteador de cada contêiner em AP

**CMD · troque 11 pelo IP da sala**

```bat
ipconfig /release
ipconfig /renew
ipconfig /all | findstr /i "IPv4 Gateway DHCP"
ping 172.16.10.11
curl.exe -s https://ifconfig.me/ip
```

**RouterOS · Terminal · alerta de DHCP intruso no Log**

```routeros
/ip dhcp-server alert add interface=bridge-LAN alert-timeout=1h on-alert=":log warning \"DHCP INTRUSO na rede - verificar roteadores das salas\""
```

## B5 · Impressoras e aparelhos fixos

**RouterOS · Terminal · troque o nome e o IP**

```routeros
/ip dhcp-server lease print
/ip dhcp-server lease make-static [find where host-name="IMPRESSORA-01"]
/ip dhcp-server lease set [find where host-name="IMPRESSORA-01"] address=172.16.10.50 comment="Impressora recepcao"
```

**PowerShell (Administrador) · ver o nome exato da impressora**

```powershell
Get-Printer | Select-Object Name, PortName
```

**PowerShell (Administrador) · troque o nome e o IP**

```powershell
Add-PrinterPort -Name "IP_172.16.10.50" -PrinterHostAddress "172.16.10.50"
Set-Printer -Name "Impressora Exemplo" -PortName "IP_172.16.10.50"
```

**CMD · remapear unidade de rede**

```bat
net use
net use Z: /delete
net use Z: \\172.16.10.51\Arquivos /persistent:yes
```

## B6 · Liberar a comunicação entre os PCs

**PowerShell (Administrador) · rede privada + descoberta + compartilhamento**

```powershell
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-32752"
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28502"
Get-NetConnectionProfile | Select-Object InterfaceAlias, NetworkCategory
```

**PowerShell · troque pelo nome ou IP do outro PC**

```powershell
ping PC-EXEMPLO
Test-NetConnection 172.16.10.192 -Port 445
```

## B7 · Testar o failover

**CMD · janela 1 · deixe rodando**

```bat
ping -t 8.8.8.8
```

**RouterOS · Terminal · simular queda**

```routeros
/ip firewall filter add chain=output dst-address=208.67.222.222 action=drop comment=TESTE-FAILOVER
```

**CMD · janela 2 · o IP público mudou?**

```bat
curl.exe -s https://ifconfig.me/ip
```

**RouterOS · Terminal · desfazer a simulação**

```routeros
/ip firewall filter remove [find where comment=TESTE-FAILOVER]
```

## B8 · Backup e entrega

**RouterOS · Terminal · gerar os backups**

```routeros
/export file=config-ok
/system backup save name=config-ok
```

**PowerShell · copiar backups via SSH**

```powershell
scp suporte@172.16.10.1:/config-ok.rsc "$env:USERPROFILE\Desktop\"
scp suporte@172.16.10.1:/config-ok.backup "$env:USERPROFILE\Desktop\"
```

## ? · Problemas comuns

**RouterOS · Terminal · Netwatch simples**

```routeros
/tool netwatch add name=OPA-MON host=208.67.222.222 interval=10s timeout=1s down-script="/ip route disable [find where comment=\"OPA-DEFAULT\"]; /ip firewall connection remove [find]; :log warning \"OPERADORA A FORA -> usando OPERADORA B\"" up-script="/ip route enable [find where comment=\"OPA-DEFAULT\"]; /ip firewall connection remove [find]; :log warning \"OPERADORA A OK -> voltando para OPERADORA A\""
```

**CMD · diagnóstico no PC**

```bat
ipconfig /all | findstr /i "IPv4 Gateway DNS"
ping 172.16.10.1
nslookup google.com 172.16.10.1
tracert -d -h 4 8.8.8.8
```

**PowerShell (Administrador) · liberar o Winbox no firewall · ajuste o caminho do .exe**

```powershell
New-NetFirewallRule -DisplayName "Winbox" -Direction Inbound -Action Allow -Program "$env:USERPROFILE\Downloads\winbox64.exe"
```

**CMD (Administrador) · IP fixo e depois volta para DHCP · troque "Ethernet" pelo nome da sua placa**

```bat
netsh interface ip set address name="Ethernet" static 172.16.10.9 255.255.255.0 172.16.10.1
netsh interface ip set address name="Ethernet" dhcp
```
