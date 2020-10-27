# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  num_instances = 1
  cpus_per_instances = 4
  memory_per_instances = 8192

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box 
  end

  config.vm.box = "generic/ubuntu1804"
  config.vm.box_check_update = false

  config.vm.synced_folder './guest/', '/vagrant', type: 'rsync'

  config.vm.provider "libvirt" do |v|
    v.cpus = cpus_per_instances
    v.memory = memory_per_instances
    v.kvm_hidden = true
  end

  config.vm.define :"gpu-instance-1" do |domain|
    domain.vm.provider "libvirt" do |v|
      v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x0'
      v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x1'
      v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x2'
      v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x3'
    end
  end
  config.vm.define :"gpu-instance-2" do |domain|
    domain.vm.provider "libvirt" do |v|
      v.pci :domain => '0x0000', :bus => '0xaf', :slot => '0x00', :function => '0x0'
      v.pci :domain => '0x0000', :bus => '0xaf', :slot => '0x00', :function => '0x1'
      v.pci :domain => '0x0000', :bus => '0xaf', :slot => '0x00', :function => '0x2'
      v.pci :domain => '0x0000', :bus => '0xaf', :slot => '0x00', :function => '0x3'
    end
  end
  
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    cd /vagrant
    ./setup.sh all
  SHELL
end
