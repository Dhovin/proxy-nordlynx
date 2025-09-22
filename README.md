# Privoxy-NordLynx Docker Container

This project provides a Docker container that sets up a secure proxy environment. It routes all traffic through NordVPN using NordLynx, and then exposes both an HTTP/HTTPS proxy (Privoxy) and a SOCKS5 proxy (Dante) within the container. This allows you to easily route specific applications or your entire system's traffic through NordVPN.

## Features

*   **NordVPN Integration**: Connects to NordVPN using a token-based authentication and allows specifying a country.
*   **Privoxy**: Provides an HTTP/HTTPS proxy for filtering and forwarding web traffic.
*   **Dante**: Offers a SOCKS5 proxy for general network traffic.
*   **Supervisord**: Manages the Privoxy and Dante processes, ensuring they stay running.
*   **NordLynx**: Utilizes NordVPN's WireGuard-based protocol for fast and secure connections.

## Prerequisites

*   [Docker](https://docs.docker.com/get-docker/) installed on your system.
*   A NordVPN account.

## Setup

1.  **Clone the repository**:
    ```bash
    git clone <your-repository-url>
    cd privoxy-nordlynx
    ```
    *(Assuming you have already done this step)*

2.  **Create/Update `.env` file**:
    Create a file named `.env` in the root of the project directory with your NordVPN token and desired country. This file is used to provide environment variables when running the Docker container.

    ```
    NORDVPN_TOKEN=your_nordvpn_token_here
    NORDVPN_COUNTRY=Canada
    NORDVPN_TECHNOLOGY=nordlynx
    LAN_NETWORK=192.168.10.0/24
    ```
    *Replace `your_nordvpn_token_here` with your actual NordVPN token and `Canada` with your preferred country.*

## Building the Docker Image

Navigate to the project root directory and build the Docker image:

```bash
docker build -t privoxy-nordlynx .
```

## Running the Docker Container

Run the Docker container, passing your NordVPN token and country as environment variables. Ensure you replace the placeholder values with your actual token and country.

```bash
docker run -d \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  --name privoxy-nordlynx \
  -e NORDVPN_TOKEN="your_nordvpn_token_here" \
  -e NORDVPN_COUNTRY="Canada" \
  -e NORDVPN_TECHNOLOGY="nordlynx" \
  -e LAN_NETWORK="192.168.10.0/24" \
  -p 8118:8118 \
  -p 1080:1080 \
  privoxy-nordlynx
```
*Note: The `NORDVPN_TOKEN` and `NORDVPN_COUNTRY` values are passed directly as environment variables to the `docker run` command, as the Dockerfile and entrypoint script are not configured to read the `.env` file directly.*

## Environment Variables

*   `NORDVPN_TOKEN`: Your NordVPN authentication token.
*   `NORDVPN_COUNTRY`: The country you wish to connect to (e.g., `Canada`, `United States`).
*   `NORDVPN_TECHNOLOGY`: The VPN technology to use (e.g., `nordlynx`).
*   `LAN_NETWORK`: Your local area network CIDR (e.g., `192.168.10.0/24`). This is used for internal routing within the container.

## Usage

Once the container is running, you can configure your applications to use the proxies:

*   **HTTP/HTTPS Proxy (Privoxy)**:
    *   Address: `localhost`
    *   Port: `8118`
*   **SOCKS5 Proxy (Dante)**:
    *   Address: `localhost`
    *   Port: `1080`

## Troubleshooting / Notes

*   **Supervisord Warnings**: You might see `CRIT`ical warnings from `supervisord` in the logs about running as root without dropping privileges and an unsecured HTTP server. For a typical Docker setup, running as root is common, and these warnings do not prevent the proxy functionality. However, for production environments, consider hardening your `supervisord.conf` and running processes as a less privileged user.
*   **NordVPN Daemon**: The `entrypoint.sh` script now ensures the NordVPN daemon is started and connected before launching the proxy services.
*   **VPN Connection Stability**: If you experience issues, check the container logs (`docker logs privoxy-nordlynx`) for NordVPN connection errors.
