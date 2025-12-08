{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "plexmediaserver" "steam" "steam-original" "steam-run" "steam-unwrapped"
      "vscode" "code" "vivaldi" "davinci-resolve" "davinci-resolve-studio"
    ];
  nixpkgs.config.permittedInsecurePackages = [ "nextcloud-32.0.2" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 30d"; };

  virtualisation.podman.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = true;
    qemu.package = pkgs.qemu_kvm;
    qemu.swtpm.enable = true;
  };

  programs.virt-manager.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  networking.hostName = "elitedeskg4";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 8384 8096 32400 9090 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 5353 ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 12;
  boot.plymouth.enable = true;

  users.users.paul = {
    isNormalUser = true;
    description = "Paul Blazevic";
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "podman" "audio" "video" ];
    shell = pkgs.fish;
    initialPassword = "nixos";
  };

  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "paul";
  };
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  services.greetd.enable = false;

  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  programs.xwayland.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # GPU support for DaVinci Resolve
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.flatpak.enable = true;
  services.cockpit = { enable = true; openFirewall = true; };
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "192.168.1.3";
    https = false;
    configureRedis = true;
    config.dbtype = "sqlite";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    phpOptions."memory_limit" = lib.mkForce "2G";
  };
  services.plex.enable = true;
  services.plex.openFirewall = true;
  services.syncthing = {
    enable = true;
    user = "paul";
    dataDir = "/home/paul/Sync";
    configDir = "/home/paul/.config/syncthing";
    openDefaultPorts = true;
  };

  # Network discovery and file sharing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "elitedeskg4";
        "netbios name" = "elitedeskg4";
        "security" = "user";
        "hosts allow" = "192.168.1. 127.0.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "home" = {
        "path" = "/home/paul";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "paul";
        "force user" = "paul";
        "force group" = "users";
        "create mask" = "0755";
        "directory mask" = "0755";
        "writable" = "yes";
      };
      "root" = {
        "path" = "/";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "paul";
        "force user" = "root";
        "force group" = "root";
        "create mask" = "0755";
        "directory mask" = "0755";
        "writable" = "yes";
        "admin users" = "paul";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.create-bash-symlink = {
    description = "Create /bin/bash symlink";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /bin
      ln -sf /run/current-system/sw/bin/bash /bin/bash
    '';
  };
  systemd.services.plexmediaserver.serviceConfig.TimeoutStopSec = "5";

  environment.systemPackages = [
    # Hyprland ecosystem
    pkgs.kitty
    pkgs.alacritty
    pkgs.waybar
    pkgs.ags
    pkgs.dunst
    pkgs.mako
    pkgs.rofi
    pkgs.wofi
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.cliphist
    pkgs.swaylock-effects
    pkgs.swww
    pkgs.hyprpaper
    pkgs.wlogout
    pkgs.hyprpicker
    pkgs.hypridle
    pkgs.hyprlock
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.pamixer
    pkgs.networkmanagerapplet
    pkgs.kdePackages.polkit-kde-agent-1
    # KDE/Desktop
    pkgs.kdePackages.discover
    pkgs.impression
    pkgs.kdePackages.partitionmanager
    pkgs.nemo
    pkgs.nemo-with-extensions
    pkgs.cinnamon-common
    pkgs.gvfs
    pkgs.xfce.thunar
    pkgs.xfce.thunar-volman
    pkgs.xfce.thunar-archive-plugin
    # Shell/CLI tools
    pkgs.fish
    pkgs.starship
    pkgs.neovim
    pkgs.git
    pkgs.curl
    pkgs.btop
    pkgs.zip
    pkgs.unzip
    pkgs.jq
    pkgs.socat
    pkgs.python3
    pkgs.flatpak
    pkgs.samba
    pkgs.cockpit
    pkgs.distrobox
    pkgs.podman
    pkgs.podman-desktop
    pkgs.virt-manager
    pkgs.gnome-boxes
    pkgs.qemu_kvm
    pkgs.firefox
    pkgs.brave
    pkgs.vivaldi
    pkgs.tor-browser
    # Graphics/Photo/Design
    pkgs.darktable
    pkgs.gimp
    pkgs.inkscape
    pkgs.krita
    pkgs.blender
    pkgs.scribus
    pkgs.digikam
    pkgs.rawtherapee
    # Video editing/production
    pkgs.kdePackages.kdenlive
    pkgs.vlc
    pkgs.obs-studio
    pkgs.handbrake
    pkgs.shotcut
    pkgs.davinci-resolve
    # pkgs.davinci-resolve-studio  # Uncomment if you have the Studio license
    pkgs.ffmpeg-full
    # Productivity
    pkgs.joplin-desktop
    pkgs.homebank
    pkgs.libreoffice-qt
    pkgs.vscode-fhs

    # CAD/3D/Engineering
    pkgs.freecad
    pkgs.librecad
    pkgs.openscad
    pkgs.sweethome3d.application
    pkgs.kicad

    # 3D Printing
    pkgs.prusa-slicer
    pkgs.cura
    pkgs.orca-slicer
    pkgs.signal-desktop
    pkgs.telegram-desktop
    pkgs.filezilla
    pkgs.qbittorrent
    pkgs.pavucontrol
    pkgs.networkmanagerapplet
    pkgs.blueman
    pkgs.catppuccin-gtk
    pkgs.catppuccin-cursors.mochaDark
    pkgs.papirus-icon-theme
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.catppuccin-kvantum
    (pkgs.steam.override { extraPkgs = p: [ p.open-sans p.noto-fonts p.noto-fonts-cjk-sans p.roboto ]; })
    pkgs.cage
  ];

  fonts.packages = [
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-color-emoji
    pkgs.font-awesome
    pkgs.material-design-icons
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.meslo-lg
    pkgs.nerd-fonts.ubuntu-mono
  ];

  home-manager.backupFileExtension = "hm-backup";
}
