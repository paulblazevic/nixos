{ pkgs, lib, ... }: {
  home.stateVersion = "25.05";
  
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    xwayland.enable = true;
    extraConfig = ''
      monitor=,preferred,auto,1
      
      exec-once = swww-daemon
      exec-once = sleep 1 && swww img ~/Pictures/Wallpapers/catppuccin-anime.jpg
      exec-once = waybar
      exec-once = dunst
      exec-once = wl-paste --type text --watch cliphist store
      exec-once = nm-applet --indicator
      
      env = XCURSOR_SIZE,24
      
      input {
        kb_layout = us
        follow_mouse = 1
        touchpad { natural_scroll = true }
      }
      
      general {
        gaps_in = 8
        gaps_out = 16
        border_size = 3
        col.active_border = rgba(89b4faff) rgba(cba6f7ff) 45deg
        col.inactive_border = rgba(313244aa)
        layout = dwindle
      }
      
      decoration {
        rounding = 16
        blur { enabled = true; size = 6; passes = 3; }
        drop_shadow = true
        shadow_range = 20
      }
      
      animations {
        enabled = yes
        bezier = wind, 0.05, 0.9, 0.1, 1.05
        animation = windows, 1, 6, wind, slide
        animation = fade, 1, 10, default
        animation = workspaces, 1, 5, wind
      }
      
      $mod = SUPER
      bind = $mod, Return, exec, kitty
      bind = $mod, T, exec, kitty
      bind = $mod, Q, killactive
      bind = $mod, M, exit
      bind = $mod, D, exec, wofi --show drun
      bind = $mod, F, fullscreen
      bind = $mod, V, exec, cliphist list | wofi -dmenu | cliphist decode | wl-copy
      bind = $mod SHIFT, S, exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%s).png
      
      bind = $mod, left, movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up, movefocus, u
      bind = $mod, down, movefocus, d
      
      ${lib.concatMapStringsSep "\n" (i: 
        "bind = $mod, ${toString i}, workspace, ${toString i}\nbind = $mod SHIFT, ${toString i}, movetoworkspace, ${toString i}"
      ) (lib.range 1 9)}
      
      windowrulev2 = opacity 0.90 0.90,class:^(kitty)$
      windowrulev2 = opacity 0.90 0.90,class:^(Code)$
    '';
  };
  
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 40;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" ];
      
      clock.format = " {:%H:%M}";
      cpu.format = " {usage}%";
      memory.format = " {}%";
      pulseaudio.format = "{icon} {volume}%";
      network.format-wifi = " {essid}";
      battery.format = "{icon} {capacity}%";
    };
    style = ''
      * { font-family: monospace; font-size: 13px; }
      window#waybar { background: rgba(30,30,46,0.8); color: #cdd6f4; }
      #workspaces button { padding: 0 10px; color: #6c7086; }
      #workspaces button.active { color: #89b4fa; background: rgba(137,180,250,0.2); }
      #clock, #cpu, #memory, #pulseaudio, #network, #battery { padding: 0 12px; margin: 5px 3px; background: rgba(49,50,68,0.6); border-radius: 12px; }
    '';
  };
}
