# Overview

This repository contains a development Vagrant skeleton project that leverages Puppet for provisioning of Vagrant guest virtual machines

The setup for this project contains a single Vagrant guest virutal machine using a 'streamlined' install of Centos 6.x, with Puppet 4.x (Puppet AIO, Puppet-Agent).

## Pre-Configuration

In order to deploy/provision the Vagrant guest virtual machines you will need the following installed on your host (local machine)

#### VirtualBox

Download and install the VirtualBox binary for your system.  [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)

If you're using [Hombrew](http://brew.sh) and [Cask](http://caskroom.io) you can do this easily

````
$ brew cask install virtualbox
````

#### Vagrant

> **Vagrant >= 1.7.4 is required for the use with Puppet 4.x**

Download and install the Vagrant binary for your system. [Download Vagrant](http://www.vagrantup.com/downloads.html).

If you're using [Hombrew](http://brew.sh) and [Cask](http://caskroom.io) you can do this easily

````
$ brew cask install vagrant
````

#### Vagrant Plugins

To simplify the managment of your Vagrant development environment(s), this skeleton requires the following Vagrant plugins to be installed.

[Vagrant Hostmanager](https://github.com/smdahlen/vagrant-hostmanager) : (**Required via Vargrantfile**)

The Vagrant Hostmanager plugin lets you add a configuration to Vagrant to automatically update your /etc/hostfile and point it to the IP in use. I really enjoy this plugin because it allows you to develop on a pretty URL such as http://elixir.example.dev versus 10.10.10.60 or the IP in use.

````
$ vagrant plugin install vagrant-hostmanager
````

[Vagrant Auto-network](https://github.com/oscar-stack/vagrant-auto_network) : (**Required via Vargrantfile**)

The Vagrant Auto-network plugin removes the requirement to manually assign a network interface and IP address for each Vagrant guest virtual machine, and update private network interfaces to make sure that new machines don't collide.  This is accomplished by the use of the pools.yaml file with a hash for each guest virtual machine located at ```` ~/.vagrant.d/auto_network/pool.yaml````

````
$ vagrant plugin install vagrant-auto_network
````

#### Librarian-Puppet

In order to assit with management of the required Puppet modules, [Librarian-Puppet](https://github.com/rodjek/librarian-puppet) can be used with the provided Puppetfile.  This will fetch any modules listed in the Puppetfile from the specified source

Install the Librarian-Puppet Ruby Gem
````
$ sudo gem install librarian-puppet
````

If using Ruby 1.8.7 ( Centos 6.x ) install the 1.x series.  As of this writing 1.5.0 is the latest
````
$ sudo gem install librarian-puppet -v 1.5.0
````

#### Vagrant NFS Synced Folders

[Synced folders](http://docs.vagrantup.com/v2/synced-folders/index.html) enable Vagrant to sync a folder on the host machine to the guest machine, allowing you to continue working on your project's files on your host machine, but use the resources in the guest machine to compile or run your project.

By default, Vagrant will share your project directory (the directory with the Vagrantfile) to **/vagrant**.

In some cases the default shared folder implementations (such as VirtualBox shared folders) have high performance penalties.  This project has [NFS synced folders](http://docs.vagrantup.com/v2/synced-folders/nfs.html) enabled within the [Vagrantfile](http://docs.vagrantup.com/v2/vagrantfile/index.html)

Before using synced folders backed by NFS, the host machine must have nfsd installed, the NFS server daemon. This comes pre-installed on Mac OS X.

To configure NFS, Vagrant must modify system files on the host. Therefore, at some point during the vagrant up sequence, you may be prompted for administrative privileges (via the typical sudo program).

For information on prerequisites and requirements visit the [offical docs: synced folders - nfs](http://docs.vagrantup.com/v2/synced-folders/nfs.html)

If you wish to disable comment out/remove the **nfs:true** reference in the Vargrantfile config.vm.synced_folder section 

Here is a quick sed to acommplish disabling NFS Shared folders

````
sed -i 's/, nfs: true/#, nfs: true/g' Vagrantfile
````

## Copy/Clone The Skeleton Project

To assist with copying/cloning the skeleton project a shell script ````copy_project.sh```` is provided.

The ````copy_project.sh```` will perform the following actions

- Copy the skeleton project to the the specified location
- Replace any references to the default skeleton node name 'elixir' in ALL files recursively to the specified node name
- Rename any files that contain the default skeleton node name 'elixir' to the specified node anem

Execute the ./copy_project.sh script to create a copy/clone of the skeleton project

````
./copy_project.sh -n testnode1 -p vagrant_testnode1
````

````
$ ./copy_project.sh -h
  Usage: ./copy_project.sh <options>

  OPTIONS:
    -n : node/hostname; REQUIRED
    -p : project name; Defaults to -n value
    -l : location to 'clone' the project,
         Defaults to the parent directory of
         of the vagrant_skeleton project
    -h : print usage
````

## Manage Puppet Modules

This section assumes the following: 

- You have completed the Configuration section above and installed all required applications
- You have copyed/cloned the skeleton project and changed to the new project directory

#### Background

Puppet 4.x now heavly utilizes the concept of [directory environments](https://docs.puppetlabs.com/puppet/3.8/reference/environments_configuring.html), creating isolated groups of Puppet agent nodes. Each with a completely different [main manifests](https://docs.puppetlabs.com/puppet/4.1/reference/dirs_manifest.html) and [modulepaths](https://docs.puppetlabs.com/puppet/4.1/reference/dirs_modulepath.html). 

In order for Vagrant to use Puppet 4.x as a provisioner it requires the use of Puppet directory environments via the Vagrantfile.

````
:environment => "dev",
:environment_path => "puppet/environments",
````

All Puppet related/required items are located under the **puppet/environments/dev/** directory located inside the newly cloned project directory.

````
$ ls
Puppetfile       environment.conf hiera.yaml       hieradata        manifests
````

#### The Puppetfile

In order for use to leverage the use of [Librarian-Puppet](https://github.com/rodjek/librarian-puppet) a Puppetfile is supplied.

Libraian-Puppet will read this file and fetch any modules listed. When fetching a module all dependencies specified in its Modulefile, metadata.json and Puppetfile will be resolved and installed.

To require additional modules to be fetched for you project update the Puppetfile with a stanza listing for the module.

In this example the **apt** module from PuppetLabs Github repository is required and checks out a tag of **0.0.3**

````
mod 'puppetlabs-apt',
  :git => "git://github.com/puppetlabs/puppetlabs-apt.git",
  :ref => '0.0.3'
````

When using a GIT source, we do not have to use a :ref =>. If we do not, then librarian-puppet will assume we meant the master branch.

When using a :ref =>, we can use anything that Git will recognize as a ref including:

- any branch name
- tag name
- SHA
- SHA unique prefix

If a branch is used for the :ref =>, Librarian-puppet can be called to updated the module by fetching the most recent version of the module from that same branch ( **librarian-puppet update** )

For additional information please see the [Libraian-Puppet Docs](https://github.com/rodjek/librarian-puppet#puppetfile-breakdown)

#### Fetch Install/Update Procedure

> You MUST be in the directory that the Puppetfile resides in before running librarian-puppet

Change to the **puppet/environments/dev/** directory located inside the newly cloned project directory.  Located in this directory resides the Puppetfile used by Librarian-Puppet to fetch the required Puppet modules used for Puppet provisioning.

````
cd puppet/environments/dev
````

Execute **librarian-puppet install** to created the **modules** and place the fetched modules within it.

````
librarian-puppet install
````

If a branch was used for the :ref =>, you can execute **librarian-puppet install** to fetch the most recent version of the module from that same branch

````
librarian-puppet update
````

## Deploy The Vagrant Environment

To build, bootstrap and provision the defined guest virtual machine referenced in the Vagrantfile run the **vagrant up** command.  

This will:

- Create a VirtualBox guest instance from the BOX listed in the Vagrantfile
- Execute any Bootstrap provisioning scripts/tasks
- Execute a Puppet Apply to run/apply a specified manifest lised in the Vagrantfile

````
vagrant up
````

In the event your project referneces more then a single guest virtual machine in the Vagrant file you can deploy a single guest by calling the guest'name' as an option to the **vagrant up** command

````
vagrant up testnode1
````

## Accessing Vagrant Guest Virtual Machines

The guest can be accessed via traditional SSH communcation method.  The default password for the root user account is 'vagrant'

````
ssh root@testnode1.example.dev
root@testnode1.example.dev's password:
````

Or by issuing the **vagrant ssh** command from within the Vagrant project directory

````
vagrant ssh
[vagrant@testnode1 ~]$
````

In the event your project referneces more then a single guest virtual machine in the Vagrant file you can ssh to a sepcific deployed guest by calling the guest'name' as an option to the **vagrant ssh** command

````
vagrant ssh testnode1
[vagrant@testnode1 ~]$
````

## Manual Puppet Execution

This section assumes the following:

- You have deployed your Vagrant environment
- You have remoted in/accessed your guest virtual machine

From time to time you may want to execute some arbitrary Puppet [Puppet DSL/Code](https://docs.puppetlabs.com/puppet/latest/reference/lang_summary.html) or a manifest for testing.  To elevate the need to destroy and reprovision your Vagrant environment you can manaully execute a **puppet apply**.  

To manually execute Puppet DSL/Code

````
$ sudo /opt/puppetlabs/bin/puppet apply --hiera_config=/vagrantpuppet/environments/dev/hiera.yaml --modulepath=/vagrant/puppet/environments/dev/modules/ -e 'DSL GOES HERE'
````

To manually execute a Puppet manifest

````
$ sudo /opt/puppetlabs/bin/puppet apply --hiera_config=/vagrantpuppet/environments/dev/hiera.yaml --modulepath=/vagrant/puppet/environments/dev/modules/ <manifest.pp>
````