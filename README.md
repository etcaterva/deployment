EtCaterva-Ansible
=================

Set of Ansible recipes to setup and configure EtCaterva servers.


Why this repository?
--------------------

Because having infrastructure to support physical backups is not cheap,
and in the unlikely event of our server getting corrupted or compromised, we'll
be able to set up a new one only executing one command.

To implement these 'setup scripts' we have choosen [Ansible], due its
flexibility, ease of use, and because some members of the team had already
experience with it.

Now, we only have to care about losing data, having to maintain logical backups.


How to use it?
--------------

Using Ansible is pretty easy. We are aiming for the creation of Ansilbe
playbooks to configure certain servers. These playbooks are located
in the top level folder.

To install Ansible you can follow the [Ansible install guide], or just try with
a classic `sudo apt-get install ansible` (although I had problems with that
version, having to install it using `sudo pip install ansible`).

To run a playbook run:

    ansible-playbook -i <path/to/hosts.file> <path/to/playbook>

For example, to run the webservers.yml playbook (to configure the web servers)
execute:

    ansible-playbook -i hosts_dev webservers.yml

> Note: For decrypting one of the variable files you will have to use either
> `--ask-vault-pass` or `--vault-password-file`. For more information see
> [how to run a playbook with vault] documentation.

If you need to pick the target username, you can simply add
`--extra-vars "ansible_user=root"`. For example, for an initial deployment of
the production server, you can run:

    ansible-playbook -i environments/prod/hosts full-site.yml --vault-password-file ../vault --extra-vars "ansible_user=root"

Testing changes
---------------

To make tesing the changes easier for us, we have created a script to automate
the creation of a Virtual Machine, using [Vagrant].

> Note: Unfortunately, Ansible can't run on Windows, and given that we use the
> Ansible provisioner for Vagrant, you won't be able to use this Vagrantfile.

To install Vagrant (Debian):

    sudo apt-get install vagrant

If you want to use Vagrant with libvirt (Debian):

    # Install some dependencies needed
    sudo apt-get install zlib1g-dev
    sudo apt-get install nfs-kernel-server
    sudo apt-get install libvirt-dev

    # Install libvirt and mutate Vagrant plugins
    vagrant plugin install vagrant-libvirt
    vagrant plugin install vagrant-mutate

    # Download the Vagrant box we are going to use, and mutate it for libvirt
    vagrant box add ubuntu/trusty64
    vagrant mutate ubuntu/trusty64 libvirt

Once you have Vagrant configured in your system, you will be able to run the
scipt for creating the VM with:

    vagrant up

The VM will get the IP `192.168.77.22`. You can ssh using that IP and one of
the created users, or using:

    vagrant ssh

If you want to open the web servers, the following URLs (using [xip.io]) are
configured to work:
- <http://www.192.168.77.22.xip.io>
- <http://2011.192.168.77.22.xip.io>

[Ansible install guide]: http://docs.ansible.com/intro_installation.html
[Ansible]: http://docs.ansible.com/ansible/index.html
[how to run a playbook with vault]: http://docs.ansible.com/ansible/playbooks_vault.html#running-a-playbook-with-vault
[Vagrant]: https://docs.vagrantup.com/v2/
[xip.io]: http://xip.io/
