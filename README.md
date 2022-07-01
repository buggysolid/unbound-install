# What

This will install the latest version of Unbound from source with a configuration that only answers queries from RFC1918 addresses.

Features enabled.

- QNAME minimisation
- Prefetching
- Stale caching
- Minimal responses
- DNSSEC

# Install

apt-get based systems (Ubuntu/Debian)

```
sudo apt-get install git -y
git clone https://github.com/buggysolid/unbound-install
cd unbound-install
./install-apt-get.sh
```

yum/dnf based systems (Centos/Fedora/Redhat)

```
sudo yum install git -y
git clone https://github.com/buggysolid/unbound-install
cd unbound-install
./install-yum.sh
```
