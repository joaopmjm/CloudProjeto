#!/bin/bash

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo apt update

cd /home/ubuntu
mkdir database
cd database
mkdir scripts
cd scripts
cat > ./setup_db.sql <<EOF
DROP DATABASE IF EXISTS teste_db;
CREATE DATABASE teste_db;

DROP DATABASE IF EXISTS todos;
CREATE DATABASE todos;

DROP USER IF EXISTS db_adm@"%";
CREATE USER db_adm@"%" IDENTIFIED BY "123456789";
GRANT ALL ON teste_db.* TO db_adm@"%";
GRANT ALL ON todos.* TO db_adm@"%";

DROP USER IF EXISTS db_user@"%";
CREATE USER db_user@"%" IDENTIFIED BY "123456789";
GRANT SELECT, INSERT, UPDATE, DELETE ON teste_db.* TO db_user@"%";
GRANT SELECT, INSERT, UPDATE, DELETE ON todos.* TO db_user@"%";

COMMIT;

USE todos;
DROP TABLE IF EXISTS todos;

CREATE TABLE todos (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title VARCHAR(50) NOT NULL,
    description VARCHAR(120),
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

COMMIT;
EOF
cd ..

crontab <<EOF
@reboot sudo docker run -d -p 80:3306 --name=db_user \
    -e MYSQL_ROOT_PASSWORD="123456789" \
    -v /home/ubuntu/database/scripts:/docker-entrypoint-initdb.d \
    mysql:latest
EOF

sudo docker run -d -p 80:3306 --name=db_user \
    -e MYSQL_ROOT_PASSWORD="123456789" \
    -v /home/ubuntu/database/scripts:/docker-entrypoint-initdb.d \
    mysql:latest