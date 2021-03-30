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
