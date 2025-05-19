# Experimental Setup for podman / quadlet

## Prerequisites

```bash
$ brew install lima
```

## Initial, first time setup

```bash
$ limactl create --tty=false --name=rocky ./rocky.yml
```

## Start VM and get a shell

Start the VM -- note that the very first time it will run the provision steps:

```bash
$ limactl start rocky
```

Then get a shell:

```bash
$ limactl shell rocky
❯ limactl shell rocky
[seletz@rocky-quadlet infra-podman-quadlet-test]$ podman -v
podman version 5.2.2
```

Note that:
- There's a user created named the same as your user in MacOS
- Your local `~/.ssh/*.pub` keys are automatically authorised
- Your host file system is automatically mounted read-write into the VM 

## Delete VM and start over

First `stop` then `delete`:

```bash
$ limactl stop rocky && limactl delete $_
```
