#!/bin/bash

systemctl disable firewalld --now

curl -sfL https://get.k3s.io | K3S_URL=https://server.public.main.oraclevcn.com:6443 K3S_CLUSTER_SECRET='${cluster_token}' sh -