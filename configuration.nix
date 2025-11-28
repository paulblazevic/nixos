{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "plexmediaserver" "steam" "steam-original" "steam-run" "steam-unwrapped"
      "vscode" "code" "vivaldi" "ventoy" "ventoy-bin" "ventoy-full"
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "nextcloud-30.0.17"
    "ventoy-1.0.97"
    "ventoy-1.1.05"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 12;
  boot.loader.timeout = 3;
  boot.plymouth.enable = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 8384 32400 ];

  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true;
    pulse.enable = true; jack.enable = true;
  };

  users.users.paul = {
    isNormalUser = true;
    description = "Paul Blazevic";
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "podman" "audio" "video" ];
    shell = pkgs.fish;
    initialPassword = "nixos";
  };

  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.dconf.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha";
  };
  services.desktopManager.plasma6.enable = true;
  services.upower.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-hyprland ];
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
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

  environment.systemPackages = with pkgs; [
    kitty waybar dunst rofi-wayland grim slurp wl-clipboard cliphist swaylock-effects swww wlogout hyprpicker hypridle
    fish starship eza bat ripgrep fd fzf neovim git curl wget fastfetch btop htop tmux zoxide
    firefox brave vivaldi tor-browser-bundle-bin darktable gimp inkscape krita kdePackages.kdenlive vlc
    joplin-desktop homebank libreoffice-qt vscode-fhs signal-desktop tdesktop filezilla qbittorrent
    distrobox podman podman-desktop virt-manager gnome-boxes ventoy-full
    (steam.override { extraPkgs = p: [ p.open-sans p.noto-fonts p.noto-fonts-cjk-sans p.roboto ]; })
    pavucontrol networkmanagerapplet blueman catppuccin-gtk catppuccin-kvantum papirus-icon-theme catppuccin-cursors.mochaDark
  ];

  fonts.packages = with pkgs; [
    noto-fonts noto-fonts-cjk-sans noto-fonts-emoji font-awesome material-design-icons
    nerd-fonts.jetbrains-mono nerd-fonts.fira-code nerd-fonts.meslo-lg nerd-fonts.ubuntu-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 30d"; };

  system.activationScripts.wallpaper.text = ''
    mkdir -p /home/paul/Pictures/Wallpapers
    [ -f /home/paul/Pictures/Wallpapers/catppuccin-anime.jpg ] || curl -L -o /home/paul/Pictures/Wallpapers/catppuccin-anime.jpg https://w.wallhaven.cc/full/9m/wallhaven-9m8k7v.jpg
  '';


