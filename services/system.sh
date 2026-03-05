setup_system() {

log "Atualizando sistema..."

apt update && apt -y upgrade

apt install -y \
htop curl git unzip \
software-properties-common

}

setup_swap() {

if swapon --show | grep -q swapfile; then
    warn "Swap já existe"
    return
fi

log "Criando swap $SWAP_SIZE"

fallocate -l "$SWAP_SIZE" /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab
swapon -a

}