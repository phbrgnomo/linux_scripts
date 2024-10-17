
    
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
