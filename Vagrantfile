# -*- mode: ruby -*-
# vi: set ft=ruby :

def setup_puppet_vm(config)
  config.vm.provider 'virtualbox' do |vb|
    vb.cpus = 2
    vb.memory = '2048'
    config.vm.synced_folder '.', '/vagrant', :type => 'virtualbox' # avoid rsync
  end

  config.vm.provision 'shell' do |shell|
    shell.path = 'scripts/shell_provisioner.sh'
  end

  config.vm.provision 'puppet' do |puppet|
    puppet.environment = 'vagrant'
    puppet.environment_path = '.'
    puppet.hiera_config_path = 'hiera.yaml'
    puppet.options = '--show_diff'
  end
end

Vagrant.configure(2) do |config|
  domain = 'vagrant.icinga.org'

  if Vagrant.has_plugin?('vagrant-vbguest') then
    config.vbguest.auto_update = false
  end

  config.vm.define 'jenkins' do |host|
    host.vm.box = 'ubuntu/xenial64'
    host.vm.hostname = "jenkins.#{domain}"
    host.vm.network 'forwarded_port', guest: 8080, host: 8080
    host.vm.network 'private_network', ip: '192.168.33.2'

    setup_puppet_vm(host)
  end

  config.vm.define 'aptly' do |host|
    host.vm.box = "ubuntu/trusty64"
    host.vm.hostname = "aptly.#{domain}"
    host.vm.network 'forwarded_port', guest: 8080, host: 8090
    host.vm.network 'forwarded_port', guest: 80, host: 9090
    host.vm.network 'private_network', ip: '192.168.33.3'

    setup_puppet_vm(host)
  end
end
