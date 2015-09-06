#!/usr/bin/env bash
# Install Puppet-Agent 4.x

set -e

if [ "$EUID" -ne "0" ] ; then
  echo "Script must be run as root." >&2
  exit 1
fi

if which puppet > /dev/null ; then
  echo "Puppet is already installed"
  exit 0
fi

# Generate a Passphraseless SSH key for the root user
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa

if [ ! -f /home/vagrant/repos_added.txt ]; then
  echo "Installing PuppetLabs Repository"
  sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
else
  echo "Puppet Repostiroy Already Added"
fi

if [ ! -f /home/vagrant/puppet_agent_installed.txt ]; then
  echo "Installing Puppet-Agent Puppet 4.x"
  sudo yum -y install puppet-agent rubygems
else
  echo "Puppet is already installed"
fi

echo 'Adding Profile.D script to place puppet in $PATH'
echo 'PATH=/opt/puppetlabs/bin/:$PATH' >> /etc/profile.d/vagrant_puppetlabs.sh 
