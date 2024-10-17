#!/bin/bash
set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
INFO="${BLUE}[INFO]${NC}"
SUCCESS="${GREEN}[SUCCESS]${NC}"
WARNING="${YELLOW}[WARNING]${NC}"
ERROR="${RED}[ERROR]${NC}"

show_banner() {
    clear
    echo -e "${BLUE}"
    echo "======================================================"
    echo "              Docker Installation Script               "
    echo "======================================================"
    echo -e "${NC}"
}

check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${SUCCESS} $1"
    else
        echo -e "${ERROR} $2"
        exit 1
    fi
}

show_progress() {
    echo -e "${INFO} $1"
}

install_docker() {
    show_progress "Instalando Docker..."
    
    # Removendo versões antigas
    apt-get remove docker docker-engine docker.io containerd runc &> /dev/null
    
    # Instalando dependências
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Adicionando chave GPG oficial do Docker
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Configurando repositório
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Instalando Docker
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    check_status "Docker instalado com sucesso" "Falha na instalação do Docker"
}

main() {
    apt-get update && apt-get upgrade -y

    install_docker

}

main "$1"