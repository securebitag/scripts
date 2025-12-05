apt install -y lvm2 parted

# Disk partitioning
parted --script /dev/sda\
 mklabel gpt\
 mkpart primary 1MB 3MB\
 name 1 grub\
 set 1 bios_grub on\
 mkpart primary 3MB 503MB\
 name 2 boot\
 set 2 boot on\
 mkpart primary 503MB 100%\
 name 3 system

# Remove old LVM settings
vgremove lvm --force
pvremove /dev/sda3 --force

# Configure LVM
pvcreate /dev/sda3 -ffy
vgcreate lvm /dev/sda3 -ffy
lvcreate -v -y -d -L 500MiB -n swap lvm
lvcreate -y -l 100%FREE -n root lvm -v

# Make filesystems and activate swap
mkfs.ext4 -F -L boot /dev/sda2
mkswap /dev/mapper/lvm-swap
swapon /dev/mapper/lvm-swap
mkfs.ext4 -F -L root /dev/mapper/lvm-root

# Define and mount directories 
BASE="/4b42"
BOOT="${BASE}/boot"
mkdir "${BASE}"
mount -t ext4 /dev/mapper/lvm-root "${BASE}"
mkdir "${BOOT}"
mount /dev/sda2 "${BOOT}"

# Do Debian Buster base installation
debootstrap --arch amd64 trixie ${BASE} http://ftp.debian.org/debian/ /usr/share/debootstrap/scripts/trixie

# Mount important directories for chroot
for DIR in /dev /proc /sys /run; do
   mount --bind "${DIR}" "${BASE}${DIR}"
done

# Configure package sources
cat << EOF > "${BASE}/etc/apt/sources.list"
deb http://ftp.debian.org/debian/ trixie main
deb-src http://ftp.debian.org/debian/ trixie main

deb http://deb.debian.org/debian-security/ trixie-security main
deb-src http://deb.debian.org/debian-security/ trixie-security main

deb http://ftp.debian.org/debian/ trixie-updates main
deb-src http://ftp.debian.org/debian/ trixie-updates main
EOF

# Link mounted filesytems to mtab
ln -sf /proc/mounts /etc/mtab

# Create fstab
cat << EOF > "${BASE}/etc/fstab"
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system>		<mount point>	<type>	<options>               <dump>  <pass>
/dev/sda2		/boot		ext4	rw,nosuid,nodev		0	0
/dev/mapper/lvm-swap	none		swap	sw			0	1
/dev/mapper/lvm-root	/		ext4	errors=remount-ro	0	1
EOF

# Configure IP addresses
cat << EOF > /${BASE}/etc/network/interfaces
# The loopback network interface
auto lo
 iface lo inet loopback

# The primary network interface
auto eth0
 iface eth0 inet static
  address 192.0.2.123/24
  gateway 192.0.2.254
 iface eth0 inet6 static
  address 2001:0db8:4b42::1/64
  gateway 2001:0db8:4b42::fffe
EOF

# Configure SSH key
mkdir "${BASE}/root/.ssh"
wget https://raw.githubusercontent.com/securebitag/scripts/main/linux/authorized_keys -O "${BASE}/root/.ssh/authorized_keys" --no-check-certificate

# Update Debian and install some additional packages
chroot "${BASE}" apt update
chroot "${BASE}" apt -y dist-upgrade
chroot "${BASE}" apt -y install grub-pc linux-image-amd64 locales lvm2 ssh
chroot "${BASE}" apt --no-install-recommends --no-install-suggests install -y python3
chroot "${BASE}" grub-install /dev/sda

sed 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' -i "${BASE}/etc/default/grub"
chroot "${BASE}" update-grub

# Configure name resolution
cat << EOF > "${BASE}/etc/resolv.conf"
nameserver 2606:4700:4700::1111
nameserver 2001:4860:4860::8888
nameserver 2620:fe::fe
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 9.9.9.9
EOF

# Set hostname
echo "securebit" > "${BASE}/etc/hostname"

# Add en_US.UTF-8, e. g. required for zerotier
cp --no-clobber "${BASE}/etc/locale.gen" "${BASE}/etc/locale.gen.orig"
sed 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' "${BASE}/etc/locale.gen" > "${BASE}/etc/locale.gen.temp"
mv -f "${BASE}/etc/locale.gen.temp" "${BASE}/etc/locale.gen"
chroot ${BASE} locale-gen
