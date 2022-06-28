#!/usr/bin/env bash
# Install the latest version of Unbound and start it as a SystemD service.

set -o errexit
set -o pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run the script as root or invoke via sudo."
  exit
fi

rm -f run.log && touch run.log
echo "Updating system."
apt-get update
echo "Installing dependencies."
apt-get install -y build-essential libssl-dev libexpat1-dev bison flex libevent-dev libsodium-dev libprotobuf-c-dev wget tar make
echo "Grabbing the latest version of Unbound."
wget 'https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz'
echo "Extracting Unbound."
tar xzf unbound-latest.tar.gz
echo "Configuring Unbound."
cd "$(ls -d ./*unbound*/)"
./configure --with-pthreads --with-libevent --with-protobuf-c --with-libsodium
echo "Building Unbound from source."
make
make install
useradd unbound
chown -R unbound /usr/local/etc/unbound
wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/unbound.conf' -O /usr/local/etc/unbound/unbound.conf
ldconfig
unbound-anchor
unbound-control-setup
wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/unbound.service' -O /etc/systemd/system/unbound.service
chmod 755 /etc/systemd/system/unbound.service
wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/resolv.conf' -O "$HOME/resolv.conf"
mv "$HOME/resolv.conf" /etc/resolv.conf
chmod 744 /etc/resolv.conf
systemctl stop systemd-resolved
systemctl disable systemd-resolved
systemctl enable unbound
systemctl restart unbound
systemctl status unbound
echo "Unbound installed."
