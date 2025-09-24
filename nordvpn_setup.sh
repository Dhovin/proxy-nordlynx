#!/bin/bash
set -x

# Strip whitespace from environment variables
NORDVPN_TOKEN=$(echo "${NORDVPN_TOKEN}" | tr -d '[:space:]')

# Test DNS resolution
ping -c 4 8.8.8.8
ping -c 4 nordvpn.com

# Start NordVPN daemon
echo "Starting NordVPN daemon..."
/etc/init.d/nordvpn start

# Wait for NordVPN daemon to be ready
echo "Waiting for NordVPN daemon..."
until nordvpn status &> /dev/null; do
    sleep 1
done
echo "NordVPN daemon is running."

echo "Waiting 15 seconds for NordVPN server list to load..."
sleep 15

# Disable analytics
nordvpn set analytics 0

# Set technology
nordvpn set technology nordlynx

# Login to NordVPN
nordvpn login --token ${NORDVPN_TOKEN}

# Connect to NordVPN
nordvpn connect "${NORDVPN_COUNTRY}"

# Wait for NordVPN connection to be established
echo "Waiting for NordVPN connection..."
until nordvpn status | grep "Status: Connected" > /dev/null; do
    sleep 2
done
echo "NordVPN connected."

# Whitelist ports
nordvpn whitelist add port 8118
nordvpn whitelist add port 1080

# Keep the script running in the foreground for supervisord
tail -f /dev/null