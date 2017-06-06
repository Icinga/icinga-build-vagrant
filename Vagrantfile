# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_REQUIRED_LINKED_CLONE_VERSION = '1.8.0'

def setup_puppet_vm(config)
  config.vm.provider 'virtualbox' do |vb|
    vb.cpus = 2
    vb.memory = '1024'
    vb.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new(VAGRANT_REQUIRED_LINKED_CLONE_VERSION)
    config.vm.synced_folder '.', '/vagrant', :type => 'virtualbox' # avoid rsync
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

# Please also see https://github.com/coreos/coreos-vagrant/blob/master/Vagrantfile
def setup_coreos(config)
  update_channel = 'stable'
  image_version = 'current'
  config.vm.box = "coreos-#{update_channel}"
  config.vm.box_url = "https://storage.googleapis.com/#{update_channel}.release.core-os.net/amd64-usr/#{image_version}/coreos_production_vagrant.json"

  if Vagrant.has_plugin?('vagrant-vbguest') then
    config.vbguest.auto_update = false
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.cpus = 2
    vb.memory = '2048'
  end

  config.vm.provision 'shell' do |shell|
    shell.path = 'scripts/provision_coreos_jenkins.sh'
  end
end

Vagrant.configure(2) do |config|
  config.vm.box = 'debian/jessie64'

  domain = 'vagrant.icinga.org'

  config.vm.define 'jenkins' do |host|
    host.vm.hostname = "jenkins.#{domain}"
    host.vm.network 'forwarded_port', guest: 8080, host: 8080
    host.vm.network 'private_network', ip: '192.168.33.2'

    setup_puppet_vm(host)
  end

  config.vm.define 'aptly' do |host|
    host.vm.hostname = "aptly.#{domain}"
    host.vm.network 'forwarded_port', guest: 8080, host: 8090
    host.vm.network 'forwarded_port', guest: 80, host: 9090
    host.vm.network 'private_network', ip: '192.168.33.3'
    host.vm.box = "ubuntu/trusty64"

    setup_puppet_vm(host)
  end

  config.vm.define 'docker1' do |host|
    host.vm.hostname = "docker1.#{domain}"
    host.vm.network 'private_network', ip: '192.168.33.81'

    setup_coreos(host)
  end
end
