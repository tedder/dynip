Simple dynip/dyndns script to update an AWS Route 53 entry.

Don't forget to inject awscli credentials into it.

## env vars

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `MYNAME` | no | Hostname to update (default: `home`) | `home` |
| `MYDOMAIN` | yes | Domain name | `mydomain.com` |
| `HOSTED_ZONE_ID` | yes | Route 53 hosted zone ID | `ZXXXXXXXXXXXXX` |
| `WHOIS_HOST` | yes | Authoritative NS to query for current DNS value | `NS-382.AWSDNS-47.COM` |
| `HEALTHCHECK_URL` | no | Pinged at the top of every loop, before the IP check | `https://hc-ping.com/your-uuid` |
| `PUSH_URL` | no | Pinged after each check/update cycle (e.g. Uptime Kuma) | `http://kuma:5998/api/push/TOKEN` |

## docker-compose entry

```yaml
  dynip:
    image: ghcr.io/tedder/dynip:latest
    network_mode: host
    restart: always
    volumes:
    - /foo/aws-credentials:/.aws/credentials:ro
    environment:
    - HEALTHCHECK_URL=https://hc-ping.com/asdf
    - PUSH_URL=http://your-uptime-kuma:5998/api/push/TOKEN
    - MYNAME=home
    - MYDOMAIN=mydomain.com
    - WHOIS_HOST=NS-987.AWSDNS-123.COM
    - HOSTED_ZONE_ID=ZXXXXXXXXXXXXX
```

Note: `network_mode: host` is required so the container sees the same external IP as the host.
Without it, Docker bridge NAT can cause the container to report a stale or incorrect IP.

## releasing

The GitHub Actions workflow (`.github/workflows/ghcr-push.yml`) builds and pushes to
`ghcr.io/tedder/dynip:latest` on every push to `main`. It does **not** create a GitHub Release.

To cut a release manually:

```bash
git tag v1.x.x
git push origin v1.x.x
gh release create v1.x.x --title "v1.x.x" --notes "Description of changes."
```

The tag push triggers the workflow, which builds and pushes the Docker image.
The `gh release create` step creates the GitHub Release entry separately.
