#!/bin/bash
# 判断是否有java环境, 否则安装
#if [ -x "$(command -v java)" ]; then
#    echo "O java está instalado. Vamos ao próximo passo!"
#else
#    echo "O java precisa ser instalado. Vamos lá..."
#    sudo yum update
#    sudo yum install java-1.8.0-openjdk
#    echo "O java foi instalado com sucesso!"
#fi

if [ -x "$(command -v docker)" ]; then
    echo "Docker está instalado. Vamos ao próximo passo!"
else
    echo "O docker precisa ser instalado. Vamos lá..."
    sudo yum remove docker docker-engine docker.io containerd runc
    sudo yum update
    sudo yum install apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo yum update
    sudo yum install docker-ce docker-ce-cli containerd.io
    echo "Docker instalado com sucesso"
fi

if [ -x "$(command -v docker-compose)" ]; then
    echo "Docker-compose também está instalado. Vamos iniciar a instalação do ambiente!"
else
    sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

#if [ -x "$(command -v java)" ]; then
    if [ -x "$(command -v docker)" ]; then
        if [ -x "$(command -v docker-compose)" ]; then
            echo "Iniciando o deploy do ambiente..."
            echo "Construindo uma imagem local do jenkins"
            docker build -t myjenkins-blueocean:1.1 .
            sudo sysctl -w vm.max_map_count=262144
            sudo sysctl -w fs.file-max=65536
            ulimit -n 65536
            ulimit -u 4096
            echo "Realizando o deploy das aplicações..."
            docker-compose up -d
            echo "Deploy Jenkins + SonarQube + PostgreSQL + Nginx Succesfully"
            echo "Acesse o Jenkins em http://[HOST-ADDRESS]/jenkins"
            echo "Acesse o SonarQube em http://[HOST-ADDRESS]/sonar"
            echo "A porta padrão utilizada por este build é a 80. Você pode alterá-la modificando as configurações do Nginx em nginx.conf"
        else
            echo "Ocorreu um problema ao realizar o deploy do ambiente. O docker-compose não foi instalado. Procure o administrador do sistema!"
        fi
    else
        echo "Ocorreu um problema ao realizar o deploy do ambiente. O docker não foi instalado. Procure o administrador do sistema!"
    fi
#else
#    echo "Ocorreu um problema ao realizar o deploy do ambiente. O java não foi instalado. Procure o administrador do sistema!"
#fi
