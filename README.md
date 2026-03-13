# 🚀 Server Optimizer (Safe Mode v2)

Script profissional para bootstrap e hardening de servidores Linux.

Projetado para servidores pequenos:

* 2 CPU
* 2GB RAM
* aplicações web
* nginx / docker / APIs

---

# 🔥 Firewall Hardening

O script detecta automaticamente qual firewall está ativo:

* UFW
* Firewalld
* IPTables

E aplica política segura:

* libera apenas:

  * 22 (SSH)
  * 80 (HTTP)
  * 443 (HTTPS)
* bloqueia todo o resto
* mantém conexões estabelecidas
* cria backup automático das regras

---

# 🌐 Nginx Optimization

* worker_processes auto
* worker_connections 4096
* sendfile
* tcp_nopush
* tcp_nodelay
* gzip
* validação automática

---

# 🧠 Kernel Optimization

* TCP backlog tuning
* port range tuning
* reuse de sockets
* redução de timeout TCP
* buffers de rede
* swappiness tuning

---

# 📁 File Descriptors

Limite aumentado para:

65535

---

# 🛠️ Como usar

```bash
git clone https://github.com/KnowledgePursue/otimization-ubuntu-kit.git
cd otimization-ubuntu-kit
chmod +x server-optimizer.sh
sudo ./server-optimizer.sh
```

---

# 📂 Arquivos modificados

* /etc/nginx/nginx.conf
* /etc/nginx/conf.d/performance.conf
* /etc/sysctl.d/99-server-optimization.conf
* /etc/security/limits.d/99-server.conf
* regras de firewall

---

# 🧯 Backup

iptables:

```
/root/iptables.backup.DATA
```

nginx:

```
/etc/nginx/nginx.conf.backup.DATA
```

---

# ⚠️ IMPORTANTE

Após rodar o script:

* confirme que o SSH continua acessível
* valide sites na porta 80/443
* valide containers expostos

---

# 👨‍💻 Uso

Ideal para:

* bootstrap de VPS
* preparação para produção
* otimização rápida
* hardening inicial
