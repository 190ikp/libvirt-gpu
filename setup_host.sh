#!/usr/bin/env bash

set -euxo pipefail


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