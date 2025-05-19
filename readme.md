# Experimental Setup for podman / quadlet

## Tl;Dr

```bash
$ brew install lima
$ make

                        Infra Podman Quadlet Development
--------------------------------------------------------------------------------
fetch-image                    Image für VM runterladen
create                         Erstellt die VM mit rocky.yml
start                          Startet die VM
stop                           Stoppt die VM
shell                          Eini SHH tuan.
delete                         Stoppt und löscht die VM
mr-proper                      VM löschen, neu anlegen und starten.
--------------------------------------------------------------------------------
$ make mr-proper
💣 Deleting VM ...
FATA[0000] open /Users/seletz/.lima/rocky/lima.yaml: no such file or directory
make: [delete] Error 1 (ignored)
WARN[0000] Ignoring non-existent instance "rocky"
📦 Fetching image ...
...
✅ Image downloaded.
🛠️ Creating VM
INFO[0000] Terminal is not available, proceeding without opening an editor
INFO[0000] Attempting to download the image              arch=aarch64 digest= location=./images/Rocky-9-GenericCloud.latest.aarch64.qcow2
INFO[0000] Downloaded the image from "./images/Rocky-9-GenericCloud.latest.aarch64.qcow2"
INFO[0000] Converting "/Users/seletz/.lima/rocky/basedisk" (qcow2) to a raw disk "/Users/seletz/.lima/rocky/diffdisk"
10.00 GiB / 10.00 GiB [-------------------------------------] 100.00% 8.63 GiB/s
INFO[0001] Expanding to 100GiB
INFO[0001] Run `limactl start rocky` to start the instance.
🚀 Starting VM
INFO[0000] Using the existing instance "rocky"
...
INFO[0091] READY. Run `limactl shell rocky` to open the shell.
$ make shell
[seletz@rocky-quadlet infra-podman-quadlet-test]$ ll
total 12
drwxr-xr-x. 3 seletz seletz   96 May 19 18:44 images
-rw-r--r--. 1 seletz seletz 2122 May 19 18:46 Makefile
-rw-r--r--. 1 seletz seletz  733 May 19 18:47 readme.md
-rw-r--r--. 1 seletz seletz  711 May 19 18:10 rocky.yml
```

## Prerequisites

```bash
$ brew install lima
```

## Initial, first time setup

```bash
$ make create
```

## Start VM and get a shell

Start the VM -- note that the very first time it will run the provision steps:

```bash
$ make start
```

Then get a shell:

```bash
$ make shell
make shell
[seletz@rocky-quadlet infra-podman-quadlet-test]$ ll
total 12
drwxr-xr-x. 3 seletz seletz   96 May 19 18:44 images
-rw-r--r--. 1 seletz seletz 2122 May 19 18:46 Makefile
-rw-r--r--. 1 seletz seletz  733 May 19 18:47 readme.md
-rw-r--r--. 1 seletz seletz  711 May 19 18:10 rocky.yml
[seletz@rocky-quadlet infra-podman-quadlet-test]$ podman -v
podman version 5.2.2
```

Note that:
- There's a user created named the same as your user in MacOS
- Your local `~/.ssh/*.pub` keys are automatically authorised
- Your host file system is automatically mounted read-write into the VM 

## Delete VM and start over

```bash
$ make mr-proper
```
