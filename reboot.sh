#!/bin/bash

# Pola error yang ingin dicari
ERROR_PATTERN="Cannot read properties of undefined (reading 'search')"

# Fungsi untuk mengirim notifikasi ke Telegram
send_telegram_message() {
    local message="$1"
    local bot_token="2141143345:AAFfQWwgdjunKDhKkBweWgl2XmFxFmL-8Gs"  # Ganti dengan token bot Anda
    local chat_id="450810319"     # Ganti dengan chat ID Anda

    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -d chat_id="${chat_id}" \
        -d text="${message}" \
        -d parse_mode="Markdown" > /dev/null
}

# Fungsi untuk mendapatkan IP VPS
get_public_ip() {
    curl -s https://api.ipify.org
}

# Mendapatkan daftar nama container yang sedang berjalan
containers=$(docker ps --format "{{.Names}}")

# Iterasi melalui setiap container
for container in $containers; do
    echo "Memantau log untuk container: $container"
    
    # Memantau log container secara real-time
    docker logs --follow "$container" 2>&1 | while read -r line; do
        if [[ "$line" == *"$ERROR_PATTERN"* ]]; then
            # Dapatkan waktu saat ini dan IP VPS
            timestamp=$(date +"%Y-%m-%d %H:%M:%S")
            public_ip=$(get_public_ip)

            # Kirim notifikasi tentang error
            send_telegram_message "⚠️ *Error Terdeteksi!*  
🖥️ *VPS IP*: ${public_ip}  
📦 *Container*: ${container}  
🕒 *Waktu*: ${timestamp}  
🛑 *Pesan Error*: \`${line}\`"

            # Restart container
            echo "$(date) - Error terdeteksi pada container $container. Me-restart..."
            docker restart "$container"

            # Kirim notifikasi tentang restart
            timestamp_restart=$(date +"%Y-%m-%d %H:%M:%S")
            send_telegram_message "🔄 *Container Restarted!*  
🖥️ *VPS IP*: ${public_ip}  
📦 *Container*: ${container}  
🕒 *Waktu Restart*: ${timestamp_restart}  
✅ *Status*: Berhasil di-restart."
        fi
    done &
done
