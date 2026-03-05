setup_database() {

if [ "$INSTALL_MARIADB" = "true" ]; then

log "Instalando MariaDB"

apt install -y mariadb-server

systemctl enable mariadb
systemctl start mariadb

fi

}

setup_redis() {

if [ "$INSTALL_REDIS" = "true" ]; then

log "Instalando Redis"

apt install -y redis-server

systemctl enable redis-server
systemctl start redis-server

fi

}