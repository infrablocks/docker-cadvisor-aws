FROM infrablocks/alpine-aws-s3-config:0.20.0

ENV GLIBC_VERSION "2.28-r0"
ENV CADVISOR_VERSION "0.36.0"
ENV CADVISOR_CHECKSUM "7bbc3e229ea41940efe25c37a7c0f6010a4d7e47bee98e0f8e0359a4690b39be"

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

RUN mkdir -p /opt/cadvisor/bin && \
    curl -L "https://github.com/google/cadvisor/releases/download/v${CADVISOR_VERSION}/cadvisor" -o "/opt/cadvisor/bin/cadvisor" && \
    cd /opt/cadvisor/bin; echo "${CADVISOR_CHECKSUM} *cadvisor" | sha256sum -c; cd - && \
    chmod +x /opt/cadvisor/bin/cadvisor

EXPOSE 8080

COPY start.sh /opt/cadvisor/bin/start.sh

RUN chmod +x /opt/cadvisor/bin/start.sh

ENV STARTUP_SCRIPT_PATH=/opt/cadvisor/bin/start.sh
