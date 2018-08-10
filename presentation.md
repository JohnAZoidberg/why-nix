---
author: Daniel Schaefer
title: Why Nix
date: August 10, 2018
---

## Agenda

> - Target audience
> - What is Nix?
> - Features of Nix
> - What can you use Nix for?
> - Why is Nix special?
> - Problem that Nix eliminates
> - Problems with Nix
> - NixOS?

---

## Target audience

> - Busy, pragmatic
> - Doesn't care about "functional" and "lazyness" per se
> - Doesn't want to break compatibility with traditional tools

---

## What is Nix?

> - A package manager
> - A lazy, pure functional, dynamically typed language

---

### What does it do with your system?

On installation:

> - Creates `/nix/{store,var}`
> - Creates build users
> - Creates `nix-daemon.service`

---

### What does it do with your system?

During runtime:

> - `/nix/{store,var}`
> - `$PATH`
> - Other environment variables
> - Symlinks in ~/.nix-profile or /run/current-system
> - Symlinks to `/nix/store/xxxxxx` in current directory named `result`

---

## Features of Nix

> - Builds packages but doesn't replace traditional build tools (e.g. make)
> - Source based (but with binary cache)
> - Always having the newest packages (if not - update yourself)
> - Atomic installation, upgrades and rollback
> - Lazy evaluation
> - Purely functional - only dependend on inputs
> - Overriding system packages with overlay

---

### Builds packages but doesn't replace traditional build tools (e.g. make)

```
{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  name = "hello-2.10";

  src = fetchurl {
    url = "mirror://gnu/hello/${name}.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89n";
  };
}
```

---

`stdenv.mkDerivation` calls `./configure` and `make` and `make install`

---

### Source based (but with binary cache)

```
  src = fetchurl {
    url = "mirror://gnu/hello/${name}.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89n";
  };
```

---

### Always having the newest packages (if not - update yourself)

https://github.com/nixos/nixpkgs has ~150k commits and 1700+ contributors

> - Disclmainer: Including Leon and me

---

### Updating a package

```
  name = "hello-${version}";
  version = "2.10";

  src = fetchurl {
    url = "mirror://gnu/hello/${name}.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89n";
  };
```

> - Update version
> - Update hash of tarball

---

### Atomic installation, upgrades and rollback

> - Installations cannot fail
> - Installations don't clutter your system
> - Uninstalling == not having the package on your $PATH
> - `nix-collect-garbage` if running low on space

---

### Overriding system packages with overlay

> - Replace openssl in every package with libressl? easy
> - Replace openssl in some packages with libressl? easy
> - Replace libc -> everything get's rebuilt

---

## What can you use Nix for?

> - Installing a package
> - Temporary shell
> - Building a package

---

### Installing a package

```
$ nix-env -i chromium
$ chromium
```

---

### Temporary shell

> - Packages and environment variables
> - Shell with everything necessary to build package

---

### Packages and environment variables

Image you didn't want PHP installed but had to demonstrate it's flaws:

```
$ nix-shell -p php
$ php -a
Interactive shell

php > var_dump(1 == "1el0");
bool(true)
php > var_dump(1 == "1e10");
bool(false)
php > exit
$ man php
$ exit
$ php
php: command not found
```

---

### Shell with language packages

Python is better than PHP but you need packages for many things

```
nix-shell -p python36Packages.matplotlib python36Packages.ipython --command ipython
```

---

### Shell with everything necessary to build package

(e.g. make gcc dependencies)

```
$ git clone https://github.com/qemu/qemu
$ cd qemu
$ nix-shell '<nixpkgs>' -A qemu
$ ./configure
$ make
$ ./x86_64-softmmu/qemu-system-x86_64
```

---

### Building ISO

iso.nix

```
{config, pkgs, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];
}
```

```
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
```

---

### Custom packages in live iso?

```
{config, pkgs, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];
  environment.systemPackages = [
    cowsay vim tmux git wget
  ];
}
```

---

### Custom services and more in iso

- Enable services like sshd (with allowed pub keys)
- Create user
- Set static IP address

But! This is about Nix not NixOS

---

### Building packages

> - Regular packages (Gentoo style)
> - Cross compiling
> - While developing

---

### Regular packages (Gentoo style)

```
nix-build '<nixpkgs>' -A  hello --option build-use-substitutes false
```

---

### Cross Compiling

```
nix-build '<nixpkgs>' --arg crossSystem '(import <nixpkgs> {}).lib.systems.examples.aarch64-multiplatform' -A hello
```
---

### While developing

```
$ cat default.nix
with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "why-nix-presentation";
  src = ./.;
  buildInputs = with pkgs; [ pandoc ];
}
$ nix-build
$ firefox result
```

> - `nix-shell --command make`
> - to upstream change src to git

---

### Modifying packages

> - Supplying a patch
> - Changing source entirely
> - Changing configure, installPhase or anything else

---

### - Supplying a patch

Add single line to `$package.nix`:

```
patches = [ ./covfefe.diff ];
```

---

### Changing source entirely

For developing use current directory:

```
src = ./.;
```

---

### Changing source entirely

Use own fork:

```
src = fetchFromGitHub {
  owner = "me";
  repo = "fork";
  rev = "v${version}";
  sha256 = "1gd0bq5x49sjm83r2wivjf03dxvhdli6cvwb9b853wwcvy4";
};
```

---

### Changing configure, installPhase or anything else

```
configurePhase = ''
   ./weird-configure
'';
```

---

### Absolute transparency on how something is built

Just look at the package in $nixpkgs

---

### Portability -  the only thing you need is Nix

```
$ nix-shell -p cowsay --command "cowsay Nix works!"
 ____________
< Nix works! >
 ------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

---

### Absolute reproducibility with pinning nixpkgs

```
let
  fetchNixpkgs = { rev, sha256 } : builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256;
  };
in
  import (fetchNixpkgs {
    rev = "5141f28405e5d31f21c10869dfc86ff340053787";
    sha256 = "0q91kfxg950g1nr71ifxhb4gfn3vfs4szh2yn7z8s2xri4l36p5m";
  }) { config = {}; }
```

---

## Why is Nix special?

> - On any Linux or MacOS system!
> - Easily have multiple versions of a package
> - Immutable package store
> - Isolated build environment

---

### Easily have multiple versions of a package

```
$ nix-shell -p openssl_1_0_2 --command "openssl version"
OpenSSL 1.0.2o  27 Mar 2018

$ nix-shell -p openssl_1_1_0 --command "openssl version"
OpenSSL 1.1.0h  27 Mar 2018
```

---

### Immutable package store

Nothing can screw with installed packages

---

### Isolated build environment

Package is dependent on:

> - Inputs
> - Nixpkgs

---

## Problem that Nix eliminates

> - No lock on package database! You can run multiple builds or installations
> - No "conflict between packages [go solve it yourself]"
> - No root required
> - Installing packages doesn't pollute the system

---

## Problems with Nix

> - Little documentation
> - Code is the documentation (code is mostly easy to read)
> - Not the biggest community
> - Custom dynamic linker interpreter (ld-linux.so) hardcoded => binaries not portable

---

### Summary

> - Clean system
> - Reproducible builds for all languages
> - Quick shell with programs and libraries
> - Transparency and modifiability of packages

---

## NixOS?

Configure entire system declaratively

```
networking.interfaces.eth0.ipv4. = [{
  address = "192.168.192.1";
  prefixLength = 24;
}];
time.timeZone = "Europe/London";
services.openssh.enable = true;
boot.kernelPackages = pkgs.linuxPackages_4_17;
users.extraUsers.elprofesor.isNormalUser = true;
boot.loader = {
  systemd-boot.enable = true;
  efi.canTouchEfiVariables = false;
};
boot.kernelModules = [ "kvm-intel" ];
```
