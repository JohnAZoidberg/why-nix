---
author: Daniel Schaefer
title: Why Nix
date: August 9, 2018
---

## Agenda

- What is Nix?
  - What does it do with your system?
- What can you use Nix for?
  - source based (but with binary cache)
  - temporary shell
    - packages and environment variables
    - get shell with everything necessary to build package (e.g. with make)
  - Building ISO
  - Building packages
  - Modifying packages
    - supplying a patch
    - changing source entirely
    - changing configure, installPhase or anything else
  - absolute transparency on how something is built
  - portability -  the only thing you need is Nix
  - absolute reproducibility with pinning nixpkgs
  - overriding system packages with overlay
  - always having the newest packages (if not - update yourself)
  - lazy evaluation
  - purely functional - only dependend on inputs
  - on any Linux or MacOS system!
  - easily have multiple versions of a package
  - problem that are eliminated
    - no lock on package database! You can run multiple build or installations
    - no "conflict between packages [go solve it yourself]"
    - no root required for things that don't need it
    - installing packages doesn't pollute the system
  - cons
    - little documentation
    - code is the documentation (code is mostly easy to read)
    - not the biggest community
    - custom dynamic linker interpreter (ld-linux.so) hardcoded => binaries not portable
- NixOS?
  - service.enable = true
