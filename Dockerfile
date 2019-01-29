FROM fedora:29

RUN dnf install -y ddclient && \
    dnf clean all

RUN mkdir -p /ddclient/config && \
    chown -R ddclient:ddclient /ddclient 

USER ddclient

RUN cp /etc/ddclient.conf /ddclient/config/ddclient.conf

ENTRYPOINT ["/usr/sbin/ddclient"]
CMD ["-daemon=0","-foreground","-file=/ddclient/config/ddclient.conf"]
