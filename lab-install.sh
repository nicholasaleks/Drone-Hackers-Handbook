#!/bin/bash
# lab-install.sh - Prepare Damn Vulnerable Drone lab on Kali Linux
# This script installs Docker and Docker Compose as per the book's instructions,
# clones the DVD repo, and builds the Docker containers (but does not start them).

set -e

echo "[+] Installing Docker dependencies..."

# Verify sudo is executed with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# Add Docker CE repository for Debian Bullseye
printf '%s\n' "deb https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list

# Import Docker GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-ce-archive-keyring.gpg

# Update and install Docker components
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io -y

# Verify Docker Compose plugin installed
echo "[+] Verifying Docker Compose..."
sudo docker compose --help

# Enable Docker service on boot and start it now
sudo systemctl enable docker --now

# Add current user to docker group
echo "[+] Adding user '$USER' to the docker group..."
sudo usermod -aG docker "$USER"

# Clone the Damn Vulnerable Drone repository if it doesn't already exist
REPO_DIR="${HOME}/Damn-Vulnerable-Drone"
if [ "$(id -u)" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    # If running via sudo, use the original user's home directory
    REPO_DIR="/home/${SUDO_USER}/Damn-Vulnerable-Drone"
fi
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning Damn Vulnerable Drone repository into ${REPO_DIR}..."
    git clone https://github.com/nicholasaleks/Damn-Vulnerable-Drone.git "$REPO_DIR"
else
    echo "Repository already exists at ${REPO_DIR}. Skipping clone."
fi

# Build the Damn Vulnerable Drone Docker images (Wi-Fi mode) without starting containers:contentReference[oaicite:6]{index=6}
echo "Building Damn Vulnerable Drone Docker images (with Wi-Fi support, this may take a while)..."
cd "$REPO_DIR"
docker compose build

echo "Docker image build completed. To explore the project, run:"
echo "cd \"$REPO_DIR\""
echo "After going to that directory, you can start the Damn Vulnerable Drone simulation with './start.sh --wifi' when ready."