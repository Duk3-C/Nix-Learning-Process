# Encrypted Disk Setup

## Warning

The commands below permanently erase the selected disk. Verify the device name with `lsblk` before continuing. They assume a single target disk at `/dev/nvme0n1`, UEFI boot, and no dual boot.

Set a shell variable only after verifying the disk:

```bash
sudo -i
lsblk -o NAME,SIZE,TYPE,FSTYPE,MODEL
export DISK=/dev/nvme0n1
```

## Partition the disk

Create a 1 GiB EFI partition and use the remainder for LUKS:

```bash
wipefs -a "$DISK"
parted "$DISK" --script -- mklabel gpt
parted "$DISK" --script -- mkpart ESP fat32 1MiB 1025MiB
parted "$DISK" --script -- set 1 esp on
parted "$DISK" --script -- name 1 ESP
parted "$DISK" --script -- mkpart cryptroot 1025MiB 100%
parted "$DISK" --script -- name 2 cryptroot
partprobe "$DISK"
```

Confirm the result before encryption:

```bash
lsblk -o NAME,SIZE,TYPE,PARTLABEL "$DISK"
```

## Create LUKS2

Choose a long, unique passphrase. Losing it means losing the data.

```bash
cryptsetup luksFormat --type luks2 --verify-passphrase /dev/disk/by-partlabel/cryptroot
cryptsetup open /dev/disk/by-partlabel/cryptroot cryptroot
```

Back up the LUKS header to external encrypted storage after installation:

```bash
cryptsetup luksHeaderBackup /dev/disk/by-partlabel/cryptroot --header-backup-file /path/on/external-media/legion-luks-header.img
```

The header backup is sensitive and does not replace the passphrase.

## Format and mount

```bash
mkfs.fat -F 32 -n ESP /dev/disk/by-partlabel/ESP
mkfs.btrfs -f -L nixos /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap
umount /mnt
```

Mount the subvolumes:

```bash
mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,nix,.snapshots,swap}
mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o subvol=@snapshots,compress=zstd,noatime /dev/mapper/cryptroot /mnt/.snapshots
mount -o subvol=@swap,noatime,nodatacow /dev/mapper/cryptroot /mnt/swap
mount -o umask=0077 /dev/disk/by-partlabel/ESP /mnt/boot
```

Create a 20 GiB swap file. The `@swap` subvolume is mounted without copy-on-write or compression:

```bash
btrfs filesystem mkswapfile --size 20G --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile
```

Verify all mounts:

```bash
findmnt /mnt
swapon --show
```

Continue with the installation sequence in `PLAN.md`.
