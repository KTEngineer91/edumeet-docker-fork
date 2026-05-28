# After PR merge — server validation

Run on `5.161.42.183` only after merging to `main`.

## 1. Backup

```bash
cd /root/edumeet-docker
cp -a docker-compose.yml docker-compose.yml.bak.$(date +%Y%m%d)
cp -a nginx.conf.rendered nginx.conf.rendered.bak.$(date +%Y%m%d)
```

## 2. Point git at the fork

```bash
git remote set-url origin git@github.com:KTEngineer91/edumeet-docker-fork.git
git fetch origin
git checkout main
git pull origin main
```

## 3. Align deploy tree

Either copy from clone:

```bash
cp production/stream/docker-compose.yml .
cp production/stream/nginx.conf.rendered .
# keep existing .env and certbot/conf/
```

Or replace deploy root with a fresh clone of the fork and restore `.env` + `certbot/` + `configs/app` from backup.

## 4. Recreate proxy only if files changed

```bash
docker compose up -d --no-deps proxy
docker ps   # proxy Up on 80 and 443
curl -sI https://stream.breezeshot.com/ | head -1
```

## 5. Wire certbot reload (optional)

```bash
chmod +x scripts/reload-nginx-after-cert.sh
# Add deploy_hook in /etc/letsencrypt/renewal/*.conf pointing to this script
```
