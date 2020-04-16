FROM alpine

RUN apk update \
 && apk add jq curl bash\
 && rm -rf /var/cache/apk/*

CMD ["/entrypoint.sh"]

COPY secret-patch.json /
COPY entrypoint.sh /
