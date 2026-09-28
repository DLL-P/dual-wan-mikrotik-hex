# =====================================================================
#  Backup apos qualquer alteracao
#  Baixar depois em Winbox > Files > selecionar > Download.
#  NAO subir .backup para o GitHub (contem usuarios e senhas).
# =====================================================================

/export file=config-final
/system backup save name=config-final

# Restaurar (apenas no mesmo hEX):
# /system backup load name=config-final.backup
