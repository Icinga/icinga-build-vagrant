# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = 'debian/jessie64'

  domain = 'vagrant.icinga.org'

  config.vm.provider 'virtualbox' do |vb|
    vb.cpus = 2
    vb.memory = '1024'
    vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    config.vm.synced_folder '.', '/vagrant', :type => 'virtualbox' # avoid rsync
  end

  config.vm.define 'jenkins' do |host|
    host.vm.hostname = "jenkins.#{domain}"
    host.vm.network 'forwarded_port', guest: 8080, host: 8080
    host.vm.network 'private_network', ip: '192.168.33.2'
  end

  config.vm.provision 'shell' do |shell|
    shell.path = 'scripts/shell_provisioner.sh'
  end

  config.vm.provision 'puppet' do |puppet|
    puppet.environment = 'vagrant'
    puppet.environment_path = '.'
    puppet.hiera_config_path = 'hiera.yaml'
    puppet.options = '--show_diff --parser=future --no-stringify_facts'
  end
end
