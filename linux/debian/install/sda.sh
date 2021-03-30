parted --script /dev/sda \
      mklabel gpt \
      mkpart primary 1MB 3MB \
      name 1 grub \
      set 1 bios_grub on \
      mkpart primary 3MB 503MB \
      name 2 boot \
      set 2 boot on \
      mkpart primary 503MB 100% \
      name 3 system
mkfs.ext4 -F -L boot /dev/sda2
# configure lvm
pvcreate /dev/sda3 -ffy
vgcreate lvm /dev/sda3 -ffy
lvcreate -v -y -d -L 500MiB -n swap lvm
lvcreate -y -l 100%FREE -n root lvm -v
# format and swap
mkswap /dev/mapper/lvm-swap
swapon /dev/mapper/lvm-swap
mkfs.ext4 -F -L root /dev/mapper/lvm-root
# install opteration system
rm -rf /4b42
mkdir /4b42
mount -t ext4 /dev/mapper/lvm-root /4b42
mkdir /4b42/boot
mount /dev/sda2 /4b42/boot
debootstrap --arch amd64 buster /4b42 http://ftp.debian.org/debian/
mount --bind /dev /4b42/dev
mount --bind /proc /4b42/proc
mount --bind /sys /4b42/sys
mount --bind /run /4b42/run
# configure new system
cat << EOF > /4b42/etc/apt/sources.list
deb http://ftp.debian.org/debian/ buster main
deb-src http://ftp.debian.org/debian/ buster main

deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main

# buster-updates, previously known as 'volatile'
deb http://ftp.debian.org/debian/ buster-updates main
deb-src http://ftp.debian.org/debian/ buster-updates main
EOF
echo -e 'LANG=de_CH.UTF-8\nLANGUAGE="de_CH:de"\n' > /4b42/etc/default/locale
echo>/4b42/etc/fstab
chroot /4b42 apt update
chroot /4b42 apt -y upgrade

