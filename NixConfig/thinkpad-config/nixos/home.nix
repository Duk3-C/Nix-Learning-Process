{ config, pkgs, pkgsUnstable, username, ... }:
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    packages = with pkgs; [
      firefox
      keepassxc
      libreoffice-fresh
      pavucontrol
      thunderbird
      pkgsUnstable.helix
    ];
  };

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
    foot = {
      enable = true;
      settings.main = {
        font = "JetBrainsMono Nerd Font:size=11";
        pad = "8x8";
      };
    };
    fuzzel.enable = true;
    waybar.enable = true;
  };

  services = {
    mako.enable = true;
    swayidle = {
      enable = true;
      events.before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      timeouts = [
        { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock -f"; }
        { timeout = 900; command = "${pkgs.systemd}/bin/systemctl suspend"; }
      ];
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    systemd.enable = true;
    config = {
      modifier = "Mod4";
      terminal = "foot";
      menu = "fuzzel";
      bars = [ { command = "waybar"; } ];
      input."type:touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
      };
      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
      in pkgs.lib.mkOptionDefault {
        "${mod}+Return" = "exec foot";
        "${mod}+d" = "exec fuzzel";
        "${mod}+Shift+s" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl set +10%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";
      };
    };
  };
}
