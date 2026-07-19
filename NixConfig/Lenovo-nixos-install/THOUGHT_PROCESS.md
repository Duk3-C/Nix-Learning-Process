# Plan Thought Process: Rationale and Decision Log

This file records design decisions, constraints, and verification points. It is not a transcript of private chain-of-thought reasoning.

## GPU architecture

The initial request asked for NVIDIA PRIME with an integrated GPU. AMD lists the Ryzen 7 7435HS without integrated graphics, so there is no confirmed render device to use as the PRIME primary GPU. Guessing a PCI bus ID would produce a broken display configuration. Following clarification, this plan uses the RTX 4060 as the only GPU and does not enable `hardware.nvidia.prime`.

The NVIDIA configuration enables DRM modesetting for Wayland, the open kernel module supported by the RTX 4060 generation, and NixOS NVIDIA power-management services. `hardware.nvidia.powerManagement.enable` preserves video memory and coordinates the NVIDIA suspend, hibernate, and resume services. The newer kernel suspend notifier is explicitly disabled so the systemd services remain active and independently observable during troubleshooting. Fine-grained PRIME power management is disabled because this is not an offload configuration.

Sway may reject NVIDIA's proprietary userspace driver even when the open kernel module is used. The system therefore starts Sway with `--unsupported-gpu`. This is an explicit compatibility choice, not a claim that NVIDIA is officially supported by wlroots/Sway.

## Release channels

NixOS and Home Manager are pinned to their 26.05 release branches. nixpkgs unstable is a separate flake input exposed only as `pkgsUnstable`; it does not replace the system package set. This limits unstable-package risk and makes each unstable selection visible in `home.nix`.

The lock file is intentionally generated on the installation media so it records revisions that actually exist at installation time.

## Storage

LUKS2 encrypts one Btrfs system partition. Btrfs subvolumes separate the root, home, Nix store, snapshots, and swap areas without hard partition-size boundaries. Compression is enabled except for swap. A swap file is included for memory pressure, but hibernation is not enabled because reliable resume from a Btrfs swap file requires an installation-specific resume offset.

The UEFI system partition cannot be encrypted. Secrets must not be stored there. `/boot` is mounted with a restrictive umask.

## Desktop and productivity

Sway is enabled at the NixOS level so PAM, portals, polkit, graphics support, and the wrapped executable are system-integrated. Home Manager owns user-facing Sway keybindings and application configuration. greetd provides a small display-independent login flow.

PipeWire supplies audio, NetworkManager handles networking, and power-profiles-daemon exposes platform power modes where firmware supports them. zram complements disk swap and reduces unnecessary writes.

## Placeholders and hardware verification

The flake defaults are intentionally usable but generic. The installer must replace user and regional values. The included `hardware-configuration.nix` is a baseline, not a substitute for `nixos-generate-config`; target-specific initrd modules and device discovery must be reviewed on the laptop.

The encrypted disk configuration uses GPT partition labels (`ESP` and `cryptroot`) rather than fabricated UUIDs. The encryption guide creates those exact labels. UUIDs may be substituted after installation for stronger identity guarantees.

## Known risks

- The supplied CPU and claimed dual-GPU layout conflict. The final configuration follows the later instruction to use NVIDIA only.
- Sway on NVIDIA remains less predictable than on AMD or Intel graphics.
- Laptop suspend behavior depends on BIOS/EC firmware as well as the NVIDIA driver.
- NixOS 26.05 inputs require those release branches to be published when the lock file is generated.
- Secure Boot is not part of the initial installation.
- Hibernation is not configured; only suspend-to-RAM is in scope.
