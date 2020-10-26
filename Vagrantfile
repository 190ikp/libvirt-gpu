# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  num_instances = 2
  cpus_per_instances = 4
  memory_per_instances = 16384

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box 
  end

  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = false

  config.vm.provider "libvirt" do |v|
    v.cpus = cpus_per_instances
    v.memory = memory_per_instances
  end

  (1..num_instances).each do |i|
    config.vm.provider "libvirt" do |v|
      v.name = "gpu-instance-#{i}"
    end
    config.vm.network "forwarded_port", guest: 80, host: "998#{i}", host_ip: 127.0.0.1
    config.vm.network "forwarded_port", guest: 443, host: "944#{i}", host_ip: 127.0.0.1
    config.vm.network "forwarded_port", guest: 22, host: "992#{i}", host_ip: 127.0.0.1
    config.vm.provision "shell" do |s|
      s.privileged = false
      s.path = "guest/setup.sh"
      s.args = ["all"]
    end
  end
end
