ARG FEDORA_MAJOR_VERSION=rawhide
ARG BASE_CONTAINER_URL=ghcr.io/ab-configs/silverblue-main

FROM ${BASE_CONTAINER_URL}:${FEDORA_MAJOR_VERSION}
ARG RECIPE

# copy over configuration files
COPY etc /etc
# COPY usr /usr
RUN rpm-ostree install sssd-idp sssd-passkey sssd-common sssd-krb5 libsss_certmap \
    libsss_idmap libsss_sudo sssd-client libsss_nss_idmap \
    sssd-krb5-common sssd-nfs-idmap sssd-proxy sssd-ad \
    sssd-common-pac sssd-ldap sssd sssd-ipa sssd-kcm libipa_hbac freeipa-client 

COPY ${RECIPE} /tmp/ublue-recipe.yml

# yq used in build.sh and the setup-flatpaks recipe to read the recipe.yml
# copied from the official container image as it's not avaible as an rpm
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

# copy and run the build script
COPY build.sh /tmp/build.sh
RUN chmod +x /tmp/build.sh && /tmp/build.sh

# clean up and finalize container build
RUN rm -rf \
        /tmp/* \
        /var/* && \
    ostree container commit
