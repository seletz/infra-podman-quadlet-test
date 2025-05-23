# Preparation

### Using machinectl to change shells

Apparently, when doing the usual `sudo su - foo` dance, we cannot use `systemctl --user` commands.  To
get a shell for a different user, now needs to use `machinectl` from the `systemd-container` package:

```bash
$ sudo machinectl shell --uid webapp
```

> [!Note]
> This **only** works for users which have a valid login
> shell.

Changing shell:

```bash
$ sudo usermod -s /bin/bash webapp
$ sudo usermod -s /bin/bash db
```

### Podman Container Autoupdate

[podman-auto-update](https://docs.podman.io/en/v5.2.2/markdown/podman-auto-update.1.html)

Update containers **now**:

```bash
$ sudo podman auto-update
```

Add a timer to do this automatically:

```bash
$ sudo systemctl enable podman-auto-update.timer --now
```

> [!Note]
> For containers running as non-root users, this must be
> a timer service needs to be added for each user.

```bash
$ sudo machinectl shell --uid webapp
Connected to the local host. Press ^] three times within 1s to exit session.
$ systemctl --user enable podman-auto-update.timer --now
Created symlink /home/webapp/.config/systemd/user/timers.target.wants/podman-auto-update.timer → /usr/lib/systemd/user/podman-auto-update.timer.
$ exit
logout
Connection to the local host terminated.
$ sudo machinectl shell --uid db
Connected to the local host. Press ^] three times within 1s to exit session.
$ systemctl --user enable podman-auto-update.timer --now
Created symlink /home/db/.config/systemd/user/timers.target.wants/podman-auto-update.timer → /usr/lib/systemd/user/podman-auto-update.timer.
$ exit
logout
Connection to the local host terminated.
```

This creates `systemd` unit files in `.config` and `.local`:

```bash
[db@rocky-quadlet ~]$ tree .config/
.config/
└── systemd
    └── user
        └── timers.target.wants
            └── podman-auto-update.timer -> /usr/lib/systemd/user/podman-auto-update.timer

3 directories, 1 file
[db@rocky-quadlet ~]$ cat .config/systemd/user/timers.target.wants/podman-auto-update.timer
[Unit]
Description=Podman auto-update timer

[Timer]
OnCalendar=daily
RandomizedDelaySec=900
Persistent=true

[Install]
WantedBy=timers.target
```

### Firewall and Networking

> [!Warning]
> Lima VMS **do not create any bridge network by default**.  One's supposed to
> use **port forwarding**.

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

To be preserve the contzents of the `webapp` and `db` user homes, these directories are
mounted from the host.

```yaml
mounts:
  - location: "~"
    writable: true
  - location: "/Users/seletz/develop/research/lima/infra-podman-quadlet-test/users/db"
    mountPoint: "/home/db"
    writable: true
  - location: "/Users/seletz/develop/research/lima/infra-podman-quadlet-test/users/webapp"
    mountPoint: "/home/webapp"
    writable: true
```


> [!Note]
> Unfortunately `mounts[].location` is not allowed to be a relative path.  Also,
> it seems `--set` in `create` is able to hanle only **one** expression.  Therefore,
> I left the `location` absolute, which sucks badly.
>
> I **could** do some `sed` or `yq` shenanigans in the `Makefile`, but I want to keep
> focused.

```bash
$ tree -a users
users
├── db
│   ├── .bash_history
│   ├── .config
│   │   └── containers
│   │       └── systemd
│   ├── .local
│   │   └── share
│   │       └── containers
│   │           └── storage
│   │               └── volumes
│   ├── containers -> /home/db/.config/containers/systemd
│   └── volumes -> /home/db/.local/share/containers/storage/volumes
└── webapp
    └── .config

12 directories, 3 files
```

> [!Note]
> The symlinks above need to be valid in the **GUEST** system, and they have
> been created in the guest.  That's why they point to `/home/db/...`

### Cockpit

Cockpit is a WEB UI for server management.  The `rocky.yaml` installs and enables it.  The `9090`
port for cockpit is forwarded to the host.  Access cockpit as https://localhost:9090

> [!Note]
> LIMA does NOT set a password for your user.  If you want to use cockpit,
> set a password, e.g. `sudo passwd <<username>>`.
