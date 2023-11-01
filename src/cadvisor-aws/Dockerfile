FROM gcr.io/cadvisor/cadvisor:v0.47.2 as cadvisor

FROM infrablocks/alpine-aws-s3-config:0.23.0

RUN apk --no-cache add libc6-compat device-mapper findutils ndctl zfs && \
    apk --no-cache add thin-provisioning-tools --repository http://dl-3.alpinelinux.org/alpine/edge/main/ && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm -rf /var/cache/apk/*

COPY --from=cadvisor /usr/local/lib/libpfm.so* /usr/local/lib/
COPY --from=cadvisor /usr/local/lib/libipmctl.so* /usr/local/lib/
COPY --from=cadvisor /usr/bin/cadvisor /opt/cadvisor/bin/cadvisor

EXPOSE 8080

COPY start.sh /opt/cadvisor/bin/start.sh

RUN chmod +x /opt/cadvisor/bin/start.sh

ENV STARTUP_SCRIPT_PATH=/opt/cadvisor/bin/start.sh
