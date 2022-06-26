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
apt-get update | tee -a run.log
echo "Installing dependencies."
apt-get install -y build-essential libssl-dev libexpat1-dev bison flex libevent-dev libsodium-dev libprotobuf-c-dev wget tar make | tee -a run.log
echo "Grabbing the latest version of Unbound."
wget 'https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz' | tee -a run.log
echo "Extracting Unbound."
tar xzf unbound-latest.tar.gz | tee -a run.log
echo "Configuring Unbound."
cd "$(ls -d ./*unbound*/)"
./configure --with-pthreads --with-libevent --with-protobuf-c --with-libsodium | tee -a run.log
echo "Building Unbound from source."
make | tee -a run.log
make install | tee -a run.log
useradd unbound | tee -a run.log
chown -R unbound /usr/local/etc/unbound | tee -a run.log
wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/unbound.conf' -O /usr/local/etc/unbound/unbound.conf | tee -a run.log
ldconfig | tee -a run.log
unbound-anchor | tee -a run.log
unbound-control-setup | tee -a run.log
wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/unbound.service' -O /etc/systemd/system/unbound.service | tee -a run.log
chmod 755 /etc/systemd/system/unbound.service | tee -a run.log
wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/resolv.conf' -O "$HOME/resolv.conf" | tee -a run.log
mv "$HOME/resolv.conf" /etc/resolv.conf | tee -a run.log
chmod 744 /etc/resolv.conf | tee -a run.log
systemctl stop systemd-resolved | tee -a run.log
systemctl disable systemd-resolved | tee -a run.log
systemctl enable unbound | tee -a run.log
systemctl restart unbound | tee -a run.log
systemctl status unbound | tee -a run.log
echo "Unbound installed."
