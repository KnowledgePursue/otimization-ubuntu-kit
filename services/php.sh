setup_php() {

log "Instalando PHP $PHP_VERSION"

add-apt-repository -y ppa:ondrej/php

apt update

apt install -y \
php${PHP_VERSION}-fpm \
php${PHP_VERSION}-cli \
php${PHP_VERSION}-mysql \
php${PHP_VERSION}-xml \
php${PHP_VERSION}-curl \
php${PHP_VERSION}-zip \
php${PHP_VERSION}-gd \
php${PHP_VERSION}-mbstring \
php${PHP_VERSION}-intl \
php${PHP_VERSION}-bcmath \
php${PHP_VERSION}-imagick

}

tune_php() {

CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

log "Otimizando PHP-FPM"

sed -i 's/^;*pm = .*/pm = dynamic/' $CONF
sed -i 's/^;*pm.max_children = .*/pm.max_children = 20/' $CONF
sed -i 's/^;*pm.start_servers = .*/pm.start_servers = 4/' $CONF
sed -i 's/^;*pm.min_spare_servers = .*/pm.min_spare_servers = 4/' $CONF
sed -i 's/^;*pm.max_spare_servers = .*/pm.max_spare_servers = 8/' $CONF
sed -i 's/^;*pm.max_requests = .*/pm.max_requests = 400/' $CONF

systemctl restart php${PHP_VERSION}-fpm

}