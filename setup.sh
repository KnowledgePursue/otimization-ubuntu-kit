#!/bin/bash

set -e

source config.env
source lib.sh

source services/system.sh
source services/security.sh
source services/php.sh
source services/nginx.sh
source services/database.sh

require_root
check_ubuntu

log "=============================="
log "INICIANDO SETUP DO SERVIDOR"
log "=============================="

if confirm "Atualizar sistema?"; then
setup_system
fi

if confirm "Criar swap?"; then
setup_swap
fi

if confirm "Configurar firewall?"; then
setup_firewall
fi

if confirm "Instalar fail2ban?"; then
setup_fail2ban
fi

if confirm "Instalar PHP?"; then
setup_php
tune_php
fi

if confirm "Instalar Nginx?"; then
setup_nginx
tune_nginx
fi

if confirm "Instalar banco de dados?"; then
setup_database
setup_redis
fi

log "SETUP FINALIZADO"