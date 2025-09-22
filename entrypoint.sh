#!/bin/bash

# Start NordVPN daemon
echo "Starting NordVPN daemon..."
/etc/init.d/nordvpn start

# Wait for NordVPN daemon to be ready
echo "Waiting for NordVPN daemon..."
until nordvpn status &> /dev/null; do
    sleep 1
done
echo "NordVPN daemon is running."

# Disable analytics
nordvpn set analytics 0

# Login to NordVPN
nordvpn login --token ${NORDVPN_TOKEN}

# Connect to NordVPN
nordvpn connect ${NORDVPN_COUNTRY}

# Wait for NordVPN connection to be established
echo "Waiting for NordVPN connection..."
until nordvpn status | grep "Status: Connected" > /dev/null; do
    sleep 2
done
echo "NordVPN connected."

# Whitelist ports
nordvpn whitelist add port 8118
nordvpn whitelist add port 1080

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
