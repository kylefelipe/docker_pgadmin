#!/bin/bash

# Author: Kyle Felipe
# E-mail: kylefelipe at gmail.com
# data: 28/11/2022
# Ùltima atualização: 28/11/2022
# Script feito para criar um container do PgAdmin  com a pasta de configurações
# em um local específico, a princípio é uma pasta data no diretório atual
# para não perder as configurações do PgAdmin quando o container for removido
# ou atualizado.
# É intenção futura poder escolher via opções onde colocar a pasta data.

REPOLINK="https://github.com/kylefelipe/docker_pgadmin"
version='0.0.1'
container_name="pgadmin"
hostname="localhost"
host_port="5050"
PGADMIN_DEFAULT_PASSWORD="postgres"
PGADMIN_DEFAULT_EMAIL="postgres"
remove_container="n"
config_dir="$(pwd -P)"
pgadmin_version="latest"

usage() {
    echo "Uso:  sudo create_postgis.sh [OPÇÃO]

    Essas opções possuem argumentos obrigatórios:

        [ -c | --container container name ]
        [ -C | --config-dir path to config folder to map to container ]
        [ -V | --pga_version string PgAdmin container version tag to use, link in the end of this help ]
        [ -h | --hostname hostname hostname/ip to expose at host ]
        [ -p | --port pgadmin port ]
        [ -P | --password pgadmin default password ]
        [ -U | --user pgadmin default user email ]
    
    Essas opções não precisam de argumentos:

        [ --rm_container remove container before create ]
        [ --help exibe esse help ]
        [ --version informa a versão e sai ]"

    echo ""
    echo "Cheque as tags que podem ser utilizadas no PgAdmin4 em <https://hub.docker.com/r/postgis/postgis/tags>"
    echo "Página do repositório desse script: <$REPOLINK>"
    echo "Envie os erros e sugestões para <$REPOLINK/issues>"
    echo "Se foi útil, deixe uma estrelinha"
    echo "LLP _\\\\//"
    echo "<www.kylefelipe.com>"
    exit 2
}

version() {
    echo $version
    exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n argument -o c:C:V:h:p:P:U: \
                    --long container:,config-dir:,pga_version:,hostname:,port:,password:,user:,rm-container,help,version -- "$@")

VALID_ARGUMENTS=$?

if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
fi

eval set -- "$PARSED_ARGUMENTS"

while :
do
    case "$1" in
    -c | --container)
        container_name="$2"
        shift 2
    ;;
    -C | --config-dir)
        config_path="$2"
        shift 2
    ;;
    -p | --port)
        host_port="$2"
        shift 2
    ;;
    -P | --password)
        PGADMIN_DEFAULT_PASSWORD="$2"
        shift 2
    ;;
    -U | --user)
        PGADMIN_DEFAULT_EMAIL="$2"
        shift 2
    ;;
    -V | --pga_version)
        pga_version="$2"
        shift 2
    ;;
    --rm-container)
        remove_container="s"
        shift
    ;;
    --help)
        usage
        shift 2
    ;;
    -v | --version)
        version
        shift 2
    ;;
    --)
        shift
        break
        ;;
    *)
        echo "Opção $1 não reconhecida."
        usage
        ;;
    esac
done


if [ "$remove_container" = "s" ]; then
    echo "Removendo container $container_name"
    docker container rm -f "$container_name"
fi

if [ ! -d "$data_dir/config_dir" ]; then
    echo "Criando a pasta /config_dir dentro do diretório $config_dir/config_dir"
    mkdir -p "$data_dir/config_dir"
    echo "Pronto!"

fi

if [ -d "$data_dir/config_dir" ] && [ ! -w "$data_dir/config_dir" ] && [ ! -x "$data_dir/config_dir" ]; then
    echo "Usuário não tem permissão para alterar a pasta $data_dir/config_dir"
    echo "Considere executar como super usuário!"
    exit 1
fi

if [ "$VALID_ARGUMENTS" = "0" ]
then
    existing_container="$(docker ps -q -f name=$container_name)"
    if [ -n "$existing_container" ] && [ "$remove_container" = "n" ]; then
        echo "Já existe um container com o nome $container_name."
        echo "Por favor, especifique um novo nome de container ou remova o já exstente"
        echo "ou use a opção --rm_container, para remover um container pré existente de mesmo nome"
        usage
    fi

    echo ""

    echo ""
    echo "Criando o container $container_name em modo daemon."
    echo ""
    echo "Imagem Pgadmin utilizada: dpage/pgadmin4:$pga_version"
    echo "https://hub.docker.com/r/dpage/pgadmin4"

    docker pull dpage/pgadmin:$pga_version

    sudo chown -R 5050:5050 $config_dir/config_dir

    docker run --name "$container_name" \
    --restart unless-stopped \
    -p $host_port:80 \
    -v "$config_dir/config_dir":/var/lib/pgadmin/ \
    -e "PGADMIN_DEFAULT_EMAIL=$PGADMIN_DEFAULT_EMAIL" \
    -e "PGADMIN_DEFAULT_PASSWORD=$PGADMIN_DEFAULT_PASSWORD" \
    -d dpage/pgadmin4:$pga_version
    
    echo ""
    if [ "$(docker ps -q -f name=$container_name -f status=running)"  == "" ]; then
        echo -n "Aguardando container iniciar"
        while [ "$(docker ps -q -f name=$container_name -f status=running)"  == "" ]; do
            echo -n "."
            sleep 1
        done
    fi

    sleep 10

    echo ""
    echo "Container criado com sucesso!"
    echo "Para acessar basta conectar em:"
    echo "${hostname}:$host_port"
    echo ""
    echo "Para parar o container:"
    echo "docker container stop $container_name"
    echo ""
    echo "Para iniciar o container (reutilizar):"
    echo "docker container start $container_name"
    echo ""
    echo "Para acessar o shell do container:"
    echo "docker container exec -it $container_name bash"
    echo ""
    echo "Be Happy!"
    echo "LLP _\\\\//"
fi
