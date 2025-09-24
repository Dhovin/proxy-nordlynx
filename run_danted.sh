#!/bin/bash

# Wait for nordlynx interface to be up
until ip link show nordlynx >/dev/null 2>&1; do
    echo "Waiting for nordlynx interface..."
    sleep 1
done

exec /usr/sbin/danted -f /etc/danted.conf
