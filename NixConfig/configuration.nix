{ config, lib, pkgs, ... }:

{

  imports = 
  [
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "Duk3-NIX";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  users.users.duk3 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "netoworkmanager" "video" "render" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --remember
        --remember-user-session --user-menu --cmd Hyprland";
        user = "duk3";
      };
    };
  };

  programs.hyprland = {
    enable = true; 
    xwayland.enable = true;
    withUWSM = true;
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    # Core
    vim wget git neovim neofetch ghostty fish

    # Hyprland
    hyprpaper waybar wofi

    # Utilities
    yazi tmux
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  system.stateVersion = "25.11";

}
