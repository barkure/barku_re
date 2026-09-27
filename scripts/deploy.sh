#!/usr/bin/env bash
# 部署:构建 SvelteKit 静态站并推送到 DMIT-LAX,由 Caddy file_server 提供服务。
# Caddyfile 里的 barku.re 站点块(/xhttp* 反代 + file_server)只改一次,本脚本不动它。
set -euo pipefail

cd "$(dirname "$0")/.."
pnpm build

# COPYFILE_DISABLE + --no-xattrs: macOS bsdtar 不往流里塞 ._* AppleDouble 文件
COPYFILE_DISABLE=1 tar --no-xattrs -C build -cf - . | ssh DMIT-LAX '
set -euo pipefail
rm -rf /srv/barku.re.tmp /srv/barku.re.old
mkdir -p /srv/barku.re.tmp
tar -C /srv/barku.re.tmp -xf -
rm -rf /srv/barku.re
mv /srv/barku.re.tmp /srv/barku.re
'
echo "deployed -> https://barku.re/"
