FROM fedora:24

RUN dnf install jq certbot -y && dnf clean all
RUN mkdir /etc/letsencrypt

CMD ["/entrypoint.sh"]

COPY secret-patch.json /
COPY entrypoint.sh /
