# Preparation

### Using `machinectl` to change shells

Apparently, when doing the usual `sudo su - foo` dance, we cannot use `systemctl --user` commands.  To
get a shell for a different user, now needs to use `machinectl` from the `systemd-container` package:

```bash
$ sudo machinectl shell --uid webapp
```

!!! note

    This **only** works for users which have a valid login
    shell.

Changing shell:

```bash
$ sudo usermod -s /bin/bash webapp
$ sudo usermod -s /bin/bash db
```


### Firewall and Networking

!!! warning

    Lima VMS **do not create any bridge network by default**.  One's supposed to
    use **port forwarding**.

```yaml
portForwards:
# Cockpit
  - guestPort: 9090
    hostPort: 9090
# Web
  - guestPort: 8080
    hostPort: 8080
# PostgreSQL
  - guestPort: 5432
    hostPort: 15432
# ODOO
  - guestPort: 8069
    hostPort: 8069
  - guestPort: 8072
    hostPort: 8072
```

We'll later enable ports and services using the firewall.


[firewalld verstehen](https://viertelwissen.de/firewalld-verstehen-und-benutzen-firewall-cmd/)
[RHEL 7: Using Firewalls](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-using_firewalls)
[RHEL 9: Firewalls and Packet Filters](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_firewalls_and_packet_filters/using-and-configuring-firewalld_firewall-packet-filters)

### User Mounts

To be preserve the contents of the `webapp` and `db` user homes, we need to copy the contents
of `./users/{webapp,db}` from the project dir to the VM, and fix permissions.  We can't use file
sharing here, as this won't preserve file ownership.

```bash
$ tree -a users
users
├── db
│    ├── .bash_history
│    ├── .config
│    │     └── containers
│    │         └── systemd
│    ├── .local
│    │     └── share
│    │         └── containers
│    │             └── storage
│    │                 └── volumes
│    ├── containers -> /home/db/.config/containers/systemd # (1)
│    └── volumes -> /home/db/.local/share/containers/storage/volumes # (1)
└── webapp
    └── .config

12 directories, 3 files
```

1. These symlinks need to be valid in the **GUEST** system, and they have
   been created in the guest.  That's why they point to `/home/db/...`

In `rocky.yaml` is a provision step which copies all the files over to the
VM:

``` yaml
provision:
  - mode: system
    script: |
      #!/bin/bash
      set -eux -o pipefail
      
      ... other stuff ...

      for user in db webapp; do
        mkdir -p /home/$user
        cp -rT /mnt/project/users/$user /home/$user
        chown -R $user:$user /home/$user
      done
```

### Cockpit

Cockpit is a WEB UI for server management.  The `rocky.yaml` installs and enables it.  The `9090`
port for cockpit is forwarded to the host.  Access cockpit as https://localhost:9090

!!! note

    LIMA does NOT set a password for your user.  If you want to use cockpit,
    set a password, e.g. `sudo passwd <<username>>`.
