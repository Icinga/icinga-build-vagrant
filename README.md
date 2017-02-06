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

Puppet will fail the first time when trying to create the build-jobs.
This is because authorization for the anonymous user is currently missing,
to work around this do the following:

* `vagrant ssh jenkins` and become root
* Edit the `/var/lib/jenkins/config.xml` file
* Set `useSecurity` to false
* Remove the `authorizationStrategy` and `securityRealm` blocks
* Save the file and restart Jenkins
* Leave the machine and re-run `vagrant provision jenkins`

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
