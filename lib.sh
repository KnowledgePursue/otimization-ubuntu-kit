#!/bin/bash

log() {
    echo "[INFO] $1"
    echo "[INFO] $1" >> "$LOG_FILE"
}

warn() {
    echo "[WARN] $1"
    echo "[WARN] $1" >> "$LOG_FILE"
}

error() {
    echo "[ERROR] $1"
    echo "[ERROR] $1" >> "$LOG_FILE"
}

confirm() {
    read -p "$1 (y/n): " choice
    case "$choice" in
        y|Y ) return 0 ;;
        * ) return 1 ;;
    esac
}

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        error "Execute como root"
        exit 1
    fi
}

check_ubuntu() {
    if ! grep -q "Ubuntu 24" /etc/os-release; then
        warn "Script projetado para Ubuntu 24"
    fi
}