# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = 'centos/7'
  config.vm.synced_folder ".", "/vagrant"

  config.ssh.forward_agent = true # So that boxes don't have to setup key-less ssh
  config.ssh.insert_key = false # To generate a new ssh key and don't use the default Vagrant one

  # common provisioning for all
  config.vm.provision "shell", path: "scripts/init.sh"

  # configure zookeeper cluster
  (1..3).each do |i|
    config.vm.define "cassandra#{i}" do |s|
      s.vm.hostname = "cassandra#{i}"
      s.vm.network "private_network", ip: "10.30.4.#{i}", netmask: "255.255.0.0", virtualbox__intnet: "replic-network"

      s.vm.provision "shell" do |cmd|
       	cmd.inline = "cp /vagrant/config/cassandra${1}.yaml /opt/cassandra/conf/cassandra.yaml && chown cassandra.cassandra /opt/cassandra/conf/cassandra.yaml && su -l -c 'cassandra' cassandra"
        cmd.args   = ["#{i}"]
      end

    end
  end

  config.vm.provider "virtualbox" do |v|
    #  This setting controls how much cpu time a virtual CPU can use. A value of 50 implies a single virtual CPU can use up to 50% of a single host CPU.
    v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
	v.memory = 2048
  end
end
