#!/bin/bash
#需要自行配置ROOT.xml中的数据源
#需要按需调整deploy-app.v[1-2].sh中是否需要传输到备份服务器上

set -e -u -o pipefail

HTTP_PORT=8080
HTTPS_PORT=8443

echo "Yes(是)= 1; No(否) = 2"
read -p "是否拥有备用Container? " HAVE_SPARE

if [ ${HAVE_SPARE} -eq 1 ]; then
    read -p "Container序号: " NUM
fi

read -p "http映射端口: " HTTP_PORT
read -p "https映射端口: " HTTPS_PORT
read -p "Container分配内存(G): " MEM
read -p "JAVA最大堆内存: " JVM_XMX
read -p "JAVA初始堆内存: " JVM_XMS
read -p "项目名称: " APP_NAME
read -p "不需要发布的应用: " NONEED

# 配置README
CONF_README() {

    README_FILE=app.homolo.net/README.md

    if [ ${1} -eq 1 ]; then

        sed -i "s/app\./web${NUM}\.${APP_NAME}\./" ${README_FILE}
        sed -i "s/ app / web${NUM}\.${APP_NAME} /" ${README_FILE}

    else

        sed -i "s/app\./${APP_NAME}\./" ${README_FILE}
        sed -i "s/ app / ${APP_NAME} /" ${README_FILE}
    fi

    sed -i "s/10g/${MEM}g/g" ${README_FILE}
    sed -i "s/8080:8080/${HTTP_PORT}:8080/g" ${README_FILE}
    sed -i "s/8443:8443/${HTTPS_PORT}:8443/g" ${README_FILE}
    sed -i "s/10G/${JVM_XMX}G/g" app.homolo.net/setenv.sh
    sed -i "s/4G/${JVM_XMS}G/g" app.homolo.net/setenv.sh

    for i in ${NONEED[@]}; do

        sed -i "/${i}/d" app.homolo.net/init.sh

    done
}

CONF_TOMCAT() {

    sed -i "s/app.homolo.net/${APP_NAME}/g" app.homolo.net/conf/server.xml

    for i in ${NONEED[@]}; do

        sed -i "/${i}/d" app.homolo.net/conf/server.xml

    done

}

MOVE_DIR() {

    sed -i "s/app\./${APP_NAME}\./" app.homolo.net/deploy-app.v1.sh
    sed -i "s/app\./${APP_NAME}\./" app.homolo.net/deploy-app.v2.sh
    mkdir -p app.homolo.net/apps/${APP_NAME}/ROOT
    mv app.homolo.net/conf/Catalina/app.homolo.net app.homolo.net/conf/Catalina/${APP_NAME}
    if [ ${1} -eq 1 ]; then

        mv app.homolo.net/deploy-app.v2.sh app.homolo.net/deploy-${APP_NAME}.sh
        rm -rf app.homolo.net/deploy-app.v1.sh
        mv app.homolo.net web${NUM}.${APP_NAME}.homolo.net

    else

        mv app.homolo.net/deploy-app.v1.sh app.homolo.net/deploy-${APP_NAME}.sh
        rm -rf app.homolo.net/deploy-app.v2.sh
        mv app.homolo.net ${APP_NAME}.homolo.net

    fi
}

tar jxf template.tar.bz2

CONF_TOMCAT

if [ ${HAVE_SPARE} -eq 1 ]; then

    CONF_README 1
    MOVE_DIR 1

else

    CONF_README 2
    MOVE_DIR 2

fi
