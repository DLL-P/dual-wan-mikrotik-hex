# Changelog

## 2026-09-28 · Organização do repositório

- Estrutura: `failover.rsc` na raiz; documentação, exemplos, guia e imagens em `docs/`.
- README reescrito como caso prático: cenário, solução, diagrama das portas, resultados e como usar os arquivos.
- Topologia em SVG e em Mermaid, diagrama do cenário anterior e diagrama do teste de failover.
- Scripts de exemplo: checagem rápida, teste de failover, gerência via roteador da Operadora B, reservas DHCP, alerta de DHCP intruso, Operadora A estático, backup.
- Cola de comandos convertida para Markdown, com as correções de campo (upgrade 6→7, pasta `flash/`).
- Guia em PDF regenerado a partir do HTML corrigido, já com valores ilustrativos. Checklist de campo removido (tinha o endereçamento real).
- Removidas cópias duplicadas (pasta `Implantacao-MikroTik-hEX/` e `.zip`), os rascunhos em PDF e o link privado do guia online.
- Privacidade: removidas fotos e prints do cliente; todos os IPs, nomes de rede, hosts e marcas de equipamentos do local substituídos por valores ilustrativos.
- `.gitignore` para backups, exports e relatórios com credenciais.

## 2026-09-26 · Implantação em campo

- `failover.rsc`: removido `hw-offload=yes` da regra de fasttrack (parâmetro inexistente no RB750Gr3 com RouterOS 7.23.7; interrompia o script).
- Corrigido o nome do pacote para **MMIPS** (`routeros-7.x-mmips.npk`).
- Registradas as lições de campo: upgrade 6→7 pelo canal `upgrade`, uso da pasta `flash/`, acesso sem porta de rede, gerência pelo Wi-Fi do roteador da Operadora B.
- Failover validado em produção (Operadora A → Operadora B → Operadora A) e teste de ponta a ponta pelo Wi-Fi de uma sala.

## 2026-09-25 · Versão inicial

- Guia de implantação (HTML/PDF), checklist de campo, cola de comandos e `failover.rsc`.
