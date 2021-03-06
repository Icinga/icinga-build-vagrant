Icinga Buildsystem Vagrant
==========================

This environment helps you to bring up a local test environment for the Icinga build system.

It is not intended for demo, but for developing the build system.

Based on [lazyfrosch/vagrant-puppet-boilerplate](https://github.com/lazyfrosch/vagrant-puppet-boilerplate).

## Prepare

Checkout this repository

    git clone https://github.com/Icinga/icinga-build-vagrant.git

    # if you are a project member
    git clone git@github.com:Icinga/icinga-build-vagrant.git

Install required ruby tools:

    bundle install
    bundle install --path vendor/bundle

And checkout the Puppet modules: (via r10k)

    rake deploy

## Recommended plugin

You might need the Vagrant plugin `vagrant-vbguest` to install / update the Virtualbox tools on the VMs.

This will help you install tools before first provisioning, and updating them after a Kernel update.

    vagrant plugin install vagrant-vbguest

## Bring up machines

You can bring up the Vagrant boxes like this:

    vagrant up jenkins

    # or all
    vagrant up

Apply changes in the Puppet or hiera data:

    vagrant provision
    vagrant provision <host>

## Known Problems

### Admin Password

You can find the initial admin password of Jenkins at

    /var/lib/jenkins/secrets/initialAdminPassword

### Creating Jobs

By default Jenkins enables integrated security for the server.

So Puppet will fail creating any resources inside Jenkins.

* Login to Jenkins with the admin password (`/var/lib/jenkins/secrets/initialAdminPassword`)
* Go to Users and change the admin user
* Add the SSH key of Jenkins' Home to the user (`/var/lib/jenkins/.ssh/id_rsa.pub`)

If this is done you can configure the security to whatever you like.
Just make sure admin is still allowed to manage things.

### Publishing Packages

Aptly will fail to publish packages if there is no GPG key present. You need to generate one
as user `root` and import the public key with `apt-key`.

* `gpg2 --gen-key`
* `gpg2 --export --armor > aptly.key`
* `apt-key add aptly.key`

## Services

| Service          | VM                               | Local                              |
| -----------------|----------------------------------|------------------------------------|
| Jenkins          | http://192.168.33.2:8080         | http://localhost:8080              |
| Jenkins Agent    | 192.168.33.81 SSH Port 2222      |                                    |
| Aptly API        | http://192.168.33.3:8080         | http://localhost:8090              |
| Aptly API (auth) | http://192.168.33.3              |                                    |
| Repositories     | http://192.168.33.3/aptly/public | http://localhost:9090/aptly/public |

### Adding the slave

In order to connect Jenkins to the slave two things need to be configured:
The node and a set of credentials. They are currently not in puppet because
we do not have a template for credentials yet. You will need to create a new
ssh-credential with the username 'jenkins' and ~/.ssh as location for the key.

When adding a node, set the following options:

    Remote root directory: /home/jenkins
    Launch method: Launch via ssh
    Host: 192.168.33.81
	Port: 2222
    Credentials: /the credentials you created/

## License

    Copyright (C) 2017 Icinga Development Team <info@icinga.com>
                  2017 Markus Frosch <markus.frosch@icinga.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
