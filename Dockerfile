FROM alpine:latest

RUN apk add --no-cache bash curl bind-tools jq aws-cli
WORKDIR /opt/app
COPY dynip.sh /opt/app/dynip.sh

CMD /opt/app/dynip.sh

