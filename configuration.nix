{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # 🚀 SYSTEM BASE
  # ==============================================================================
  system.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "plexmediaserver" "steam" "steam-original" "steam-run" "steam-unwrapped"
      "vscode" "code" "vivaldi"
    ];
  nixpkgs.config.permittedInsecurePackages = [
    "nextcloud-32.0.2"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 30d"; };

  # 🖥️ VIRTUALIZATION & CONTAINER FIX
  # ==============================================================================
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

  # 🌐 NETWORKING & FIREWALL
  # ==============================================================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 8384 8096 32400 9090 ];

  # ⚙️ BOOTLOADER & PLYMOUTH
  # ==============================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 12;
  boot.plymouth.enable = true;

  # 👤 USER & GROUPS
  # ==============================================================================
  users.users.paul = {
    isNormalUser = true;
    description  = "Paul Blazevic";
    extraGroups  = [ "wheel" "networkmanager" "libvirtd" "podman" "audio" "video" ];
    shell        = pkgs.fish;
    initialPassword = "nixos";
  };

  # 🎨 DISPLAY, DE & SHELL
  # ==============================================================================
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  # SDDM, XSERVER, AND PLASMA 6
  services.xserver.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.greetd.enable = false;

  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  programs.xwayland.enable = true;

  # 🔊 AUDIO
  # ==============================================================================
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true;
    pulse.enable = true; jack.enable = true;
  };

  # ☁️ SERVICES
  # ==============================================================================
  services.flatpak = {
    enable = true;
    openFirewall = true;
  };
  services.cockpit = {
    enable = true;
    openFirewall = true;
  };
  services.nextcloud = {
    enable = true; package = pkgs.nextcloud32; hostName = "192.168.1.3"; https = false; configureRedis = true; config.dbtype = "sqlite";
    config.adminpassFile = "/etc/nextcloud-admin-pass"; phpOptions."memory_limit" = lib.mkForce "2G";
  };
  services.plex.enable = true; services.plex.openFirewall = true;
  services.syncthing = {
    enable = true; user = "paul"; dataDir = "/home/paul/Sync"; configDir = "/home/paul/.config/syncthing"; openDefaultPorts = true;
  };

  # 🛠️ SYSTEMD FIXES
  # ==============================================================================
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

  # 📦 ENVIRONMENT PACKAGES (FIXED)
  # ==============================================================================
  environment.systemPackages = [
    # --- 1. Window Management (Hyprland & Dependencies) ---
    pkgs.kitty pkgs.waybar pkgs.dunst pkgs.rofi pkgs.grim pkgs.slurp pkgs.wl-clipboard
    pkgs.cliphist pkgs.swaylock-effects pkgs.swww pkgs.wlogout pkgs.hyprpicker pkgs.hypridle
    pkgs.kdePackages.discover pkgs.impression pkgs.kdePackages.partitionmanager

    # --- 2. Shell & Terminal Utilities ---
    pkgs.fish pkgs.starship pkgs.eza pkgs.bat pkgs.ripgrep pkgs.fd pkgs.fzf pkgs.neovim
    pkgs.git pkgs.curl pkgs.wget pkgs.fastfetch pkgs.btop pkgs.tmux pkgs.zoxide pkgs.zip pkgs.unzip
    pkgs.flatpak

    # --- 3. Cockpit Extensions (Management) ---
    pkgs.cockpit

    # --- 4. Virtualization & Containers (Fixed) ---
    pkgs.distrobox pkgs.podman pkgs.podman-desktop pkgs.virt-manager pkgs.gnome-boxes
    # 🌟 FINAL FIX: Use the full package name for QEMU utilities like qemu-img
    pkgs.qemu_kvm

    # --- 5. Browsers & Media Applications ---
    pkgs.firefox pkgs.brave pkgs.vivaldi pkgs.tor-browser pkgs.darktable pkgs.gimp
    pkgs.inkscape pkgs.krita pkgs.kdePackages.kdenlive pkgs.vlc

    # --- 6. Productivity & Communication ---
    pkgs.joplin-desktop pkgs.homebank pkgs.libreoffice-qt pkgs.vscode-fhs pkgs.signal-desktop
    pkgs.telegram-desktop pkgs.filezilla pkgs.qbittorrent

    # --- 7. System Tools & Utilities ---
    pkgs.pavucontrol pkgs.networkmanagerapplet pkgs.blueman

    # --- 8. Theming (GTK/Qt/Icons) ---
    pkgs.catppuccin-gtk pkgs.catppuccin-cursors.mochaDark pkgs.papirus-icon-theme
    pkgs.libsForQt5.qtstyleplugin-kvantum pkgs.catppuccin-kvantum

    # --- 9. Special Packages (Overrides/Functions) ---
    (pkgs.steam.override { extraPkgs = p: [ p.open-sans p.noto-fonts p.noto-fonts-cjk-sans p.roboto ]; })
    pkgs.cage
  ];

  # ✏️ FONTS
  # ==============================================================================
  fonts.packages = with pkgs; [
    noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji font-awesome material-design-icons
    nerd-fonts.jetbrains-mono nerd-fonts.fira-code nerd-fonts.meslo-lg nerd-fonts.ubuntu-mono
  ];

  # 🏠 HOME MANAGER
  # ==============================================================================
  home-manager.backupFileExtension = "hm-backup";
}
