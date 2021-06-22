#!/bin/bash
# Enable IP Forwarding
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf

# Add repo key
apt install -y dirmngr gnupg2
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B188E2B695BD4743
echo "deb http://bird.network.cz/debian/ buster main">/etc/apt/sources.list.d/bird2.list

# System Update
apt update
apt -y upgrade

# Install Bird2
apt -y install bird2
