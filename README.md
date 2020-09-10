# EvoBSD 6.7.1

EvoBSD is an ansible project used for customising OpenBSD hosts
used by Evolix.

## How to install an OpenBSD machine

**Note :** The system must be installed with a root account only.
Put your public key in the remote root's autorized_keys
(/root/.ssh/authorized_keys)

1.  Install ansible's prerequisites

```
ansible-playbook prerequisite.yml -CDi hosts -l HOSTNAME
```

2.  Run it

First use (become_method: su, and var_files uncommented) :

```
ansible-playbook evolixisation.yml --ask-vault-pass -CDki hosts -l HOSTNAME -u root
```

Subsequent use (become_method: sudo) :

```
ansible-playbook evolixisation.yml --ask-vault-pass -CDKi hosts -l HOSTNAME
```

### Testing

Changes can be tested by using [Packer](https://www.packer.io/) and
[vmm(4)](https://man.openbsd.org/vmm.4) :

*   This process depends on the [Go](https://golang.org/) programming language.

## Packages

Needing a Golang eco system and some basics

````
pkg_add go-- packer-- git--
````

*   We use the [packer-builder-openbsd-vmm](https://github.com/double-p/packer-builder-openbsd-vmm) project to bridge Packer and vmm(4)

````
git clone https://github.com/double-p/packer-builder-openbsd-vmm.git
````

## builds

Set ````GOPATH```` (default: ~/go), if the 1.4GB dependencies wont fit.

````
make
make install
````

*   You need your unprivileged user to be able to run vmctl(8) through doas(1)

```
echo "permit nopass myunprivilegeduser as root cmd /usr/sbin/vmctl" >> /etc/doas.conf
```

See packer-builder-openbsd-vmm/examples/README.examples for further instructions

*   Enable NAT on your host machine

```
pass out on em0 inet from tap0:network to any nat-to (em0)
```
*assuming em0 is your egress interface*

## Contributions
See the [contribution guidelines](CONTRIBUTING.md)

## License

[MIT License](LICENSE)
