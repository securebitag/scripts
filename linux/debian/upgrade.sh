# Upgrade Debian 10 Buster to Debian 11 Bullseye
apt update
apt -y upgrade

cat << EOF > "${BASE}/etc/apt/sources.list"
deb http://ftp.debian.org/debian/ bullseye main
deb-src http://ftp.debian.org/debian/ bullseye main

deb http://deb.debian.org/debian-security/ bullseye-security main
deb-src http://deb.debian.org/debian-security/ bullseye-security main

deb http://ftp.debian.org/debian/ bullseye-updates main
deb-src http://ftp.debian.org/debian/ bullseye-updates main
EOF

apt update
apt -y upgrade
apt -y full-upgrade
apt -y autoremove

uname -r
cat /etc/debian_version
