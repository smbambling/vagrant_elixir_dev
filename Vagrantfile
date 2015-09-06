# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install any required plugins
required_plugins = ['vagrant-hostmanager','vagrant-auto_network']

for plugin in required_plugins
  unless Vagrant.has_plugin? plugin
    system("vagrant plugin install #{plugin}")
    need_vagrant_up = true
  end
end

if need_vagrant_up
  puts 'Vagrant plugins have been modified -- Please re-run vagrant up'
  exit(1)
end

# Configure Vagrant-Auto_Network plugin settings
AutoNetwork.default_pool = '10.10.10.0/24'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Domain used for VMs
  DOMAIN = "example.dev"

  # Vagrant virtual environment box that VMs will be built from
  BOX    = "smbambling/centos66-64"

  # Enable Vagrant-Hostmaster plugin settings
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true

  # Enable synced folder via NFS
  config.vm.synced_folder '.', '/vagrant', nfs: true

  # Foreman Server
  config.vm.define "elixir".to_sym do |elixir|
    elixir.vm.box = BOX
    elixir.vm.hostname = "elixir" + "." + DOMAIN
    elixir.hostmanager.aliases = %w(elixir)
    elixir.vm.network :private_network, :auto_network => true
    #set some machine-specific options  
    elixir.vm.provider "virtualbox" do |v|
      #change the amount of RAM 
      v.customize ["modifyvm", :id, "--memory", "1024"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
    end
    #run bootstrap scripts
    elixir.vm.provision :shell, :path => "bootstrap_scripts/puppet_agent.sh"
    elixir.vm.provision :puppet, 
      :manifests_path => "puppet/environments/dev/manifests",
      :manifest_file => "site.pp",
      :environment => "dev",
      :environment_path => "puppet/environments",
      :module_path => "puppet/environments/dev/modules",
      :hiera_config_path => "puppet/environments/dev/hiera.yaml"
  end

end
