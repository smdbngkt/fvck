#!/bin/bash

# Warna untuk output
GREEN="\e[32m"
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"

# Header
echo -e "${CYAN}======================================="
echo -e "        ${GREEN}System Information Checker"
echo -e "${CYAN}=======================================${RESET}"

# Informasi CPU
echo -e "\n${GREEN}CPU Information:${RESET}"
lscpu | grep -E '^Model name|^CPU\(s\)|^Architecture|^CPU MHz'

# Total penggunaan CPU
echo -e "\n${GREEN}Total CPU Usage:${RESET}"
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
echo -e "CPU Usage: ${RED}$CPU_USAGE${RESET}"

# Informasi RAM
echo -e "\n${GREEN}RAM Information:${RESET}"
RAM_INFO=$(free -m | awk 'NR==2 {printf "Total: %s MB | Used: %s MB | Free: %s MB", $2, $3, $4}')
RAM_PERCENT=$(free | awk 'NR==2 {printf "%.2f", $3/$2 * 100}')
echo -e "$RAM_INFO"
echo -e "RAM Usage: ${RED}$RAM_PERCENT%${RESET}"

# Informasi Penyimpanan
echo -e "\n${GREEN}Disk Storage:${RESET}"
df -h --total | grep -E '^Filesystem|total'

# Informasi Sistem Operasi
echo -e "\n${GREEN}Operating System:${RESET}"
lsb_release -a 2>/dev/null || echo "No lsb_release found. OS info may vary."

# Uptime
echo -e "\n${GREEN}System Uptime:${RESET}"
uptime -p

# Informasi Jaringan
echo -e "\n${GREEN}Network Information:${RESET}"
ip -o -4 addr show | awk '{print $2": "$4}'
echo -e "Default Gateway: $(ip route | grep default | awk '{print $3}')"
echo -e "Public IP: $(curl -s https://api.ipify.org || echo 'Failed to fetch public IP')"

# Informasi Proses Tertinggi (CPU dan RAM)
echo -e "\n${GREEN}Top Processes (CPU & Memory):${RESET}"
ps aux --sort=-%cpu,-%mem | awk 'NR<=10 {printf "%-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $11}' | sed '1i USER       PID       %CPU      %MEM      COMMAND'

# Footer
echo -e "\n${CYAN}======================================="
echo -e "       ${GREEN}System Check Complete"
echo -e "${CYAN}=======================================${RESET}"
