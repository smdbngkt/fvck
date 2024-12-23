#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Harap jalankan script ini sebagai root."
    exit 1
fi

# Perbarui paket dan instal Dante Server
apt update && apt upgrade -y
apt install -y dante-server

# Konfigurasi Dante Server
cat > /etc/danted.conf <<EOL
logoutput: syslog

internal: 0.0.0.0 port = 1080
external: eth0

method: username none
user.privileged: root
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    log: error
}
EOL

# Restart dan aktifkan Dante Server
systemctl restart danted
systemctl enable danted

# Tampilkan informasi SOCKS5
echo "\nSOCKS5 server berhasil diinstal dan dikonfigurasi!"
echo "IP: $(curl -s ifconfig.me)"
echo "Port: 1080"
echo "\nAnda dapat mengedit konfigurasi di /etc/danted.conf sesuai kebutuhan."
