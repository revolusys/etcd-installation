#!/bin/bash

{
  wget -q --show-progress \
    https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl \
    https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson
  
  chmod +x cfssl cfssljson
  sudo mv cfssl cfssljson /opt/bin/
}


cat > ca-config.json <<EOF
{
    "signing": {
        "default": {
            "expiry": "8760h"
        },
        "profiles": {
            "etcd": {
                "expiry": "8760h",
                "usages": ["signing","key encipherment","server auth","client auth"]
            }
        }
    }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "etcd cluster",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "US",
      "L": "England",
      "O": "Kubernetes",
      "OU": "ETCD-CA",
      "ST": "Washington"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca



#- Create TLS certificates (replace ETCD1_IP, ETCD2_IP ETCD3_IP by yours)

{

ETCD1_IP="192.168.1.161"
ETCD2_IP="192.168.1.162"
ETCD3_IP="192.168.1.163"

cat > etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "localhost",
    "127.0.0.1",
    "${ETCD1_IP}",
    "${ETCD2_IP}",
    "${ETCD3_IP}"
  ],
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "US",
      "L": "England",
      "O": "Kubernetes",
      "OU": "etcd",
      "ST": "Washington"
    }
  ]
}
EOF
}
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-csr.json | cfssljson -bare etcd
