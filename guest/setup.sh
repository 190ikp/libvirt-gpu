#!/usr/bin/env bash

set -euo pipefail

fix_resolver() {
  sudo rm -f /etc/netplan/*
  sudo mv -f conf/netplan.yaml /etc/netplan/01-netcfg.yaml
  sudo sed -i \
    -e "s/^DNS=.*$/DNS=131.113.224.8/g" \
    -e "s/^DNSSEC=yes$/DNSSEC=no/g" \
    /etc/systemd/resolved.conf

  sudo systemctl restart systemd-resolved.service
  sudo netplan apply
}

setup_packages() {

  sudo add-apt-repository universe
  sudo apt update
  sudo apt upgrade --yes
  
  sudo apt install --yes \
  build-essential \
  linux-headers-"$(uname -r)"
}

setup_sshd() {
  
  sudo cp conf/sshd_config /etc/ssh/sshd_config
  sudo systemctl restart ssh

}

setup_nvml() {
  ./cuda_init.sh for_host
}

setup_docker() {
  sudo apt install --yes \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

  sudo apt update
  sudo apt install --yes \
    docker-ce \
    docker-ce-cli \
    containerd.io
  
  sudo usermod -aG docker "$USER"
}

all() {
  echo 'Starting instance setup...'

  setup_sshd
  fix_resolver
  setup_packages
  setup_nvml
  setup_docker
  
  echo 'Done.'
}

eval "$1"