# Lenovo Legion NixOS Installation Plan

## Goal

Install NixOS 26.05 as an encrypted, reproducible Sway workstation on the Lenovo Legion laptop. The system uses the NVIDIA RTX 4060 directly, Home Manager for the user environment, and selected packages from nixpkgs unstable.

## Confirmed scope

- CPU: AMD Ryzen 7 7435HS (8 cores, 16 threads; verify in firmware)
- GPU: NVIDIA GeForce RTX 4060 Laptop GPU
- Memory: 16 GB
- Storage: approximately 476 GB NVMe
- Desktop: Sway on Wayland
- Stable system packages: NixOS 26.05
- Selected newer packages: nixpkgs unstable
- Disk: LUKS2-encrypted Btrfs
- Boot: UEFI with systemd-boot

NVIDIA PRIME is intentionally not configured. The Ryzen 7 7435HS is documented without an integrated GPU, and the user requested an NVIDIA-only configuration after this was identified. The NVIDIA suspend services and video-memory preservation are enabled instead.

## Before installation

1. Update the laptop BIOS/UEFI from Lenovo.
2. Back up all files. The encryption procedure erases the selected disk.
3. In firmware, use UEFI mode and disable CSM/legacy boot.
4. Disable Windows Fast Startup if retaining any Windows-created filesystems.
5. Confirm that Secure Boot is disabled for the initial installation. It can be added later with Lanzaboote.
6. Boot the NixOS 26.05 graphical or minimal ISO.
7. Verify the hardware:

   ```bash
   lspci -nn | grep -E 'VGA|3D|Display|Network'
   lsblk -o NAME,SIZE,TYPE,FSTYPE,MODEL
   cat /sys/power/mem_sleep
   ```

8. Confirm the target disk name. Commands in `DISK_ENCRYPTION.md` assume `/dev/nvme0n1`.

## Installation sequence

1. Follow `DISK_ENCRYPTION.md` to partition, encrypt, format, and mount the disk.
2. Generate target-specific hardware configuration and save a comparison copy:

   ```bash
   sudo nixos-generate-config --root /mnt
   sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/hardware-configuration.generated.nix
   ```

3. Copy the `nixos` directory to `/mnt/etc/nixos`.
4. Compare `/mnt/hardware-configuration.generated.nix` with `/mnt/etc/nixos/hardware-configuration.nix`. Add any generated kernel modules and detected hardware settings missing from the repository baseline. Keep the encrypted root and Btrfs mount definitions from the baseline.
5. Edit the constants near the top of `/mnt/etc/nixos/flake.nix`:
   - `hostname`
   - `username`
   - `timezone`
   - `locale`
6. Review `/mnt/etc/nixos/home.nix`, especially Git identity and preferred applications.
7. Generate the lock file and install:

   ```bash
   cd /mnt/etc/nixos
   sudo nix --extra-experimental-features 'nix-command flakes' flake lock
   sudo nixos-install --flake .#legion
   ```

8. Set the regular user's password after installation:

   ```bash
   sudo nixos-enter --root /mnt -c 'passwd nixos'
   ```

   Replace `nixos` with the configured username. This is separate from the root password requested by `nixos-install`.

9. Reboot, remove the installer, unlock LUKS, and log in through greetd.

## First-boot checks

Run these before treating the installation as complete:

```bash
nvidia-smi
echo "$XDG_SESSION_TYPE"
systemctl status nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
journalctl -b -p warning
sudo nixos-rebuild dry-build --flake /etc/nixos#legion
```

The session type should be `wayland`, and `nvidia-smi` should show the RTX 4060.

## Suspend validation

Save work before each test. Test five or more suspend/resume cycles both on AC power and battery:

```bash
systemctl suspend
```

After each resume, check Sway rendering, external displays, Wi-Fi, audio, and:

```bash
nvidia-smi
journalctl -b -u nvidia-suspend.service -u nvidia-resume.service
journalctl -b | grep -Ei 'nvrm|nvidia|suspend|resume|amdgpu'
```

If resume still fails, capture `journalctl -b -1` after a forced restart and record the output of `cat /sys/power/mem_sleep`. Do not add random kernel parameters before identifying whether the failure is NVIDIA, firmware, or platform sleep related.

## Routine operation

Update both stable and unstable inputs, inspect the proposed build, then switch:

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild dry-build --flake .#legion
sudo nixos-rebuild switch --flake .#legion
```

Roll back from the systemd-boot generation menu if an update fails. Periodic automatic garbage collection is configured, but old bootable generations remain available until collected.

## Acceptance criteria

- Encrypted root requires the LUKS passphrase at boot.
- Sway starts from greetd and uses native Wayland applications where supported.
- `nvidia-smi` detects the RTX 4060.
- Suspend/resume succeeds repeatedly on battery and AC power.
- Home Manager applies the user packages and Sway configuration.
- Stable system packages come from NixOS 26.05; explicitly selected packages come from unstable.
- `nixos-rebuild dry-build --flake .#legion` succeeds.
