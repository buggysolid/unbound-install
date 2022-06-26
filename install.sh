#!/usr/bin/env bash
# Install the latest version of Unbound and start it as a SystemD service.

set -o errexit
set -o pipefail

rm -f run.log && touch run.log
echo "Updating system."
sudo apt-get update | tee -a run.log
echo "Installing dependencies."
sudo apt-get install -y build-essential libssl-dev libexpat1-dev bison flex libevent-dev libsodium-dev libprotobuf-c-dev wget tar make | tee -a run.log
echo "Grabbing the latest version of Unbound."
wget 'https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz' | tee -a run.log
echo "Extracting Unbound."
tar xzf unbound-latest.tar.gz | tee -a run.log
echo "Configuring Unbound."
cd "$(ls -d ./*unbound*/)"
./configure --with-pthreads --with-libevent --with-protobuf-c --with-libsodium | tee -a run.log
echo "Building Unbound from source."
make | tee -a run.log
sudo make install | tee -a run.log
sudo useradd unbound | tee -a run.log
sudo chown -R unbound /usr/local/etc/unbound | tee -a run.log
sudo -u unbound wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/unbound.conf' -O /usr/local/etc/unbound/unbound.conf | tee -a run.log
sudo ldconfig | tee -a run.log
sudo -u unbound unbound-anchor | tee -a run.log
sudo -u unbound unbound-control-setup | tee -a run.log
sudo wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/unbound.service' -O /etc/systemd/system/unbound.service | tee -a run.log
sudo chmod 755 /etc/systemd/system/unbound.service | tee -a run.log
sudo wget 'https://raw.githubusercontent.com/buggysolid/unbound-config/main/resolv.conf' -O "$HOME/resolv.conf" | tee -a run.log
sudo mv "$HOME/resolv.conf" /etc/resolv.conf | tee -a run.log
sudo chmod 744 /etc/resolv.conf | tee -a run.log
sudo systemctl stop systemd-resolved | tee -a run.log
sudo systemctl disable systemd-resolved | tee -a run.log
sudo systemctl enable unbound | tee -a run.log
sudo systemctl restart unbound | tee -a run.log
sudo systemctl status unbound | tee -a run.log
echo "Unbound installed."
