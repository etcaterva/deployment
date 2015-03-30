EtCaterva-Ansible
=================

Set of Ansible recipes to setup and configure EtCaterva servers.


Why this repository?
--------------------

Because having infrastructure to support physical backups is not cheap,
and in the unlikely event of our server getting corrupted or hacked, we'll
be able to set up a new one only executing one command.

To implement these setup scripts we have choosen Ansible, due its flexibility,
ease of use, and because some members of the team had already experience with it.

Now, we only have to care about losing data, having to maintain logical backups.


How to use it?
--------------

Using Ansible is pretty easy. We are aiming for the creation of Ansilbe
playbooks to configure certain services, although in the future we may
want to create only one playbook per server. These playbooks will be located
in the top level folder.

To install Ansible you can follow [Ansible install guide], or just try with
a classic `sudo apt-get install ansible` (although I had problems with that
version, having to install it using `sudo pip install ansible`).

[Ansible install guide]: http://docs.ansible.com/intro_installation.html

To run a playbook run:

    ansible-playbook -i <path/to/hosts.file> <path/to/playbook>

For example, to run the users.yml playbook to configure users of the server
execute:

    ansible-playbook -i hosts users.yml
