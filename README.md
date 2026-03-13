# 🚀 Server Optimizer (Safe Mode)

Script profissional de otimização automática para servidores Linux pequenos.

Projetado especialmente para servidores:

* ✅ 2 CPU
* ✅ 2GB RAM
* ✅ Aplicações Web
* ✅ Containers / Docker
* ✅ Reverse Proxy
* ✅ APIs

O script aplica otimizações **seguras e verificadas** no sistema e no Nginx.

---

# 📦 O que o script otimiza

## 🌐 Nginx

* worker_processes automático
* worker_connections otimizado
* sendfile
* tcp_nopush
* tcp_nodelay
* gzip
* validação automática (`nginx -t`)
* reload seguro
* backup automático antes de qualquer alteração

---

## 🧠 Kernel Linux (sysctl)

* tuning de TCP stack
* aumento de backlog de conexões
* reutilização de sockets
* aumento de buffers de rede
* melhoria de throughput
* redução de timeout TCP
* otimização de portas efêmeras

---

## 📁 File Descriptors

Aumenta limite de arquivos abertos:

Antes: ~1024
Depois: ~65535

Essencial para servidores web com muitas conexões.

---

## 💾 Swap Optimization

Configura:

vm.swappiness = 10

Evita uso excessivo de swap e melhora latência.

---

# 🛠️ Como usar no servidor

## 1️⃣ Clonar o repositório

```bash
git clone https://github.com/SEU-USUARIO/server-optimizer.git
cd server-optimizer
```

---

## 2️⃣ Dar permissão de execução

```bash
chmod +x server-optimizer.sh
```

---

## 3️⃣ Executar como root

```bash
sudo ./server-optimizer.sh
```

---

# 🔐 Segurança do Script

O script foi projetado para **não quebrar o servidor**.

Ele:

* cria backup automático do nginx.conf
* só altera configurações se necessário
* testa a configuração antes de aplicar
* restaura automaticamente se houver erro
* não sobrescreve configurações críticas existentes
* cria arquivos de otimização separados quando possível

---

# 📊 Ganho esperado

Em servidores pequenos:

* antes: ~1500 conexões simultâneas
* depois: ~8000+ conexões simultâneas

(depende da aplicação e carga)

---

# 📂 Arquivos modificados pelo script

```
/etc/nginx/nginx.conf
/etc/nginx/conf.d/performance.conf
/etc/sysctl.d/99-server-optimization.conf
/etc/security/limits.d/99-server.conf
```

---

# 🔄 Aplicar novamente

Sempre que quiser reaplicar otimizações:

```bash
sudo ./server-optimizer.sh
```

---

# 🧯 Em caso de problema

Restaurar backup manual:

```bash
ls /etc/nginx/ng
```
