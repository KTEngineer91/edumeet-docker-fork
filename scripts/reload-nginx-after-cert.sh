#!/bin/sh
# Run after certbot renew on the host (deploy hook).
set -e
docker exec edumeet-docker-proxy-1 nginx -s reload
