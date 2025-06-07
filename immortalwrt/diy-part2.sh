#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

## 移除 SNAPSHOT 标签
#sed -i 's,SNAPSHOT,,g' include/version.mk
#sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

## Modify default Lan IP
sed -i 's/192.168.6.1/192.168.5.1/g' package/base-files/files/bin/config_generate

## 启用 luci-app-irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

## Modify hostname
#sed -i 's/ImmortalWrt/rax3000m_256m/g' package/base-files/files/bin/config_generate

## 修改wan口默认pppoe和设置pppoe拨号账户密码
if [[ -n "$PPPOE_USERNAME" && -n "$PPPOE_PASSWD" ]]; then
  sed -i 's/2:-dhcp/2:-pppoe/g' package/base-files/files/lib/functions/uci-defaults.sh

  sed -i "s#username='username'#username='$PPPOE_USERNAME'#g" package/base-files/files/bin/config_generate
  sed -i "s#password='password'#password='$PPPOE_PASSWD'#g" package/base-files/files/bin/config_generate
fi

## 修改wifi名称（mtwifi-cfg）
sed -i 's/ImmortalWrt-2.4G/RAX3000M/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ImmortalWrt-5G/RAX3000M-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

## 修改闪存为256M版本(这是针对原厂128闪存来的，但又要编译256M固件来的）
#sed -i 's/<0x580000 0x7200000>/<0x580000 0xee00000>/g' target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/mt7981-cmcc-rax3000m.dts
#sed -i 's/116736k/240128k/g' target/linux/mediatek/image/mt7981.mk

## 删除冲突的软件包
#rm -rf ./package/istore
#rm -rf ./feeds/kenzo/luci-app-quickstart
#rm -rf ./feeds/kenzo/luci-app-store
#rm -rf ./feeds/kenzo/luci-lib-taskd
rm -rf package/new && mkdir -p package/new

## 下载主题luci-theme-argon
# git clone https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
# git clone https://github.com/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config
## 调整 LuCI 依赖，去除 luci-app-opkg，替换主题 bootstrap 为 argon
# sed -i '/+luci-light/d;s/+luci-app-opkg/+luci-light/' ./feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/' ./feeds/luci/collections/luci-light/Makefile
## 修改argon背景图片
rm -rf feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

## golang编译环境
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

## Add luci-app-ddns-go
#rm -rf feeds/luci/applications/luci-app-ddns-go
#rm -rf feeds/packages/net/ddns-go
#git clone --depth 1 https://github.com/sirpdboy/luci-app-ddns-go package/new/ddnsgo
#mv -n package/new/ddnsgo/*ddns-go package/new/
#rm -rf package/new/ddnsgo

## adguardhome
git clone -b patch-1 https://github.com/kiddin9/openwrt-adguardhome package/new/openwrt-adguardhome
mv package/new/openwrt-adguardhome/*adguardhome package/new/
\cp -rf $GITHUB_WORKSPACE/patches/AdGuardHome/AdGuardHome_template.yaml package/new/luci-app-adguardhome/root/usr/share/AdGuardHome/AdGuardHome_template.yaml
\cp -rf $GITHUB_WORKSPACE/patches/AdGuardHome/links.txt package/new/luci-app-adguardhome/root/usr/share/AdGuardHome/links.txt
# sed -i 's/+adguardhome/+PACKAGE_$(PKG_NAME)_INCLUDE_binary:adguardhome/g' package/new/luci-app-adguardhome/Makefile
rm -rf package/new/openwrt-adguardhome

## Add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/net/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/new/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/new/sbwml-mosdns
mv -n package/new/sbwml-mosdns/*mosdns package/new/
mv -n package/new/sbwml-mosdns/v2dat package/new/
rm -rf package/new/sbwml-mosdns

## Add luci-app-wolplus
# git clone https://github.com/animegasan/luci-app-wolplus package/new/luci-app-wolplus

## Add luci-app-wechatpush
rm -rf feeds/luci/applications/luci-app-wechatpush/
git clone https://github.com/tty228/luci-app-wechatpush.git package/new/luci-app-wechatpush

## Add luci-app-pushbot
git clone https://github.com/zzsj0928/luci-app-pushbot package/new/luci-app-pushbot

## Add luci-app-socat
rm -rf feeds/packages/net/socat
git clone https://github.com/immortalwrt/packages package/new/immortalwrt-packages
mv package/new/immortalwrt-packages/net/socat package/new/socat
rm -rf package/new/immortalwrt-packages
rm -rf feeds/luci/applications/luci-app-socat
git clone --depth 1 https://github.com/chenmozhijin/luci-app-socat package/new/chenmozhijin-socat
mv -n package/new/chenmozhijin-socat/luci-app-socat package/new/
rm -rf package/new/chenmozhijin-socat

####################################(适用于openwrt 23.05 及以上的分支.)
### clone kiddin9/openwrt-packages仓库
#git clone https://github.com/kiddin9/kwrt-packages package/new/openwrt-packages
#
### Add luci-app-autoreboot
#mv package/new/openwrt-packages/luci-app-autoreboot package/new/luci-app-autoreboot
#
### Add luci-app-onliner
#mv package/new/openwrt-packages/luci-app-onliner package/new/luci-app-onliner
#
### Add luci-app-qbittorrent
#mv package/new/openwrt-packages/qBittorrent-Enhanced-Edition package/new/qBittorrent-Enhanced-Edition
#mv package/new/openwrt-packages/luci-app-qbittorrent package/new/luci-app-qbittorrent
### qbittorrent依赖
#mv package/new/openwrt-packages/qt6tools package/new/qt6tools
#mv package/new/openwrt-packages/qt6base package/new/qt6base
#mv package/new/openwrt-packages/libdouble-conversion package/new/libdouble-conversion
#rm -rf feeds/packages/libs/libtorrent-rasterbar
#mv package/new/openwrt-packages/libtorrent-rasterbar package/new/libtorrent-rasterbar
#
### Add luci-app-partexp
## mv package/new/openwrt-packages/luci-app-partexp package/new/luci-app-partexp
#
### Add luci-app-diskman
## mv package/new/openwrt-packages/luci-app-diskman package/new/luci-app-diskman
#
### Add luci-app-fileassistant
#rm -rf feeds/luci/applications/luci-app-fileassistant
#mv package/new/openwrt-packages/luci-app-fileassistant package/new/luci-app-fileassistant
#
### Add luci-app-wolplus
#mv package/new/openwrt-packages/luci-app-wolplus package/new/luci-app-wolplus
#
#rm -rf package/new/openwrt-packages
#################################

## Add luci-app-openclash
rm -rf feeds/luci/applications/luci-app-openclash
#bash $GITHUB_WORKSPACE/scripts/openclash.sh arm64
# bash $GITHUB_WORKSPACE/scripts/openclash-dev.sh arm64
git clone --depth 1 https://github.com/vernesong/OpenClash package/new/OpenClash
mv -n package/new/OpenClash/luci-app-openclash package/new/
rm -rf package/new/OpenClash
mkdir -p package/new/luci-app-openclash/root/etc/openclash/core

# CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz"
# CLASH_TUN_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/master/premium\?ref\=core | grep download_url | grep $1 | awk -F '"' '{print $4}' | grep -v "v3" )
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

# wget -qO- $CLASH_DEV_URL | tar xOvz > package/new/luci-app-openclash/root/etc/openclash/core/clash
# wget -qO- $CLASH_TUN_URL | gunzip -c > package/new/luci-app-openclash/root/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > package/new/luci-app-openclash/root/etc/openclash/core/clash_meta
wget -qO- $GEOIP_URL > package/new/luci-app-openclash/root/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > package/new/luci-app-openclash/root/etc/openclash/GeoSite.dat

chmod +x package/new/luci-app-openclash/root/etc/openclash/core/clash*

## Add luci-app-qbittorrent/4.4.5
git clone -b 4.4.5 https://github.com/sbwml/luci-app-qbittorrent.git package/new/luci-app-qbittorrent

## Add zsh
#bash $GITHUB_WORKSPACE/scripts/zsh.sh
# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd
# preset-terminal-tools
mkdir -p files/root
pushd files/root
# Install oh-my-zsh
git clone https://github.com/ohmyzsh/ohmyzsh ./.oh-my-zsh
# Install extra plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions
# Get .zshrc dotfile
cp $GITHUB_WORKSPACE/patches/.zshrc .
popd


## end
ls -1 package/new/

