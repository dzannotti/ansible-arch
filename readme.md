# My Ansible + Dotfiles for Arch Linux

```bash
sudo pacman -S python ansible
ansible-galaxy install -r requirements.yml
ansible-playbook -i localhost main.yml -K
```
