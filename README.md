Fairly simply dynip/dyndns script to update an AWS route53 entry.

Don't forget to inject awscli credentials into it.

VOLUME
    - /home/ted/nuc87_compose/aws-credentials:/.aws/config

```
MYNAME
MYDOMAIN
HEALTHCHECK_URL
HOSTED_ZONE_ID
WHOIS_HOST
```

## docker-compose entry

```
  dynip:
    build: ./dynip/
    restart: always
    volumes:
    - /foo/aws-credentials:/.aws/config
    environment:
    - HEALTHCHECK_URL=https://hc-ping.com/asdf
    - MYNAME=home
    - MYDOMAIN=mydomain.com
    - WHOIS_HOST=NS-987.AWSDNS-123.COM
    - HOSTED_ZONE_ID=Z2IABCDABCD123
```
