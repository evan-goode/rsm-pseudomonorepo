# AGENTS.md

This repository has scripts for building and testing DNF and related projects. In the top-level directory, there are symlinks to checkouts of dnf, dnf5, dnf-plugins-core, ci-dnf-stack, libsolv, etc. Configure the system by modifying config.sh.

General process:

1. For each upstream repository containing code you want to build and/or test:
    1. `cd $repository`
    2. `git checkout` the correct branch
        - To test on CentOS $X Stream, checkout the rhel-$X.$Y (or rhel-$X.$Y.0 in some cases) branch, where $y is the current RHEL minor release. 
    3. Important: make sure the working directory is clean! The build system will not work unless you commit your changes, even with temporary messages. Untracked files are OK.
2. For each Fedora or CentOS Stream dist-git repository to test:
    1. `cd fedpkg/$repository` or `cd centpkg/$repository`
    2. `git checkout` the correct branch
    3. Make sure the working directory is clean. Untracked files are OK.
3. If running integration tests, `cd ci-dnf-stack` and check out the desired branch.
4. Edit config.sh
    1. List packages to build from source in `BUILD_FROM_SOURCE`.
    2. List packages to build from Fedora dist-git or CentOS Stream dist-git in `BUILD_FROM_FEDPKG` or `BUILD_FROM_CENTPKG`, respectively.
    3. Select the correct `MOCK_CHROOT`
    4. If running tests, select the `CI_BASE_IMAGE` that matches the `MOCK_CHROOT`
    5. If you want to test the latest development version of dependencies, use `CI_CONTAINER_TYPE=nightly`. If you want to test for a downstream release (common when building from `rhel-X.Y` branches, and you want to test with downstream-available dependencies, set `CI_CONTAINER_TYPE=distro`. With `nightly`, packages from the dnf-nightly Copr repository are used to build the test container.

To build a project (first building its recursive dependencies, if they are listed in `$BUILD_FROM_{SOURCE,FEDPKG,CENTPKG}`), run `redo build/$repository.rpmlist`. 

To run ci-dnf-stack integration tests, run `redo build/dnf5.test` or `redo build/dnf4.test`.

Note: running all of the tests takes a long time. To start, it's best to run just the tests that you're interested in. To do so, build the test container first: `redo build/dnf4.image` or `redo build/dnf5.image`. Then, `cd ci-dnf-stack` and run `sudo ./container-test --container=localhost/dnf-bot/dnf-testing -d run <path to feature file relative to dnf-behave-tests/dnf/>`.
