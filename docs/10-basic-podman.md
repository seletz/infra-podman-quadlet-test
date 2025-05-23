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


## Podman Container Autoupdate

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