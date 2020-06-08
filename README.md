# EvoBSD 1.0

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

```
ansible-playbook evolixisation.yml --ask-vault-pass -CDKi hosts -l HOSTNAME
```

### Testing

Changes can be tested by using [Packer](https://www.packer.io/) and
[vmm(4)](https://man.openbsd.org/vmm.4) :

*   This process depends on the [Go](https://golang.org/) programming language.

```
# pkg_add go packer
```

*   We use the [packer-builder-vmm](https://github.com/prep/packer-builder-vmm) project to bridge Packer and vmm(4)

```
$ go get -u github.com/prep/packer-builder-vmm/cmd/packer-builder-vmm
```

*   Here is an example build file

```
$ vim openbsd.json
```

    {
      "description": "OpenBSD installation on vmm(4)",

      "variables": {
        "hostname":    "evobsd",
        "domain":      "example.com",

        "password": "evolix"
      },

      "builders": [
        {
          "type":      "vmm",
          "vm_name":   "evobsd",
          "disk_size": "2G",
          "format":    "qcow2",
          "mem_size":  "1024M",

          "iso_urls":          ["downloads/install64.fs", "https://ftp.nluug.nl/pub/OpenBSD/6.4/amd64/install64.fs"],
          "iso_checksum":      "7aa4344cb39efbf67300f97ac7eec005b607e8c19d4e31a0a593a8ee2b7136e4",
          "iso_checksum_type": "sha256",

          "boot_wait": "10s",
          "boot_command": [
            "S<enter>",

            "cat <<EOF >disklabel.template<enter>",
            "/ 1G-* 100%<enter>",
            "EOF<enter>",

            "cat <<EOF >install.conf<enter>",
            "System hostname = {{user `hostname`}}<enter>",
            "DNS domain name = {{user `domain`}}<enter>",
            "Password for root account = {{user `password`}}<enter>",
            "Do you expect to run the X Window System = no<enter>",
            "Setup a user = no<enter>",
            "Which disk is the root disk = sd1<enter>",
            "Use (A)uto layout, (E)dit auto layout, or create (C)ustom layout = c<enter>",
            "URL to autopartitioning template for disklabel = file://disklabel.template<enter>",
            "Location of sets = disk<enter>",
            "Is the disk partition already mounted = no<enter>",
            "Set name(s) = -bsd.rd<enter>",
            "Set name(s) = done<enter>",
            "Directory does not contain SHA256.sig. Continue without verification = yes<enter>",
            "What timezone are you in = Europe/Paris<enter>",
            "EOF<enter>",

            "install -af install.conf<enter>",
            "<wait2m>",

            "/sbin/halt -p<enter><wait15>"
          ]
        }
      ]
    }


*   You need your unprivileged user to be able to run vmctl(8) through doas(1)

```
# echo "permit nopass myunprivilegeduser as root cmd /usr/sbin/vmctl" >> /etc/doas.conf
```

*   Build the virtual machine

```
$ packer build openbsd.json
```

*   Start it

```
doas vmctl start evobsd -cL -d output-vmm/evobsd.qcow2
```

*   Enable NAT on your host machine

```
pass out on em0 inet from tap0:network to any nat-to (em0)
```
*assuming em0 is your egress interface*

## Contributions
See the [contribution guidelines](CONTRIBUTING.md)

## License

[MIT License](LICENSE)
