ARG BASE=quay.io/fedora/fedora-bootc:42
FROM $BASE

ENV LANG C.UTF-8
ARG TYPE=nightly

# disable deltas and weak deps
RUN set -x && \
    echo -e "deltarpm=0" >> /etc/dnf/dnf.conf && \
    echo -e "install_weak_deps=0" >> /etc/dnf/dnf.conf

# enable dnf5
RUN set -x && \
    dnf -y upgrade bootc; \
    dnf -y install dnf5 dnf5-plugins; \
    dnf5 -y copr enable rpmsoftwaremanagement/test-utils; \
    dnf5 -y copr enable rpmsoftwaremanagement/dnf-nightly; \
    dnf5 -y distro-sync --from-repo copr:copr.fedorainfracloud.org:rpmsoftwaremanagement:dnf-nightly '*'

ARG CACHEBUST=1
RUN echo "CACHEBUST=$CACHEBUST" && dnf5 -y distro-sync --from-repo copr:copr.fedorainfracloud.org:rpmsoftwaremanagement:dnf-nightly '*'

# install local RPMs if available
COPY ./rpms/ /opt/ci/rpms/
RUN set -x && \
    if [ -n "$(find /opt/ci/rpms/ -maxdepth 1 -name '*.rpm' -print -quit)" ]; then \
        printf '[local]\nname=local\nbaseurl=file:///opt/ci/rpms/\nenabled=1\ngpgcheck=0\npriority=1\n' \
            > /etc/yum.repos.d/local.repo && \
        dnf5 -y distro-sync --from-repo=local --setopt=allow_vendor_change=true; \
    fi

RUN dnf5 install -y neovim zsh buildah dnf5-plugin-manifest dnf-bootc rpm-plugin-reflink rpm-build --setopt=allow_vendor_change=true

# add user evan with uid 1000, member of wheel
RUN useradd -u 1000 -G wheel -s /bin/zsh evan

# mount point for virtiofs-passed home directory
RUN mkdir -p /home/evan && chown evan:evan /home/evan && \
    echo 'evan /home/evan virtiofs defaults 0 0' >> /etc/fstab

# passwordless sudo for wheel
RUN sed -i 's/^Defaults\s*always_set_home/# &/' /etc/sudoers && \
    echo -e '\n%wheel\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers

# sshd: listen on all interfaces, share root's authorized_keys with all users
RUN printf 'ListenAddress 0.0.0.0\nPort 22\nAuthorizedKeysFile .ssh/authorized_keys /root/.ssh/authorized_keys\n' \
    > /etc/ssh/sshd_config.d/99-bcvk.conf
