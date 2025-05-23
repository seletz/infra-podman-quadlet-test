# Basic Podman

## Verison

The podman version for reference:

```bash
$ podman version
Client:       Podman Engine
Version:      5.2.2
API Version:  5.2.2
Go Version:   go1.23.2 (Red Hat 1.23.2-1.el9)
Built:        Tue May  6 18:29:02 2025
OS/Arch:      linux/arm64
```

## Online Docs


- [Einführung in Podman](https://viertelwissen.de/einfuehrung-in-podman/)


## Preparation

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

### Firewall

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