# Subir novas instancias do PGADMIN sem perder as configurações

## Caso já exista um PgAdmin sem volume

Copie as configurações do PgAdmin para um local...

```bash
docker cp <container>:/var/lib/pgadmin <pasta_de_destino>
sudo chown -R 5050:5050
```

Para novas atualizações não precisa fazer a cópia de novo

## Atualize a imagem do PgAdmin

```shell
docker pull dpage/pgadmin
```

## Pare e remova os containers

Cuidado, aconselho fazer apenas o stop do container e testar o novo com um nome diferente.. em caso de problemas, ainda tem chance de voltar a usar o container antigo.

```shell
docker stop <container> # Para o container
docker rm <container> # (CUIDADO) Remove o container
```

## Inicie um container fazendo o bind para a nova pasta

```shell
docker run --name pgadmin -p 5050:80 -v <pasta_de_destino>:/var/lib/pgadmin/ -e "PGADMIN_DEFAULT_EMAIL=usuario@email" -e "PGADMIN_DEFAULT_PASSWORD=senha_usuario" -d dpage/pgadmin4
```

Docker atualizado e sem perder as conexões

## Font

[stackoverflow](https://stackoverflow.com/questions/63212270/how-to-update-the-pgadmin4-docker-image)
