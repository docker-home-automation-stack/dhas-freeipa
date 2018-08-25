FROM freeipa/freeipa-server

COPY ./src/entry.sh /entry.sh

ENTRYPOINT [ "sh", "-c", "/entry.sh /usr/local/sbin/init" ]
