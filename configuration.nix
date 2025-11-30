{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ============================== VIRTUALIZATION FIX ==============================
  # This section enables the Libvirt daemon and QEMU/KVM for virtual machines.
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm; # Explicitly use the KVM-enabled QEMU package
  };
  # User 'paul' is already added to 'libvirtd' group below.
  # ==============================================================================

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "plexmediaserver" "steam" "steam-original" "steam-run" "steam-unwrapped"
      "vscode" "code" "vivaldi" "ventoy" "ventoy-bin" "ventoy-full"
    ];
  nixpkgs.config.permittedInsecurePackages = [
    "nextcloud-32.0.2"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 12;
  boot.plymouth.enable = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 8384 8096 32400 ];

  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true;
    pulse.enable = true; jack.enable = true;
  };

  users.users.paul = {
    isNormalUser = true;
    description  = "Paul Blazevic";
    # 'libvirtd' group is necessary for non-root virtualization management.
    extraGroups  = [ "wheel" "networkmanager" "libvirtd" "podman" "audio" "video" ];
    shell        = pkgs.fish;
    initialPassword = "nixos";
  };

  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  programs.xwayland.enable = true;

  # ─────────────────── FIX FOR KDE PLASMA AND SDDM ───────────────────
  # ENABLE XSERVER, SDDM LOGIN SCREEN, AND THE PLASMA DESKTOP.
  services.xserver.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  # Ensure Greetd is disabled if SDDM is enabled.
  services.greetd.enable = false;
  # ───────────────────────────────────────────────────────────────────

  services.nextcloud = { enable = true; package = pkgs.nextcloud32; hostName = "192.168.1.3"; https = false; configureRedis = true; config.dbtype = "sqlite"; config.adminpassFile = "/etc/nextcloud-admin-pass"; phpOptions."memory_limit" = lib.mkForce "2G"; };
  services.plex.enable = true; services.plex.openFirewall = true;
  services.jellyfin.enable = true; services.jellyfin.openFirewall = true;
  services.syncthing = { enable = true; user = "paul"; dataDir = "/home/paul/Sync"; configDir = "/home/paul/.config/syncthing"; openDefaultPorts = true; };
  services.cockpit.enable = true;
  services.cockpit.openFirewall = true;

    environment.systemPackages = with pkgs; [
    kitty waybar dunst rofi grim slurp wl-clipboard cliphist swaylock-effects swww wlogout hyprpicker hypridle
    fish starship eza bat ripgrep fd fzf neovim git curl wget fastfetch btop tmux zoxide
    firefox brave vivaldi tor-browser darktable gimp inkscape krita kdePackages.kdenlive vlc
    joplin-desktop homebank libreoffice-qt vscode-fhs signal-desktop telegram-desktop filezilla qbittorrent
    distrobox podman podman-desktop virt-manager
    (steam.override { extraPkgs = p: [ p.open-sans p.noto-fonts p.noto-fonts-cjk-sans p.roboto ]; })
    pavucontrol networkmanagerapplet blueman
    catppuccin-gtk catppuccin-cursors.mochaDark papirus-icon-theme libsForQt5.qtstyleplugin-kvantum catppuccin-kvantum
    # Removed: greetd.tuigreet (Since SDDM is enabled)
    cage
  ];

  fonts.packages = with pkgs; [
    noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji font-awesome material-design-icons
    nerd-fonts.jetbrains-mono nerd-fonts.fira-code nerd-fonts.meslo-lg nerd-fonts.ubuntu-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 30d"; };

  # Permanent /bin/bash fix
  systemd.services.create-bash-symlink = {
    description = "Create /bin/bash symlink";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /bin
      ln -sf /run/current-system/sw/bin/bash /bin/bash
    '';
  };

  # Fast Plex shutdown
  systemd.services.plexmediaserver.serviceConfig.TimeoutStopSec = "5";

  # Home Manager never fails
  home-manager.backupFileExtension = "hm-backup";

  system.stateVersion = "25.05";
}
