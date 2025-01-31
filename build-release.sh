#!/bin/bash
sum="sha1sum"

if ! hash sha1sum 2>/dev/null; then
	if ! hash shasum 2>/dev/null; then
		echo "I can't see 'sha1sum' or 'shasum'"
		echo "Please install one of them!"
		exit
	fi
	sum="shasum"
fi

UPX=false
if hash upx 2>/dev/null; then
	UPX=true
fi

VERSION=`date -u +%Y%m%d`
VERSION='1'
LDFLAGS="-X main.VERSION=$VERSION -s -w"
GCFLAGS=""

OSES=(linux darwin windows freebsd)
ARCHS=(amd64 386)
ARCHS=(amd64)
for os in ${OSES[@]}; do
	for arch in ${ARCHS[@]}; do
		suffix=""
		if [ "$os" == "windows" ]
		then
			suffix=".exe"
		fi
		env CGO_ENABLED=0 GOOS=$os GOARCH=$arch go build -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_${os}_${arch}${suffix}
		if $UPX; then upx -9 client_${os}_${arch}${suffix};fi
		tar -zcf lanproxy-client-${os}-${arch}-$VERSION.tar.gz client_${os}_${arch}${suffix}
		$sum lanproxy-client-${os}-${arch}-$VERSION.tar.gz
	done
done

# ARM
ARMS=(5 6 7)
for v in ${ARMS[@]}; do
	env CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=$v go build -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_linux_arm$v
done
if $UPX; then upx -9 client_linux_arm* server_linux_arm*;fi
tar -zcf lanproxy-client-linux-arm-$VERSION.tar.gz client_linux_arm*
$sum lanproxy-client-linux-arm-$VERSION.tar.gz

# Mac ARM
env CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_darwin_arm64
tar -zcf lanproxy-client-darwin-arm64-$VERSION.tar.gz client_darwin_arm64
$sum lanproxy-client-darwin-arm64-$VERSION.tar.gz

#MIPS32LE
env CGO_ENABLED=0 GOOS=linux GOARCH=mipsle go build -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_linux_mipsle
env CGO_ENABLED=0 GOOS=linux GOARCH=mips go build -ldflags "$LDFLAGS" -gcflags "$GCFLAGS" -o client_linux_mips

if $UPX; then upx -9 client_linux_mips* server_linux_mips*;fi
tar -zcf lanproxy-client-linux-mipsle-$VERSION.tar.gz client_linux_mipsle
tar -zcf lanproxy-client-linux-mips-$VERSION.tar.gz client_linux_mips
$sum lanproxy-client-linux-mipsle-$VERSION.tar.gz
$sum lanproxy-client-linux-mips-$VERSION.tar.gz
