# Debian
## Installation via Securebit Rescue System
### Install on /dev/sda
wget --no-check-certificate -O - https://raw.githubusercontent.com/securebitag/scripts/main/linux/debian/install.sh | sh

### Install on /dev/vsa
wget --no-check-certificate -O /tmp/install.sh https://raw.githubusercontent.com/securebitag/scripts/main/linux/debian/install.sh; sed -i 's/sda/vda/g' /tmp/install.sh; /bin/sh /tmp/install.sh

## BIRD2
apt -y install wget; wget --no-check-certificate -O - https://raw.githubusercontent.com/securebitag/scripts/main/linux/debian/install/bird2.sh | bash
