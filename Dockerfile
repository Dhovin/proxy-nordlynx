# Use Ubuntu 24.04 as base image
FROM ubuntu:24.04

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Arguments that can be passed at build time
ARG NORDVPN_TOKEN
ARG NORDVPN_COUNTRY

# Set environment variables
ENV NORDVPN_TOKEN=${NORDVPN_TOKEN}
ENV NORDVPN_COUNTRY=${NORDVPN_COUNTRY}

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y net-tools privoxy dante-server curl supervisor iputils-ping && \
    rm -rf /var/lib/apt/lists/*

# Install NordVPN
RUN curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh | sh -s -- -n

# Create nordvpn group
RUN groupadd nordvpn || true

# Copy configuration files
COPY dante.conf /etc/danted.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisord/privoxy.conf /etc/supervisor/conf.d/privoxy.conf
COPY supervisord/dante.conf /etc/supervisor/conf.d/dante.conf
COPY supervisord/nordvpn.conf /etc/supervisor/conf.d/nordvpn.conf
COPY privoxy.config /etc/privoxy/config
COPY nordvpn_setup.sh /nordvpn_setup.sh
RUN chmod +x /nordvpn_setup.sh

COPY run_danted.sh /run_danted.sh
RUN chmod +x /run_danted.sh

# Expose ports
EXPOSE 8118 1080

# Set up entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Start supervisord

