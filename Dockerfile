FROM alpine:3.20 AS build

RUN apk add --no-cache perl curl bash git autoconf automake make gettext perl-utils

# Pinned commit on main, after v4.0.0, which includes the Hetzner
# apex-domain fix (ddclient/ddclient#899) needed for apex-domain zones.
# No tagged release includes this fix yet; update this SHA to a tagged
# release once one is cut.
ARG DDCLIENT_COMMIT=f4dcf6fc8e4bf47d1041d75dd6fcd328132e6141

RUN git clone https://github.com/ddclient/ddclient.git /src && \
    cd /src && git checkout ${DDCLIENT_COMMIT} && \
    ./autogen && \
    ./configure --sysconfdir=/etc --prefix=/usr/local && \
    make && \
    make install DESTDIR=/out

FROM alpine:3.20

RUN apk add --no-cache perl perl-io-socket-ssl perl-digest-sha1 curl net-tools && \
    addgroup -g 1000 ddclient && \
    adduser -D -u 1000 -G ddclient ddclient && \
    mkdir -p /ddclient/config && \
    chown -R ddclient:ddclient /ddclient

COPY --from=build /out/usr/local /usr/local
RUN mkdir -p /usr/local/var/cache/ddclient /usr/local/var/run && \
    chown -R ddclient:ddclient /usr/local/var

USER ddclient

ENTRYPOINT ["/usr/local/bin/ddclient"]
CMD ["-daemon=0", "-foreground", "-file=/ddclient/config/ddclient.conf"]
