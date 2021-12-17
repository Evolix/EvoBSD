# EvoBSD

EvoBSD is an ansible project used for customising OpenBSD hosts used by Evolix.

## How to install an OpenBSD machine

**Note :** The system must be installed with a root account only.

1.  Install ansible's prerequisites

```
ansible-playbook prerequisite.yml -CDi hosts -l HOSTNAME
```

2.  Run it

The variables files evolix-main.yml and evolinux-secrets.yml are customized variables for Evolix that overwrite main.yml variables. They are not needed if you are not from Evolix.

First use (become_method: su) :

```
ansible-playbook evolixisation.yml --ask-vault-pass -CDki hosts -u root -l HOSTNAME
```

Subsequent use (become_method: sudo) :

```
ansible-playbook evolixisation.yml --ask-vault-pass -CDKi hosts --skip-tags pf -l HOSTNAME
```

## Contributions

See the [contribution guidelines](CONTRIBUTING.md)

## License

[MIT License](LICENSE)
