#!/bin/bash
set -euo pipefail

# 获取最新版本
API_URL="https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/tag/alpha"
NEW_VER=$(curl -s $API_URL | jq -r '.tag_name | sub("^v"; "")')
CURRENT_VER=$(grep -Po '^pkgver=\K.*' PKGBUILD)

# 检查版本更新
if [[ "$NEW_VER" == "$CURRENT_VER" ]]; then
  echo "无新版本"
  exit 0
fi

# 更新 PKGBUILD
sed -i "s/^pkgver=.*/pkgver=$NEW_VER/" PKGBUILD
sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD  # 重置 pkgrel

# 下载源码并计算校验和
updpkgsums PKGBUILD

# 更新 .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# 设置提交信息
echo "UPDATE_NEEDED=true" >> $GITHUB_ENV
echo "::set-output name=new_version::$NEW_VER"
