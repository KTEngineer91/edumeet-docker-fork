# Breezeshot production (stream.breezeshot.com)

Snapshot of the live stack from `/root/edumeet-docker` on the eduMEET server.

## Apply on server

1. Backup: `docker-compose.yml`, `nginx.conf.rendered`, `.env`
2. Copy these files into the deploy root (e.g. `/root/edumeet-docker`):
   - `docker-compose.yml`
   - `nginx.conf.rendered`
   - `configs/proxy/` (optional reference)
   - `Dockerfiles/Dockerfile-client` (if building client from this tree)
3. Keep existing `.env` and `certbot/conf/` on the server (not in git).
4. If only docs changed: no restart. If `docker-compose.yml` or nginx config changed:

```bash
docker compose up -d --no-deps proxy
docker ps   # proxy must be Up on 80 and 443
```

## Proxy rule

Do **not** add `entrypoint: [/bin/sh, -c]` together with `command: [sh, -c, ...]` on `proxy` — that causes a crash loop.

## Git remote (after fork PR is merged)

```bash
cd /root/edumeet-docker
git remote set-url origin git@github.com:KTEngineer91/edumeet-docker-fork.git
git fetch origin
git checkout main   # or the release branch you use
```

Then pull updates instead of copying files by hand.
