#!/bin/bash

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# File log
LOG_FILE="/var/log/ufw-config.log"

# Port ranges to open
PORT_RANGES=("2003:2050" "3003:3050" "4003:4050" "5003:5050")

# Additional individual ports to open
INDIVIDUAL_PORTS=(
    80    # HTTP
    8108  # Custom
    443   # HTTPS
    22    # SSH
    3389  # RDP
    3000  # Development
    21    # FTP
    25    # SMTP
    53    # DNS
    110   # POP3
    143   # IMAP
    587   # SMTP (submission)
    993   # IMAPS
    995   # POP3S
    5432  # PostgreSQL
    6379  # Redis
    8080  # Alternate HTTP
    8443  # Alternate HTTPS
    27017 # MongoDB
)

# Fungsi logging
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
    echo -e "$1"
}

# Fungsi validasi port
validate_port() {
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt 65535 ]; then
        log_message "${RED}Error: Port $1 tidak valid. Port harus berupa angka antara 1-65535${NC}"
        return 1
    fi
    return 0
}

# Fungsi untuk memeriksa apakah ufw terinstal
check_ufw_installed() {
    if ! command -v ufw &> /dev/null; then
        log_message "${YELLOW}ufw tidak ditemukan. Menginstal ufw...${NC}"
        sudo apt update && sudo apt install ufw -y
        if [[ $? -eq 0 ]]; then
            log_message "${GREEN}ufw berhasil diinstal.${NC}"
        else
            log_message "${RED}Gagal menginstal ufw. Periksa koneksi internet Anda.${NC}"
            exit 1
        fi
    else
        log_message "${GREEN}ufw sudah terinstal.${NC}"
    fi
}

# Fungsi untuk membuka rentang port
open_port_ranges() {
    for range in "${PORT_RANGES[@]}"; do
        log_message "${YELLOW}Membuka rentang port $range${NC}"
        ufw allow "$range"/tcp
        ufw allow "$range"/udp
        if [[ $? -eq 0 ]]; then
            log_message "${GREEN}Berhasil membuka rentang port $range${NC}"
        else
            log_message "${RED}Gagal membuka rentang port $range${NC}"
        fi
    done
}

# Fungsi untuk membuka port individual
open_individual_ports() {
    for port in "${INDIVIDUAL_PORTS[@]}"; do
        if validate_port "$port"; then
            log_message "${YELLOW}Membuka port $port${NC}"
            ufw allow "$port"/tcp
            ufw allow "$port"/udp
            if [[ $? -eq 0 ]]; then
                log_message "${GREEN}Berhasil membuka port $port${NC}"
            else
                log_message "${RED}Gagal membuka port $port${NC}"
            fi
        fi
    done
}

# Fungsi untuk menutup port spesifik
close_port() {
    if validate_port "$1"; then
        log_message "${YELLOW}Menutup port $1${NC}"
        ufw deny "$1"/tcp
        ufw deny "$1"/udp
        if [[ $? -eq 0 ]]; then
            log_message "${GREEN}Berhasil menutup port $1${NC}"
        else
            log_message "${RED}Gagal menutup port $1${NC}"
        fi
    fi
}

# Fungsi untuk menampilkan status port
show_port_status() {
    log_message "${YELLOW}Status port yang dibuka:${NC}"
    ufw status numbered | grep -E "^[[0-9]+]" >> "$LOG_FILE"
    ufw status numbered
}

# Memeriksa apakah ufw aktif
enable_ufw_if_not_active() {
    if ! ufw status | grep -q "Status: active"; then
        log_message "${YELLOW}Mengaktifkan firewall UFW...${NC}"
        ufw enable
        if [[ $? -eq 0 ]]; then
            log_message "${GREEN}Firewall UFW berhasil diaktifkan.${NC}"
        else
            log_message "${RED}Gagal mengaktifkan UFW.${NC}"
            exit 1
        fi
    else
        log_message "${GREEN}Firewall UFW sudah aktif.${NC}"
    fi
}

# Fungsi untuk backup konfigurasi UFW
backup_ufw_config() {
    BACKUP_DIR="/root/ufw-backup"
    BACKUP_FILE="$BACKUP_DIR/ufw-backup-$(date +%Y%m%d-%H%M%S).rules"
    
    # Buat direktori backup jika belum ada
    mkdir -p "$BACKUP_DIR"
    
    # Backup konfigurasi
    ufw status verbose > "$BACKUP_FILE"
    if [[ $? -eq 0 ]]; then
        log_message "${GREEN}Backup konfigurasi UFW berhasil dibuat di $BACKUP_FILE${NC}"
    else
        log_message "${RED}Gagal membuat backup konfigurasi UFW${NC}"
    fi
}

# Main execution
log_message "Memulai konfigurasi UFW..."

# Backup konfigurasi sebelum melakukan perubahan
backup_ufw_config

# Memeriksa dan menginstal ufw jika diperlukan
check_ufw_installed

# Mengaktifkan UFW jika belum aktif
enable_ufw_if_not_active

# Menerapkan aturan
open_port_ranges
open_individual_ports

# Reload UFW untuk menerapkan perubahan
log_message "${YELLOW}Memuat ulang aturan UFW...${NC}"
ufw reload

# Menampilkan status akhir
show_port_status

log_message "${GREEN}Konfigurasi UFW selesai.${NC}"
