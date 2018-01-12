#!/bin/bash
yum remove docker \
                  docker-common \
                  docker-selinux \
                  docker-engine

yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum-config-manager --enable docker-ce-edge

yum install -y docker-ce

systemctl enable docker

systemctl start docker

curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://c3c8dcbe.m.daocloud.io
service docker restart
