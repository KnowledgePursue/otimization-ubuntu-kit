setup_firewall() {

if [ "$ENABLE_UFW" != "true" ]; then
    warn "UFW desabilitado"
    return
fi

log "Configurando firewall"

apt install -y ufw

ufw default deny incoming
ufw default allow outgoing

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

ufw --force enable

}

setup_fail2ban() {

if [ "$ENABLE_FAIL2BAN" != "true" ]; then
    warn "Fail2ban desabilitado"
    return
fi

log "Instalando fail2ban"

apt install -y fail2ban

systemctl enable fail2ban
systemctl start fail2ban

}