# eduMEET production — quick ops

Deploy path on server: `/root/edumeet-docker`

## Site down?

```bash
cd /root/edumeet-docker
docker ps
```

Proxy must be **Up** on **80** and **443** (not `Restarting`). If proxy is broken, fix `docker-compose.yml` (see below) then:

```bash
docker compose up -d --no-deps proxy
```

Do **not** reboot the whole server first.

**What went wrong once:** bad `proxy` `entrypoint` + `command` in Compose → nginx crash loop → full outage. Not boot order.

---

## Deploy new client build only

```bash
cd /root/edumeet-docker
docker compose build --no-cache edumeet-client
docker compose up -d --no-deps edumeet-client
```

---

## After SSL renewal

```bash
docker exec edumeet-docker-proxy-1 nginx -s reload
```

Or use `scripts/reload-nginx-after-cert.sh` as Certbot `deploy_hook`.

---

## Proxy rule

Do **not** set `entrypoint: [/bin/sh, -c]` and `command: [sh, -c, ...]` together on `proxy`. Use the `command` already in this repo’s `docker-compose.yml`.

---

## Pull repo updates

```bash
cd /root/edumeet-docker
git pull
docker compose up -d --no-deps proxy    # only if compose changed
```
