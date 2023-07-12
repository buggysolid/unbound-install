# What

This will install the latest version of Unbound from source with a configuration that only answers queries from RFC1918 addresses.

Features enabled.

- QNAME minimisation
- Prefetching
- Stale caching
- Minimal responses
- DNSSEC

This is the [configuration](https://github.com/buggysolid/unbound-config) for these install scripts.

# Caveat

Running this install script will disable systemd-resolved

# Install

```
cat<<EOF | sudo /usr/bin/env bash
if [[ -f "/usr/bin/apt" ]]; then
  apt update
  apt install -y git
  git clone https://github.com/buggysolid/unbound-install
  cd unbound-install
  sudo ./install-apt-get.sh
elif [[ -f "/usr/bin/yum" ]]; then
  yum makecache
  yum install -y git
  git clone https://github.com/buggysolid/unbound-install
  cd unbound-install
  sudo ./install-yum.sh
else
  echo "Could not determine which package manager is installed."
  exit
fi
EOF
```
