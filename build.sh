#!/bin/bash

pkg=${1:-v2ray-core-latest.zip}


test -f ${pkg} || exit
test -L ${pkg} && pkg=$(basename $(readlink -f $pkg))

#
dst=src
test -d $dst && rm -rf $dst
unzip $pkg -d $dst
src=${PWD}

#
cp -vf ${src:+$src/}v2ray.service  $dst/systemd/system/v2ray.service
cp -vf ${src:+$src/}v2ray@.service $dst/systemd/system/v2ray@.service
cp -vf ${src:+$src/}config.json    $dst/config.json
#
src=$dst

#
pkg_name=${pkg%.*}
pkg_version=${pkg_name##*-}
pkg_name=${pkg_name%-*}
pkg_arch=${pkg_name##*-}
pkg_name=${pkg_name%-*}

#
dst="${pkg_name}-${pkg_arch}-${pkg_version}"
test -d "$dst" && rm -rf $dst
mkdir $dst




#
install -d $dst/DEBIAN
cat > $dst/DEBIAN/control << EOF
Package: $pkg_name
Architecture: $pkg_arch
Version: $pkg_version
Maintainer: Wenger Binning <wengerbinning@gmail.com>
Description: The Proxy Service.
	Project V is a set of network tools that helps you to build your own computer
	network. It secures your network connections and thus protects your privacy. 
EOF
cat > $dst/DEBIAN/postinst << EOF
EOF
chmod a+x $dst/DEBIAN/postinst
#


#
install -m 0755 -d $dst/usr/bin
install -m 0755 -t $dst/usr/bin $src/v2ray
#
install -m 0755 -d $dst/usr/share/v2ray
install -m 0644 -t $dst/usr/share/v2ray $src/geoip.dat
install -m 0644 -t $dst/usr/share/v2ray $src/geosite.dat
install -m 0644 -t $dst/usr/share/v2ray $src/geoip-only-cn-private.dat
#
install -m 0755 -d $dst/etc/systemd/system
install -m 0644 -t $dst/etc/systemd/system $src/systemd/system/v2ray.service
install -m 0644 -t $dst/etc/systemd/system $src/systemd/system/v2ray@.service
#
install -m 0755 -d $dst/etc/v2ray
install -m 0644 -t $dst/etc/v2ray $src/config.json
install -m 0644 -t $dst/etc/v2ray $src/vpoint_socks_vmess.json
install -m 0644 -t $dst/etc/v2ray $src/vpoint_vmess_freedom.json


#
dpkg-deb --root-owner-group --build $dst
