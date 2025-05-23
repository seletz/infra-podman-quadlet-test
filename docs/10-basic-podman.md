---
title: Fist Steps with Podman
subtitle: Steps needed to create a first Caddy container
---
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

!!! note

    For containers running as non-root users, this must be
    a timer service needs to be added for each user.

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

## The first Container

!!! note

    The following is executed as the `webapp` user.
    Use `sudo machinectle shell --uid webapp`

For ease of use, we store files which define a container in a subdirectory.  Here,
we want a simple [Caddy]() container, so we crate a `caddy/` directory and
create these files:

- A `caddy.container` which defines the container
- A `caddy_data.volume` which defines the data volume referenced in the container


```Systemd title="caddy/caddy.container"
---8<---
users/webapp/caddy/caddy.container
---8<---
```

```Systemd title="caddy/caddy_data.volume"
---8<---
users/webapp/caddy/caddy_data.volume
---8<---
```

These files *look* like `systemd unit` files but they really aren't.  They're called *quadlets*
after the project with the same name which is now part of standard podman.  These *quadlet* files
are used by some magic to create real systemd unit files.

Why would we want this?  Well, now that we have these, we can create some symbolic links to
a local directory and have `systemd` **automatically** pick them up and generate services:

1. Create links

    ```bash
    $ cd .config/containers/systemd
    $ ln -s ~/caddy/caddy* .
    ```

2. Have systemd pick them up:

    ```bash hl_lines="4"
    $ systemctl --user daemon-reload
    $ systemctl --all --user list-units --type=service
      UNIT                           LOAD   ACTIVE   SUB     DESCRIPTION
      caddy.service                  loaded active   dead    Caddy
      dbus-broker.service            loaded active   running D-Bus User Message Bus
      grub-boot-success.service      loaded inactive dead    Mark boot as successful
      podman-auto-update.service     loaded inactive dead    Podman auto-update service
      systemd-tmpfiles-clean.service loaded inactive dead    Cleanup of User's Temporary Files and Directories
      systemd-tmpfiles-setup.service loaded active   exited  Create User's Volatile Files and Directories

    LOAD   = Reflects whether the unit definition was properly loaded.
    ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
    SUB    = The low-level unit activation state, values depend on unit type.
    6 loaded units listed.
    To show all installed unit files use 'systemctl list-unit-files'.
    ```

3. Start the service:

    ```bash
    $ systemctl --user start caddy
    $ systemctl --user status caddy.service
    ● caddy.service - Caddy
         Loaded: loaded (/home/webapp/.config/containers/systemd/caddy.container; generated)
         Active: active (running) since Fri 2025-05-23 16:27:40 CEST; 19s ago
       Main PID: 43389 (conmon)
          Tasks: 11 (limit: 23019)
         Memory: 27.4M
            CPU: 106ms
         CGroup: /user.slice/user-1001.slice/user@1001.service/app.slice/caddy.service
                 ├─libpod-payload-56fd3fe36f82708162306ab87b69a0fca3a0eabe2d17af78abbbc8a1ecc2d774
                 │ └─43391 caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
                 └─runtime
                   ├─43386 /usr/bin/pasta --config-net -t 8000-8000:80-80 -t 8443-8443:443-443 --dns-forward 169.254.0.1 -u none -T none -U none --no-map-gw --quiet --netns /run/user/1001/net>
                   └─43389 /usr/bin/conmon --api-version 1 -c 56fd3fe36f82708162306ab87b69a0fca3a0eabe2d17af78abbbc8a1ecc2d774 -u 56fd3fe36f82708162306ab87b69a0fca3a0eabe2d17af78abbbc8a1ecc2d>

    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"info","ts":1748010460.752824,"logger":"admin","msg":"admin endpoint started","address":"localhost:2019","enforce_origin":fals>
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"warn","ts":1748010460.7528663,"logger":"http.auto_https","msg":"server is listening only on the HTTP port, so no automatic HT>
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"info","ts":1748010460.7529428,"logger":"tls.cache.maintenance","msg":"started background certificate maintenance","cache":"0x>
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"warn","ts":1748010460.7529655,"logger":"http","msg":"HTTP/2 skipped because it requires TLS","network":"tcp","addr":":80"}
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"warn","ts":1748010460.7529674,"logger":"http","msg":"HTTP/3 skipped because it requires TLS","network":"tcp","addr":":80"}
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"info","ts":1748010460.7529685,"logger":"http.log","msg":"server running","name":"srv0","protocols":["h1","h2","h3"]}
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"info","ts":1748010460.7530577,"msg":"autosaved config (load with --resume flag)","file":"/config/caddy/autosave.json"}
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"info","ts":1748010460.7530744,"msg":"serving initial configuration"}
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"info","ts":1748010460.7535074,"logger":"tls","msg":"storage cleaning happened too recently; skipping for now","storage":"File>
    May 23 16:27:40 rocky-quadlet systemd-caddy[43389]: {"level":"info","ts":1748010460.7535334,"logger":"tls","msg":"finished cleaning storage units"}
    ```

4. Verify podman is showing the caddy container:

    ```bash
    $ podman ps
    CONTAINER ID  IMAGE                           COMMAND               CREATED             STATUS             PORTS                                                                   NAMES
    56fd3fe36f82  quay.io/zyclonite/caddy:latest  run --config /etc...  About a minute ago  Up About a minute  0.0.0.0:8000->80/tcp, 0.0.0.0:8443->443/tcp, 80/tcp, 443/tcp, 2019/tcp  systemd-caddy
    ```

5. Verify Caddy is serving requests:

    ```bash
    $ curl localhost:8000
    Hello from Caddy!
    ```

