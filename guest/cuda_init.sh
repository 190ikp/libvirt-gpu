#!/usr/bin/env bash
set -euo pipefail

export CONTAINER_CUDA_VERSION=10-1

modify_bashrc() {
  # don't variable expand in heredoc
  cat << 'EOF' >> ~/.bashrc
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64
EOF
}

setup_repos() {
  sudo apt update
  sudo apt upgrade --yes
  # install requirements
  sudo apt install --yes \
    "linux-headers-$(uname -r)" \
    build-essential

  # add CUDA and cuDNN repository
  sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
  echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" |
    sudo tee /etc/apt/sources.list.d/cuda.list
  echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" |
    sudo tee /etc/apt/sources.list.d/nvidia-ml.list

  # add libnvidia-container & nvidia-docker repository
  curl -fsSL https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
  curl -fsSL https://nvidia.github.io/nvidia-docker/ubuntu18.04/nvidia-docker.list |
    sudo tee /etc/apt/sources.list.d/nvidia-container.list
  
  sudo apt update
}

for_host() {
  setup_repos

  # NVIDIA driver only
  sudo apt install --yes \
    cuda-drivers \
    nvidia-container-toolkit
}

for_container() {
  setup_repos

  # no GPU driver
  sudo apt install --yes --no-install-recommends \
    cuda-toolkit-$CONTAINER_CUDA_VERSION

  modify_bashrc
}

echo 'Setup CUDA...'
eval "$1"
echo 'Done.'