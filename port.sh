#!/bin/bash

# Port ranges to open
PORT_RANGES=("2003:2020" "3003:3020" "4003:4020" "5003:5020")

# Additional individual ports to open
INDIVIDUAL_PORTS=(80 8108 443 22 3389)

# Function to open port ranges
open_port_ranges() {
  for range in "${PORT_RANGES[@]}"; do
    echo "Opening port range $range"
    ufw allow "$range"/tcp
    ufw allow "$range"/udp
  done
}

# Function to open individual ports
open_individual_ports() {
  for port in "${INDIVIDUAL_PORTS[@]}"; do
    echo "Opening port $port"
    ufw allow "$port"/tcp
    ufw allow "$port"/udp
  done
}

# Enable UFW if not enabled
if ! ufw status | grep -q "Status: active"; then
  echo "Enabling UFW firewall..."
  ufw enable
fi

# Apply the rules
open_port_ranges
open_individual_ports

# Reload UFW to apply changes
ufw reload

echo "All specified ports have been opened."
