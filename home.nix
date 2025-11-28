{ pkgs, ... }: {
  home.stateVersion = "25.05";

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;        # THIS creates /usr/share/wayland-sessions/hyprland.desktop
    xwayland.enable = true;
    extraConfig = ''
      monitor=,preferred,auto,1
      input { kb_layout = us }
      general { gaps_in = 5; gaps_out = 15; border_size = 2 }
      decoration { rounding = 8; drop_shadow = yes }
      $mod = SUPER
      bind = $mod, Return, exec, kitty
      bind = $mod, Q, killactive
      bind = $mod, D, exec, wofi --show drun
    '';
  };

  programs.tmux.enable = true;

  home.packages = with pkgs; [ kitty wofi waybar dunst grim slurp ];
}
