---
author: Daniel Schaefer
title: Why Nix
date: August 9, 2018
---

## Agenda

- What is Nix?
- Features of Nix
- What can you use Nix for?
- Why is Nix special?
- Problem that Nix solves
- Problems with Nix
- NixOS?

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
> - other environment variables
> - TODO CHECK symlinks in other places than `/nix/store`
> - symlink to `/nix/store/xxxxxx` in current directory named `result`

---

## Features of Nix

---

### Builds packages but doesn't replace traditional build tools (e.g. make)

```
{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  name = "hello-2.10";

  src = fetchurl {
    url = "mirror://gnu/hello/${name}.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
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
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };
```

---

### Always having the newest packages (if not - update yourself)

https://github.com/nixos/nixpkgs has ~150k commits and 1700+ contributors

dfklsjdf: Including me

---

### Updating a package

```
  name = "hello-${version}";
  version = "2.10";

  src = fetchurl {
    url = "mirror://gnu/hello/${name}.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };
```

- update version
- update hash of tarball

---

### Lazy evaluation

TODO

---

### Purely functional - only dependend on inputs

TODO

---

### Overriding system packages with overlay

---

## What can you use Nix for?

---

### Temporary shell

---

### Packages and environment variables

Image you didn't want PHP installed but had to demonstrate it's flaws:

```
$ nix-shell -p php
$ php -a
Interactive shell

php > var_dump(1 == "1e");
bool(true)
php > var_dump(1 == "1e10");
bool(false)
php > exit
$ exit
$ php
php: command not found
```

---

### Get shell with everything necessary to build package (e.g. with make)

```
$ git clone https://github.com/qemu/qemu
$ cd qemu
$ nix-shell '<nixpkgs>' -A qemu
./configure
make
```

TODO: better example

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
    firefox
  ];
}
```

---

### Custom services and more in iso

- enable services like sshd (with allowed pub keys)
- create user
- set static IP address

But! This is about Nix not NixOS

---

### Building packages

---

### Modifying packages

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
  sha256 = "1gd0bq5x49sjm83r2wivjf03dxvhdli6cvwb9b853wwcvy4inmmh";
};
```

---

### Changing configure, installPhase or anything else

```
configurePhase = ''
   ./weird-configure
'';
```

TODO: more

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

---

## Why is Nix special?

> - On any Linux or MacOS system!
> - Easily have multiple versions of a package

---

## Problem that Nix solves

> - No lock on package database! You can run multiple build or installations
> - No "conflict between packages [go solve it yourself]"
> - No root required for things that don't need it
> - Installing packages doesn't pollute the system

---

## Problems with Nix

> - Little documentation
> - Code is the documentation (code is mostly easy to read)
> - Not the biggest community
> - Custom dynamic linker interpreter (ld-linux.so) hardcoded => binaries not portable

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
