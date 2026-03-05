setup_nginx() {

log "Instalando Nginx"

apt install -y nginx

systemctl enable nginx
systemctl start nginx

}

tune_nginx() {

log "Otimizando nginx"

cat > /etc/nginx/conf.d/performance.conf <<EOF
# Performance tuning

worker_connections 4096;

sendfile on;
tcp_nopush on;
tcp_nodelay on;

keepalive_timeout 65;

gzip on;
gzip_comp_level 5;
gzip_min_length 256;

open_file_cache max=10000 inactive=60s;
open_file_cache_valid 120s;
open_file_cache_min_uses 2;
open_file_cache_errors on;

EOF

nginx -t && systemctl reload nginx

}