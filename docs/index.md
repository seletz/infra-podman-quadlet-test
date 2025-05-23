---
title: Introduction
---
# Introduction

In this repository I document my experiments with [podman](https://docs.podman.io/en/latest/index.html) as
an alternative to [docker](https://www.docker.com).

## Rationale

At $work we use *docker compose* for pretty much everything.  This means in effect that a container image is
the *build artefact* for software we deploy.

Now docker has some drawbacks:

- needs a daemon to run
- Integration in **systemd** is lacking
- It's non-free software

## Goals

These are my goals:

- Explore how **podman** behaves wrt *systemd* units
- Explore how we can leverage rootless podman containers -- having each service run as a dedicated user
- Explore how overlays and templates in systemd units work
- Explore pods
- Explore how to convert a `docker-compose.yaml` into a pod
- Explore how networking behaves in rootless mode

## Reference


- [Viertelwissen: Einführung in Podman](https://viertelwissen.de/einfuehrung-in-podman/)
- [Viertelwissen: Podman Quadlets](https://viertelwissen.de/podman-quadlets/)
- [Viertelwissen: Podman Pods mit Authentik](https://viertelwissen.de/podman-pods-mit-authentik/)

Networking, firewalls:

- [Viertelwissen: Firewalld verstehen und benutzen](https://viertelwissen.de/firewalld-verstehen-und-benutzen-firewall-cmd/)
- [RHEL 7: Using Firewalls](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-using_firewalls)
- [RHEL 9: Firewalls and Packet Filters](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_firewalls_and_packet_filters/using-and-configuring-firewalld_firewall-packet-filters)

