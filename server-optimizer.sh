#!/usr/bin/env bash

set -e

echo "======================================"
echo "SERVER OPTIMIZER (SAFE MODE v2)"
echo "======================================"

if [ "$EUID" -ne 0 ]; then
    echo "Execute como root"
    exit 1
fi

DATE=$(date +%F-%H%M)

NGINX_CONF="/etc/nginx/nginx.conf"
PERF_CONF="/etc/nginx/conf.d/performance.conf"
SYSCTL_CONF="/etc/sysctl.d/99-server-optimization.conf"
LIMITS_CONF="/etc/security/limits.d/99-server.conf"

echo "Data: $DATE"

############################
# DETECTAR FIREWALL
############################

FIREWALL="none"

if command -v ufw >/dev/null 2>&1; then
    FIREWALL="ufw"
elif command -v firewall-cmd >/dev/null 2>&1; then
    FIREWALL="firewalld"
elif command -v iptables >/dev/null 2>&1; then
    FIREWALL="iptables"
fi

echo "Firewall detectado: $FIREWALL"

############################
# CONFIGURAR FIREWALL
############################

echo "Configurando firewall seguro..."

if [ "$FIREWALL" = "ufw" ]; then

    ufw --force reset

    ufw default deny incoming
    ufw default allow outgoing

    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp

    ufw --force enable

elif [ "$FIREWALL" = "firewalld" ]; then

    systemctl start firewalld
    systemctl enable firewalld

    firewall-cmd --permanent --remove-service=ssh || true
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp

    firewall-cmd --reload

elif [ "$FIREWALL" = "iptables" ]; then

    iptables-save > /root/iptables.backup.$DATE

    iptables -F
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT

    if command -v netfilter-persistent >/dev/null 2>&1; then
        netfilter-persistent save
    fi

else
    echo "Nenhum firewall encontrado — pulando etapa"
fi

############################
# DETECTAR NGINX
############################

if command -v nginx >/dev/null 2>&1; then
    NGINX=true
    cp $NGINX_CONF ${NGINX_CONF}.backup.$DATE
else
    NGINX=false
fi

############################
# OTIMIZAR NGINX
############################

if [ "$NGINX" = true ]; then

if grep -q worker_processes $NGINX_CONF; then
    sed -i 's/worker_processes.*/worker_processes auto;/' $NGINX_CONF
else
    sed -i '1i worker_processes auto;' $NGINX_CONF
fi

if grep -q worker_connections $NGINX_CONF; then
    sed -i 's/worker_connections.*/worker_connections 4096;/' $NGINX_CONF
else
    mkdir -p /etc/nginx/conf.d
    cat > $PERF_CONF <<EOF
events {
    worker_connections 4096;
}
EOF
fi

for OPT in "sendfile on;" "tcp_nopush on;" "tcp_nodelay on;" "gzip on;"; do
    if ! grep -q "$OPT" $NGINX_CONF; then
        sed -i "/http {/a \    $OPT" $NGINX_CONF
    fi
done

fi

############################
# SYSCTL
############################

cat > $SYSCTL_CONF <<EOF
fs.file-max = 2097152
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_syn_backlog = 8096
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
vm.swappiness = 10
EOF

sysctl --system

############################
# LIMITES
############################

cat > $LIMITS_CONF <<EOF
* soft nofile 65535
* hard nofile 65535
EOF

############################
# TESTE NGINX
############################

if [ "$NGINX" = true ]; then

if nginx -t; then
    systemctl reload nginx
else
    echo "Erro nginx — restaurando backup"
    cp ${NGINX_CONF}.backup.$DATE $NGINX_CONF
    systemctl reload nginx
    exit 1
fi

fi

echo "OTIMIZAÇÃO FINALIZADA"
