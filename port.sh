#!/bin/bash

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Port ranges to open
PORT_RANGES=("2003:2050" "3003:3050" "4003:4050" "5003:5050")

# Additional individual ports to open
INDIVIDUAL_PORTS=(80 8108 443 22 3389 3000)

# Fungsi untuk memeriksa apakah ufw terinstal
check_ufw_installed() {
  if ! command -v ufw &> /dev/null; then
    echo -e "${YELLOW}ufw tidak ditemukan. Menginstal ufw...${NC}"
    sudo apt update && sudo apt install ufw -y
    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}ufw berhasil diinstal.${NC}"
    else
      echo -e "${RED}Gagal menginstal ufw. Periksa koneksi internet Anda.${NC}"
      exit 1
    fi
  else
    echo -e "${GREEN}ufw sudah terinstal.${NC}"
  fi
}

# Fungsi untuk membuka rentang port
open_port_ranges() {
  for range in "${PORT_RANGES[@]}"; do
    echo -e "${YELLOW}Membuka rentang port $range${NC}"
    ufw allow "$range"/tcp
    ufw allow "$range"/udp
  done
}

# Fungsi untuk membuka port individual
open_individual_ports() {
  for port in "${INDIVIDUAL_PORTS[@]}"; do
    echo -e "${YELLOW}Membuka port $port${NC}"
    ufw allow "$port"/tcp
    ufw allow "$port"/udp
  done
}

# Memeriksa apakah ufw aktif
enable_ufw_if_not_active() {
  if ! ufw status | grep -q "Status: active"; then
    echo -e "${YELLOW}Mengaktifkan firewall UFW...${NC}"
    ufw enable
    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}Firewall UFW berhasil diaktifkan.${NC}"
    else
      echo -e "${RED}Gagal mengaktifkan UFW.${NC}"
      exit 1
    fi
  else
    echo -e "${GREEN}Firewall UFW sudah aktif.${NC}"
  fi
}

# Memeriksa dan menginstal ufw jika diperlukan
check_ufw_installed

# Mengaktifkan UFW jika belum aktif
enable_ufw_if_not_active

# Menerapkan aturan
open_port_ranges
open_individual_ports

# Reload UFW untuk menerapkan perubahan
echo -e "${YELLOW}Memuat ulang aturan UFW...${NC}"
ufw reload
echo -e "${GREEN}Semua port yang ditentukan telah dibuka.${NC}"
