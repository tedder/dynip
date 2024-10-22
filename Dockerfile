FROM alpine:3.20
# v3.20 fails with datetime issues in awscli

RUN apk add --no-cache bash curl bind-tools jq aws-cli
WORKDIR /opt/app
USER nobody
COPY dynip.sh /opt/app/dynip.sh

CMD /opt/app/dynip.sh

