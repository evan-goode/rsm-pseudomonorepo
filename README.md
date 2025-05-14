# rpm-software-management pseudomonorepo (rsmpmr)

> [!WARNING]
> These are sloppy right now and might not be super convenient for others to use. But they work for me!

This is a set of build scripts for rpm-software-management projects using [Daniel J. Bernstein's redo build system](http://cr.yp.to/redo.html) (specifically, the [apenwarr/redo](https://redo.readthedocs.io/en/latest) implementation). It sort of lets me pretend that rpm-software-management is a monorepo, hence the name.

Imagine you want to make a change in dnf that depends on another change in libdnf, then write and run a test for that change. With rsmpmr, you simply check out the correct commits in your `dnf`, `libdnf`, and `ci-dnf-stack` repositories, set `BUILD_FROM_SOURCE="libdnf dnf"`, and run `redo build/dnf4.test`. No need for the manual headache of running the libdnf rpmbuild, installing the right libdnf RPMs, building the dnf RPMs, copying the right RPMs to `ci-dnf-stack/rpms`, building the test container, realizing you built `libdnf` for the wrong Fedora version, and starting over. And everything builds cleanly under Mock to avoid contamination from other changes on your development machine.

Some things (building images, creating libvirt VMs, running tests with TMT) work much more smoothly with passwordless sudo. I do all my development work in a VM and this is fine with me, but with some modifications it might be possible to do some of these rootless.

## Setup

1. Install [redo](https://github.com/apenwarr/redo). I don't know of a Fedora package, so you can install it from source or use `redo-apenwarr` from Nixpkgs.

2. For complete functionality, install the following:

    ```
    sudo dnf install -y podman tmt+all mock @virtualization
    ```

3.

    ```
    git clone https://github.com/evan-goode/rsm-pseudomonorepo rsm
    cd rsm
    ```

4. Create symlinks to your checkouts of the rpm-software-management repositories, for example:

    ```
    ln -s ~/git/dnf .
    ln -s ~/git/createrepo_c .
    ln -s ~/git/dnf5 .
    ln -s ~/git/libdnf .
    ln -s ~/git/libsolv .
    ln -s ~/git/dnf-plugins-core .
    ```

5. To build packages from Fedora or CentOS dist-git, the scripts expect dist-git repositories arranged under `centpkg/` and `fedpkg/`, for example:

    ```
    $ tree ~/git/centpkg -L 1
    /home/evan/git/centpkg
    ├── dnf
    └── libdnf
    $ pwd
    /home/evan/git/rsm
    $ ln -s ~/git/centpkg .
    ```

## Usage

Edit `config.sh` to your liking to configure your build. Make sure all source repositories have clean working directories or the build will error.

All output files will be under `build/`. Outputting multiple RPMs is a bit weird since djb redo doesn't support directory outputs, so we store the RPMs under e.g. `build/dnf.rpms` and create `build/dnf.rpmlist` which contains a list of relative paths such as `dnf.rpms/dnf-4.24.0-1.git.9735.2e1799f.el10.noarch.rpm`.

### Build RPMs

```
redo build/dnf.rpmlist

# A list of `build/`-relative paths to resulting RPMs will be in `build/dnf.rpmlist`. For example:
cd build; xargs sudo dnf install -y < dnf.rpmlist
```

### Run ci-dnf-stack tests

```
redo build/dnf4.test # for dnf-4-stack branch
# or 
redo build/dnf5.test # for main branch
```

### Start a bootc VM (WIP)

Clone https://github.com/evan-goode/bootc-test-scripts to `bootc-test-scripts`, then

```
redo build/bootc.virt-install
```

### Run bootc ci-dnf-stack tests via TMT

```
redo build/dnf4.test
```
