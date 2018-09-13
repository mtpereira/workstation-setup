# Workstation setup

This repository hosts the necessary automation for setting up my workstations.

It is meant to be used on Archlinux systems and it is very specific to my needs.

## Dependencies

### Packages

- git
- ansible
- openssh
- sudo

### Users

- Local nominal user with sudo access
  - `useradd -g users -G wheel -m __USERNAME__`
  - `passwd __USERNAME__`
  - `sudoedit /etc/sudoers` and uncomment the wheel line
- SSH key on that user's `~/.ssh` directory for accessing GitHub
  - `eval $(ssh-agent)`
  - `ssh-add ~/.ssh/id_rsa`
- Migrate GPG keys to the user's `~/.gnupg` directory
  - `OLD$ gpg -a --export > pubkeys.asc`
  - `OLD$ gpg -a --export-secret-keys > privatekeys.asc`
  - `OLD$ gpg --export-ownertrust > otrust.txt`
  - `NEW$ gpg --import privatekeys.asc`
  - `NEW$ gpg --import pubkeys.asc`
  - `NEW$ gpg --import-ownertrust otrust.txt`
  - `NEW$ gpg -K && gpg -k`

### Misc

- Ansible AUR module
  - `git clone git@github.com:kewlfft/ansible-aur.git ~/.ansible/plugins/modules/aur`

