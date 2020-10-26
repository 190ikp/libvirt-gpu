#!/usr/bin/env bash

set -euo pipefail

setup_packages() {

  sudo add-apt-repository universe
  sudo apt update
  sudo apt upgrade --yes
  
  sudo apt install --yes \
  build-essential \
  linux-headers-"$(uname -r)"
}

setup_nvml() {
  cuda_init.sh for_host
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
}

all() {
  echo 'Starting instance setup...'

  setup_packages
  setup_nvml
  setup_docker
  
  echo 'Done.'
}