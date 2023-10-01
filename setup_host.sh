#!/usr/bin/env bash

set -euo pipefail

# setup for GPU Paththrough
# see: https://github.com/NVIDIA/deepops/blob/master/virtual/README.md#enabling-virtualization-and-gpu-passthrough
# This script works well with Linux kernel > 4.1

setup_kernel() {
  echo 'Starting kernel setup...'
  sudo sed -i -e \
    "s/^GRUB_CMDLINE_LINUX=\"\"$/GRUB_CMDLINE_LINUX=\"quiet splash intel_iommu=on vfio_iommu_type1.allow_unsafe_interrupts=1 iommu=pt\"/g" \
    /etc/default/grub
  sudo cp conf/vfio-pci.conf /etc/modules-load.d/vfio-pci.conf

  sudo update-grub
  echo 'Done. Reboot to enable kernel parameter.'
}

setup_vfio() {
  # This script works only with NVIDIA GPUs

  echo "options vfio-pci ids=$(\
      lspci -nd 10de: |
        awk '{print $3}' |
        tr '\n' ',' |
        sed 's/,$//'\
      )" |
    sudo tee /etc/modprobe.d/vfio.conf
  
  sudo update-initramfs -u
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

print_vgpu() {
  # This script works only with NVIDIA GPUs

  lspci -Dnd 10de: | awk '{print $1}' | while read -r line; do
    domain="$(echo $line | cut -d ':' -f 1)"
    bus=$(echo $line | cut -d ':' -f 2)
    slot=$(echo $line | cut -d ':' -f 3 | cut -d '.' -f 1)
    function=$(echo $line | cut -d ':' -f 3 | cut -d '.' -f 2)
    echo "v.pci :domain => '0x$domain', :bus => '0x$bus', :slot => '0x$slot', :function => '0x$function'"
  done
}

eval "$1"
