{ config, pkgs, hostname, username, timezone, locale, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./sway.nix
  ];

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  time.timeZone = timezone;
  i18n.defaultLocale = locale;
  console.keyMap = "us";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.systemd.enable = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    description = "Primary user";
    extraGroups = [ "networkmanager" "video" "wheel" ];
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  services = {
    blueman.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    enableRedistributableFirmware = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  environment.systemPackages = with pkgs; [
    btop
    cryptsetup
    curl
    git
    pciutils
    ripgrep
    smartmontools
    usbutils
    vim
    wget
  ];

  system.stateVersion = "26.05";
}
