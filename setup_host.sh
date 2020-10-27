#!/usr/bin/env bash

set -euxo pipefail

# setup for GPU Paththrough
# see: https://github.com/NVIDIA/deepops/blob/master/virtual/README.md#enabling-virtualization-and-gpu-passthrough
# This script works well with Linux kernel > 4.1

setup_kernel() {
  echo 'Starting kernel setup...'
  sudo sed -i -e \
    "s/^GRUB_CMDLINE_LINUX=/GRUB_CMDLINE_LINUX="quiet splash intel_iommu=on vfio_iommu_type1.allow_unsafe_interrupts=1 iommu=pt"/g" \
    /etc/default/grub
  sudo cp conf/vfio-pci.conf /etc/modules-load.d/vfio-pci.conf

  sudo update-grub
  echo 'Done. Reboot to enable kernel parameter.'
}

setup_vagrant() {
  echo 'Starting vagrant setup...'

  export VAGRANT_VERSION=2.2.10
  
  wget https://releases.hashicorp.com/vagrant/"$VAGRANT_VERSION"/vagrant_"$VAGRANT_VERSION"_x86_64.deb
  sudo apt install --yes ./vagrant_"$VAGRANT_VERSION"_x86_64.deb
  rm ./vagrant_"$VAGRANT_VERSION"_x86_64.deb
  sudo apt install --yes \
    qemu \
    libvirt-daemon-system \
    libvirt-clients \
    ebtables \
    dnsmasq-base \
    libxslt-dev \
    libxml2-dev \
    libvirt-dev \
    zlib1g-dev \
    ruby-dev

  vagrant plugin install vagrant-libvirt vagrant-cachier

  echo 'vagrant setup done.'
  echo 'Log out to apply changed permissions.'
}

eval "$1"
