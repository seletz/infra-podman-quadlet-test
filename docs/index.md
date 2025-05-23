---
title: Introduction
---
# Introduction

In this repository I document my experiments with [podman](https://docs.podman.io/en/latest/index.html) as
an alternative to [docker]().

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




