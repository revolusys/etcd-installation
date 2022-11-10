#!/bin/bash

export RELEASE=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest|grep tag_name | cut -d '"' -f 4)

wget https://github.com/etcd-io/etcd/releases/download/${RELEASE}/etcd-${RELEASE}-linux-amd64.tar.gz

tar xvf etcd-${RELEASE}-linux-amd64.tar.gz

cd etcd-${RELEASE}-linux-amd64

sudo mv etcd etcdctl /opt/bin 

etcd --version

etcdctl version


sudo mkdir -p /var/lib/etcd/

sudo mkdir /etc/etcd

sudo groupadd --system etcd

sudo useradd -s /sbin/nologin --system -g etcd etcd

sudo chown -R etcd:etcd /var/lib/etcd/

sudo cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
User=etcd
Type=notify
Environment=ETCD_DATA_DIR=/var/lib/etcd
Environment=ETCD_NAME=etcd-01
ExecStart=/opt/bin/etcd
Restart=always
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl  daemon-reload

sudo systemctl  start etcd.service

sudo systemctl enable etcd.service

systemctl status etcd.service

etcdctl member list

etcdctl  endpoint health
