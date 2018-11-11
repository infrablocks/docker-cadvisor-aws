FROM infrablocks/alpine-aws-s3-config:0.6.0

# Inspired by google/cadvisor

ENV GLIBC_VERSION "2.28-r0"
ENV CADVISOR_VERSION "0.31.0"
ENV CADVISOR_CHECKSUM "195faa8d3953b4534bb0f050738ca3f7d6b1a646a1663e5660c9848967ff678f"

RUN apk --no-cache add ca-certificates wget device-mapper findutils && \
    apk --no-cache add zfs --repository http://dl-3.alpinelinux.org/alpine/edge/main/ && \
    apk --no-cache add thin-provisioning-tools --repository http://dl-3.alpinelinux.org/alpine/edge/main/ && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm glibc-${GLIBC_VERSION}.apk && \
    rm glibc-bin-${GLIBC_VERSION}.apk && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /cadvisor/bin && \
    curl -L "https://github.com/google/cadvisor/releases/download/v${CADVISOR_VERSION}/cadvisor" -o "/cadvisor/bin/cadvisor" && \
    cd /cadvisor/bin; echo "${CADVISOR_CHECKSUM} *cadvisor" | sha256sum -c; cd -

EXPOSE 8080

COPY docker-entrypoint.sh /cadvisor/bin/docker-entrypoint.sh

ENV STARTUP_SCRIPT_PATH=/cadvisor/bin/docker-entrypoint.sh
