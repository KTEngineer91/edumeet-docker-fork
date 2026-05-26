# eduMEET Docker Fork — operations (Breezeshot)

This repo (`KTEngineer91/edumeet-docker-fork`) is the infrastructure source for production. Application images are built from Dockerfiles here using forks such as `edumeet-client-fork`.

## Incident summary (for stakeholders)

1. **Before restart:** Users may have seen connection or join errors.
2. **After restart:** **Whole site down** (HTTPS/meetings), not an isolated “socket bug.”
3. **Cause:** nginx **proxy** container crash-loop from invalid Docker Compose `entrypoint` + `command` on `proxy` (if compose was edited incorrectly on the server).
4. **Not boot order:** Room server and other containers were often still `Up`; the public proxy on ports 80/443 failed.
5. **Fix:** Restore a valid proxy definition (see below), then recreate **only** proxy: `docker compose up -d --no-deps proxy`.

---

## Health check (~30 seconds)

```bash
cd /root/edumeet-docker   # deploy directory on the server
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
curl -sI https://stream.breezeshot.com/ | head -1
```

**Required:** proxy container → **Up** with `0.0.0.0:80->80` and `443->443` (**not** `Restarting`).

---

## Deploy latest client only (safe)

```bash
cd /root/edumeet-docker
# Set BRANCH_CLIENT in .env (e.g. main)
docker compose build --no-cache edumeet-client
docker compose up -d --no-deps edumeet-client
```

Does **not** restart proxy, room server, DB, Keycloak, or TURN.

---

## Restart one service

```bash
docker compose restart edumeet-room-server   # example
```

---

## After SSL certificate renewal

Certs update on disk; nginx must reload:

```bash
docker exec edumeet-docker-proxy-1 nginx -s reload
```

Use the script in this repo: `scripts/reload-nginx-after-cert.sh` (wire as Certbot `deploy_hook` on the server).

---

## Avoid as first response to outage

- Full **server reboot** (does not fix bad Compose on disk).
- `docker compose up -d` **without a service name** for routine client updates (can recreate a misconfigured proxy).

---

## Proxy Compose rule (critical)

**Never** combine:

```yaml
entrypoint:
  - /bin/sh
  - -c
command:
  - sh
  - -c
  - ...
```

That pattern makes the proxy exit immediately and restart forever.

**This repo’s default** uses a single `command` string with `envsubst` and nginx (see `docker-compose.yml` → `proxy`). If you switch to a static `nginx.conf.rendered` on the server, use **one** shell invocation only, for example:

```yaml
command:
  - /bin/sh
  - -c
  - nginx -t && exec nginx -g "daemon off;"
```

Do **not** add a separate `entrypoint: [/bin/sh, -c]` above it.

---

## Symptom → what to check

| Symptom | Check first |
|---------|-------------|
| Entire site down / HTTPS fails | **proxy** status |
| Join errors, site loads | **edumeet-room-server** logs, then proxy |
| Login fails | **edumeet_keycloak** |
| Browser “not secure” | cert on disk vs served cert → **nginx reload** |

---

## Update production from this repo

```bash
cd /root/edumeet-docker
git pull origin fix-infra-issue   # or main after merge
# If compose changed for proxy only:
docker compose up -d --no-deps proxy
```

Keep on the server (not in git): `.env`, `certbot/conf`, host-specific config under `configs/`.
