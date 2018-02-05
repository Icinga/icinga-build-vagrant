#!/bin/bash

set -e

OSTYPE="unknown"

if [ -x /usr/bin/lsb_release ]; then
    OSTYPE=$(lsb_release -i -s)
    CODENAME=$(lsb_release -sc)
elif [ -e /etc/redhat-release ]; then
    OSTYPE="RedHat"
else
    echo "Unsupported OS!" >&2
    exit 1
fi

if [ ! -e /var/initial_update ]; then
    echo "Running initial upgrade"
    if [ "$OSTYPE" = "Debian" ] || [ "$OSTYPE" = "Ubuntu" ]; then
        apt-get update
        apt-get dist-upgrade -y
        date > /var/initial_update
    elif [ "$OSTYPE" = "RedHat" ]; then
        yum update -y
        date > /var/initial_update
    fi
fi

if [ "$OSTYPE" = "Debian" ]; then
    bp="/etc/apt/sources.list.d/backports.list"
    if [ ! -e "$bp" ]; then
        echo "Enabling backports repo"
        echo "deb http://httpredir.debian.org/debian ${CODENAME}-backports main" >"$bp"
        apt-get update
    fi

    bpp="/etc/apt/sources.list.d/backports-puppet3.list"
    if [ -e "${bpp}" ]; then
        rm -f "${bpp}"
    fi

    debsrc=/etc/apt/sources.list.d/puppet5.list
    if [ ! -e "$debsrc" ]; then
        echo "Installing Puppetlabs release package..."
        wget -O /tmp/puppetlabs.deb "https://apt.puppetlabs.com/puppet5-release-${CODENAME}.deb"
        dpkg -i /tmp/puppetlabs.deb
        rm -f /tmp/puppetlabs.deb
        apt-get update
    fi
elif [ "$OSTYPE" = "Ubuntu" ]; then
    if [ ! -e /etc/apt/sources.list.d/puppet5.list ]; then
        echo "Installing Puppetlabs release package..."
        wget -O /tmp/puppetlabs.deb "https://apt.puppetlabs.com/puppet5-release-${CODENAME}.deb"
        dpkg -i /tmp/puppetlabs.deb
        rm -f /tmp/puppetlabs.deb
        apt-get update
    fi
elif [ "$OSTYPE" = "RedHat" ]; then
    if [ ! -e /etc/yum.repos.d/puppet5.repo ]; then
        echo "Installing Puppet 5 release..."
        yum install -y https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
    fi
fi

if [ "$OSTYPE" = "Debian" ]  || [ "$OSTYPE" = "Ubuntu" ]; then
    if dpkg -s puppet &>/dev/null; then
        echo "You have package 'puppet' for version < 4 installed." >&2
        echo "Please fix this manually, this environment needs at least Puppet 4!" >&2
        exit 1
    elif ! dpkg -s puppet-agent &>/dev/null; then
        echo "Installing puppet..."
        apt-get install -y "puppet-agent"
    fi
elif [ "$OSTYPE" = "RedHat" ]; then
    if ! rpm -q puppet &>/dev/null; then
        echo "Installing puppet..."
        yum install -y puppet-agent
    fi
fi

if [ "$OSTYPE" = "RedHat" ]; then
    if [ `getenforce` = 'Enforcing' ]; then
        echo "Setting selinux to permissive"
        setenforce 0
    fi

    if grep -qP "^SELINUX=enforcing" /etc/selinux/config; then
        echo "Disabling selinux after reboot"
        sed -i 's/^\\(SELINUX=\\)enforcing/\\1disabled/' /etc/selinux/config
    fi
fi
