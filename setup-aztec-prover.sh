#!/bin/bash

clear
cat << "EOF"
# ┌────────────────────────────────────┐
# │███╗   ███╗██████╗  ██████╗ ██╗  ██╗│
# │████╗ ████║██╔══██╗██╔════╝ ██║  ██║│
# │██╔████╔██║██████╔╝██║  ███╗███████║│
# │██║╚██╔╝██║██╔══██╗██║   ██║██╔══██║│
# │██║ ╚═╝ ██║██║  ██║╚██████╔╝██║  ██║│
# │╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝│
# └────────────────────────────────────┘                          
#      created by 0xMugi
#      Setup Aztec Prover Node
#                               
EOF

# Exit on any error
set -e

# Check if resuming
RESUME=false
if [ "$1" == "--resume" ]; then
  RESUME=true
  echo "Melanjutkan dari langkah terakhir..."
fi

# Verify running on Ubuntu
if ! lsb_release -a 2>/dev/null | grep -q "Ubuntu"; then
  echo "Error: Skrip ini hanya untuk Ubuntu Linux."
  exit 1
fi

# Function to install prerequisites and Docker
install_prerequisites() {
  echo "Menginstal prerequisite..."
  sudo apt-get update
  sudo apt-get install -y curl ca-certificates gnupg lsb-release

  echo "Menginstal Docker..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  echo "Menginstal Docker Compose..."
  DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K[^"]+')
  sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $USER

  # Verify Docker
  if ! command -v docker &> /dev/null; then
    echo "Error: Docker gagal diinstal. Coba jalankan 'sudo apt-get update && sudo apt-get install -y docker-ce' secara manual."
    exit 1
  fi

  # Verify Docker Compose
  if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose gagal diinstal."
    exit 1
  fi
}

# Function to install Aztec CLI
install_aztec_cli() {
  echo "Menginstal Aztec CLI..."
  if curl -s https://install.aztec.network | grep -q "404"; then
    echo "URL https://install.aztec.network tidak valid, beralih ke instalasi via npm..."
    sudo npm install -g @aztec/cli
  else
    echo "y" | bash -i <(curl -s https://install.aztec.network)
  fi

  # Verify Aztec CLI
  if ! command -v aztec-cli &> /dev/null; then
    echo "Warning: Aztec CLI gagal diinstal. Prover Node mungkin tetap berjalan via Docker, tetapi beberapa perintah CLI tidak akan tersedia."
  else
    echo "Aztec CLI berhasil diinstal."
    echo "Memperbarui Aztec CLI ke versi alpha-testnet..."
    aztec-cli update alpha-testnet
  fi

  # Update PATH
  echo "Memperbarui PATH..."
  export PATH=$PATH:/root/.aztec/bin
  echo 'export PATH=$PATH:/root/.aztec/bin' >> ~/.bashrc
  source ~/.bashrc
}

# Function to create .env file
create_env_file() {
  echo "Membuat file .env..."
  cat << EOF > .env
ETHEREUM_HOSTS=https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key
L1_CONSENSUS_HOST_URL=https://sepolia-beacon.drpc.org
PROVER_PUBLISHER_PRIVATE_KEY=0xYourPrivateKey
PROVER_ID=0xYourPublicAddress
DATA_DIRECTORY=/data
LOG_LEVEL=info
DATA_STORE_MAP_SIZE_KB=134217728
PROVER_BROKER_HOST=http://broker:8080
PROVER_AGENT_COUNT=1
PROVER_AGENT_POLL_INTERVAL_MS=10000
# P2P_ENABLED=true
# PROVER_COORDINATION_NODE_URL=http://:8080
EOF

  echo "File .env telah dibuat di $(pwd)/.env."
  echo "Silakan edit file ini dengan data Anda:"
  echo "- ETHEREUM_HOSTS: URL RPC Sepolia (contoh: https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key)"
  echo "- L1_CONSENSUS_HOST_URL: URL Beacon Chain (contoh: https://sepolia-beacon.drpc.org)"
  echo "- PROVER_PUBLISHER_PRIVATE_KEY: Kunci privat Ethereum (contoh: 0xYourPrivateKey)"
  echo "- PROVER_ID: Alamat publik Ethereum (contoh: 0xYourPublicAddress)"
  echo "Cara edit di SSH:"
  echo "1. Buka file: nano .env"
  echo "2. Edit nilai yang diperlukan."
  echo "3. Simpan: Ctrl+O, Enter, lalu keluar: Ctrl+X"
  echo "Setelah selesai mengedit, jalankan skrip lagi dengan:"
  echo "  ./setup-aztec-prover.sh --resume"
  echo "Skrip akan berhenti sekarang."
  exit 0
}

# Function to create docker-compose.yml
create_docker_compose() {
  echo "Membuat file docker-compose.yml..."
  mkdir -p /home/my-node/node
  cat << EOF > docker-compose.yml
name: aztec-prover
services:
  prover-node:
    image: aztecprotocol/aztec:0.85.0-alpha-testnet.2
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start
      - --prover-node
      - --archiver
      - --network
      - alpha-testnet
    depends_on:
      broker:
        condition: service_started
        required: true
    environment:
      ETHEREUM_HOSTS: \${ETHEREUM_HOSTS}
      L1_CONSENSUS_HOST_URL: \${L1_CONSENSUS_HOST_URL}
      LOG_LEVEL: \${LOG_LEVEL}
      PROVER_BROKER_HOST: \${PROVER_BROKER_HOST}
      PROVER_PUBLISHER_PRIVATE_KEY: \${PROVER_PUBLISHER_PRIVATE_KEY}
      DATA_DIRECTORY: \${DATA_DIRECTORY}
      DATA_STORE_MAP_SIZE_KB: \${DATA_STORE_MAP_SIZE_KB}
      # P2P_ENABLED: \${P2P_ENABLED}
      # PROVER_COORDINATION_NODE_URL: \${PROVER_COORDINATION_NODE_URL}
    ports:
      - "8080:8080"
      - "40400:40400"
      - "40400:40400/udp"
    volumes:
      - /home/my-node/node:/data

  agent:
    image: aztecprotocol/aztec:0.85.0-alpha-testnet.2
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start
      - --prover-agent
      - --network
      - alpha-testnet
    environment:
      PROVER_AGENT_COUNT: \${PROVER_AGENT_COUNT}
      PROVER_AGENT_POLL_INTERVAL_MS: \${PROVER_AGENT_POLL_INTERVAL_MS}
      PROVER_BROKER_HOST: \${PROVER_BROKER_HOST}
      PROVER_ID: \${PROVER_ID}
    pull_policy: always
    restart: unless-stopped

  broker:
    image: aztecprotocol/aztec:0.85.0-alpha-testnet.2
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start
      - --prover-broker
      - --network
      - alpha-testnet
    environment:
      DATA_DIRECTORY: \${DATA_DIRECTORY}
      ETHEREUM_HOSTS: \${ETHEREUM_HOSTS}
      LOG_LEVEL: \${LOG_LEVEL}
    volumes:
      - /home/my-node/node:/data
EOF
}

# Main logic
if [ "$RESUME" = false ]; then
  # Install prerequisites if Docker not installed
  if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
    install_prerequisites
  else
    echo "Docker dan Docker Compose sudah terinstal, melewati langkah ini."
  fi

  # Install Node.js and npm (for Aztec CLI fallback)
  if ! command -v npm &> /dev/null; then
    echo "Menginstal Node.js dan npm (untuk fallback Aztec CLI)..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    if ! command -v npm &> /dev/null; then
      echo "Error: npm gagal diinstal."
      exit 1
    fi
  else
    echo "Node.js dan npm sudah terinstal, melewati langkah ini."
  fi

  # Install Aztec CLI if not installed
  if ! command -v aztec-cli &> /dev/null; then
    install_aztec_cli
  else
    echo "Aztec CLI sudah terinstal, melewati langkah ini."
  fi

  # Create .env if it doesn't exist
  if [ ! -f .env ]; then
    create_env_file
  else
    echo "File .env sudah ada, melewati pembuatan. Pastikan sudah diedit dengan data valid."
  fi
fi

# Resume from here if --resume is used
if [ ! -f docker-compose.yml ]; then
  create_docker_compose
else
  echo "File docker-compose.yml sudah ada, melewati pembuatan."
fi

# Start Docker Compose services
echo "Menjalankan layanan Prover Node..."
sudo docker-compose up -d

echo "Selesai! Prover Node, Broker, dan Agent telah diatur."
echo "Untuk memeriksa status: sudo docker-compose ps"
echo "Untuk melihat log: sudo docker-compose logs -f"
echo "Untuk menghentikan: sudo docker-compose down"