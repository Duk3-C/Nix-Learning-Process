{
  
  home.username = "duk3";
  home.homeDirectory = "/home/orlando";
  home.stateVersion = "25.11";
  programs.fish = {
    enable = true;
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec uwsm start -S hyprland-uwsm.desktop
      fi
    '';
  };
}
