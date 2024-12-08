#!/bin/bash

# Mengambil alamat IP publik dari ipify
IP=$(curl -s https://api.ipify.org)

# Mengambil skrip restart.py dari URL dan menyimpannya ke dalam file
curl -o restart.py https://raw.githubusercontent.com/smdbngkt/fvck/refs/heads/main/restart.py

# Menambahkan entri ke crontab untuk menjalankan script setiap 15 menit
(crontab -l 2>/dev/null; echo "*/15 * * * * python3 $(pwd)/restart.py $IP $(pwd)") | crontab -
