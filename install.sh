#!/bin/bash

# 获取用户输入
read -p "请输入Reader服务的镜像名称 (默认: hectorqin/reader): " READER_IMAGE
READER_IMAGE=${READER_IMAGE:-hectorqin/reader}

read -p "请输入Reader容器名称 (默认: reader): " READER_CONTAINER_NAME
READER_CONTAINER_NAME=${READER_CONTAINER_NAME:-reader}

read -p "请输入Reader服务的端口号 (默认: 4396): " READER_PORT
READER_PORT=${READER_PORT:-4396}

read -p "请输入日志映射目录 (默认: /home/reader/logs): " READER_LOGS
READER_LOGS=${READER_LOGS:-/home/reader/logs}

read -p "请输入数据映射目录 (默认: /home/reader/storage): " READER_STORAGE
READER_STORAGE=${READER_STORAGE:-/home/reader/storage}

read -p "请输入用户上限 (默认: 50): " READER_USERLIMIT
READER_USERLIMIT=${READER_USERLIMIT:-50}

read -p "请输入用户书籍上限 (默认: 200): " READER_USERBOOKLIMIT
READER_USERBOOKLIMIT=${READER_USERBOOKLIMIT:-200}

read -p "是否开启缓存章节内容 (true/false，默认: true): " READER_CACHECHAPTERCONTENT
READER_CACHECHAPTERCONTENT=${READER_CACHECHAPTERCONTENT:-true}

read -p "是否开启登录鉴权 (true/false，默认: true): " READER_SECURE
READER_SECURE=${READER_SECURE:-true}

read -p "请输入管理员密码 (默认: adminpwd): " READER_SECUREKEY
READER_SECUREKEY=${READER_SECUREKEY:-adminpwd}

read -p "请输入注册邀请码 (默认: registercode): " READER_INVITECODE
READER_INVITECODE=${READER_INVITECODE:-registercode}

read -p "请输入Watchtower容器名称 (默认: watchtower): " WATCHTOWER_CONTAINER_NAME
WATCHTOWER_CONTAINER_NAME=${WATCHTOWER_CONTAINER_NAME:-watchtower}

# 生成docker-compose.yaml文件
cat <<EOF > docker-compose.yaml
version: '3.1'
services:
  reader:
    image: ${READER_IMAGE}
    container_name: ${READER_CONTAINER_NAME}
    restart: always
    ports:
      - ${READER_PORT}:8080
    networks:
      - share_net
    volumes:
      - ${READER_LOGS}:/logs
      - ${READER_STORAGE}:/storage
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - READER_APP_USERLIMIT=${READER_USERLIMIT}
      - READER_APP_USERBOOKLIMIT=${READER_USERBOOKLIMIT}
      - READER_APP_CACHECHAPTERCONTENT=${READER_CACHECHAPTERCONTENT}
      - READER_APP_SECURE=${READER_SECURE}
      - READER_APP_SECUREKEY=${READER_SECUREKEY}
      - READER_APP_INVITECODE=${READER_INVITECODE}
  watchtower:
    image: containrrr/watchtower
    container_name: ${WATCHTOWER_CONTAINER_NAME}
    restart: always
    environment:
        - TZ=Asia/Shanghai
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: ${READER_CONTAINER_NAME} ${WATCHTOWER_CONTAINER_NAME} --cleanup --schedule "0 0 4 * * *"
    networks:
      - share_net
networks:
  share_net:
    driver: bridge
EOF

echo "docker-compose.yaml文件已生成"
