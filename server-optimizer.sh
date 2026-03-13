#!/usr/bin/env bash

set -e

echo "======================================"
echo "SERVER OPTIMIZER (SAFE MODE)"
echo "======================================"

# -----------------------------
# Verificar root
# -----------------------------

if [ "$EUID" -ne 0 ]; then
    echo "Execute como root"
    exit 1
fi

# -----------------------------
# Variáveis
# -----------------------------

NGINX_CONF="/etc/nginx/nginx.conf"
PERF_CONF="/etc/nginx/conf.d/performance.conf"
SYSCTL_CONF="/etc/sysctl.d/99-server-optimization.conf"
LIMITS_CONF="/etc/security/limits.d/99-server.conf"

DATE=$(date +%F-%H%M)

echo "Data: $DATE"

# -----------------------------
# Detectar nginx
# -----------------------------

if command -v nginx >/dev/null 2>&1; then
    NGINX_INSTALLED=true
    echo "Nginx detectado"
else
    NGINX_INSTALLED=false
    echo "Nginx não instalado"
fi

# -----------------------------
# BACKUP
# -----------------------------

echo "Criando backups..."

if [ "$NGINX_INSTALLED" = true ]; then
    cp $NGINX_CONF ${NGINX_CONF}.backup.$DATE
fi

# -----------------------------
# OTIMIZAÇÃO NGINX
# -----------------------------

if [ "$NGINX_INSTALLED" = true ]; then

echo "Otimizando nginx..."

# worker_processes

if grep -q "worker_processes" $NGINX_CONF; then
    sed -i 's/worker_processes.*/worker_processes auto;/' $NGINX_CONF
else
    sed -i '1i worker_processes auto;' $NGINX_CONF
fi

# worker_connections

if grep -q "worker_connections" $NGINX_CONF; then
    sed -i 's/worker_connections.*/worker_connections 4096;/' $NGINX_CONF
else

mkdir -p /etc/nginx/conf.d

cat > $PERF_CONF <<EOF
events {
    worker_connections 4096;
}
EOF

fi

# otimizações http

if ! grep -q "sendfile on;" $NGINX_CONF; then
sed -i '/http {/a \    sendfile on;' $NGINX_CONF
fi

if ! grep -q "tcp_nopush" $NGINX_CONF; then
sed -i '/http {/a \    tcp_nopush on;' $NGINX_CONF
fi

if ! grep -q "tcp_nodelay" $NGINX_CONF; then
sed -i '/http {/a \    tcp_nodelay on;' $NGINX_CONF
fi

if ! grep -q "gzip on;" $NGINX_CONF; then
sed -i '/http {/a \    gzip on;' $NGINX_CONF
fi

fi

# -----------------------------
# OTIMIZAÇÃO KERNEL
# -----------------------------

echo "Configurando sysctl..."

cat > $SYSCTL_CONF <<EOF

# File system
fs.file-max = 2097152

# TCP
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 16384
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

# TCP tuning
net.ipv4.tcp_max_syn_backlog = 8096
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_tw_reuse = 1

# Port range
net.ipv4.ip_local_port_range = 1024 65000

# Memory
vm.swappiness = 10

EOF

sysctl --system

# -----------------------------
# LIMITES DE ARQUIVOS
# -----------------------------

echo "Configurando limites..."

cat > $LIMITS_CONF <<EOF
* soft nofile 65535
* hard nofile 65535
EOF

# -----------------------------
# TESTE NGINX
# -----------------------------

if [ "$NGINX_INSTALLED" = true ]; then

echo "Testando nginx..."

if nginx -t; then

echo "Configuração nginx OK"

systemctl reload nginx

else

echo "ERRO no nginx"
echo "Restaurando backup"

cp ${NGINX_CONF}.backup.$DATE $NGINX_CONF

systemctl reload nginx

exit 1

fi

fi

echo "======================================"
echo "OTIMIZAÇÃO CONCLUÍDA"
echo "======================================"
