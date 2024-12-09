#!/bin/bash

# Definisi warna
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
RESET="\e[0m"

# Header
echo -e "${CYAN}======================================="
echo -e "        ${MAGENTA}🌟 System Information Checker 🌟"
echo -e "${CYAN}=======================================${RESET}"

# Informasi CPU
echo -e "\n${BLUE}💻 CPU Information:${RESET}"
lscpu | grep -E '^Model name|^CPU\(s\)|^Architecture|^CPU MHz' | sed "s/^/${YELLOW}/"

# Informasi RAM
echo -e "\n${GREEN}📊 RAM Information:${RESET}"
free -h | awk 'NR==1 || NR==2 {print $1, $2, $3, $4}' | sed "s/^/${YELLOW}/"

# Informasi Penyimpanan
echo -e "\n${MAGENTA}📦 Disk Storage:${RESET}"
df -h --total | grep -E '^Filesystem|total' | sed "s/^/${YELLOW}/"

# Informasi Sistem Operasi
echo -e "\n${CYAN}🖥️ Operating System:${RESET}"
lsb_release -a 2>/dev/null | sed "s/^/${YELLOW}/" || echo -e "${YELLOW}No lsb_release found. OS info may vary."

# Uptime
echo -e "\n${RED}⏱️ System Uptime:${RESET}"
uptime -p | sed "s/^/${YELLOW}/"

# Informasi Jaringan
echo -e "\n${GREEN}🌐 Network Information:${RESET}"
ip -o -4 addr show | awk '{print $2": "$4}' | sed "s/^/${YELLOW}/"
echo -e "${YELLOW}Default Gateway: $(ip route | grep default | awk '{print $3}')"
echo -e "Public IP: $(curl -s https://api.ipify.org || echo 'Failed to fetch public IP')"

# Informasi Proses Tertinggi (CPU dan RAM)
echo -e "\n${BLUE}🔥 Top Processes (CPU & Memory):${RESET}"
ps aux --sort=-%cpu,-%mem | awk 'NR<=10 {printf "%-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $11}' | sed '1i USER       PID       %CPU      %MEM      COMMAND' | sed "s/^/${YELLOW}/"

# Footer
echo -e "\n${CYAN}======================================="
echo -e "       ${MAGENTA}🎉 System Check Complete 🎉"
echo -e "${CYAN}=======================================${RESET}"
