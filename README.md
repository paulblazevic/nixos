# NixOS Fleet Configuration

Complete NixOS configuration for deploying 5+ identical machines with professional workstation capabilities.

## 🚀 Features

### Desktop Environments
- **KDE Plasma 6** - Full-featured desktop (default)
- **Hyprland** - Beautiful tiling Wayland compositor with Catppuccin theme

### Professional Software Suite
- **CAD/3D**: FreeCAD, LibreCAD, OpenSCAD, Blender, SweetHome3D
- **3D Printing**: PrusaSlicer, Cura, OrcaSlicer
- **Graphics**: GIMP, Inkscape, Krita, Darktable, RawTherapee, Digikam, Scribus
- **Video**: DaVinci Resolve, Kdenlive, Shotcut, OBS Studio, Handbrake
- **Electronics**: KiCad

### Infrastructure
- **Virtualization**: Podman, Virt-Manager, QEMU/KVM
- **Network Sharing**: Samba (SMB) with full admin access
- **Services**: Plex Media Server, Nextcloud, Syncthing, Cockpit
- **Development**: VSCode, Git, complete toolchain

---

## 📋 Repository Structure

```
/etc/nixos/
├── configuration.nix       # Main system configuration
├── flake.nix              # Flake configuration for fleet management
├── flake.lock             # Locked dependencies
├── home.nix               # User configuration (Hyprland setup)
└── hardware-configuration.nix  # AUTO-GENERATED per machine (DO NOT COPY)
```

---

## 🖥️ Replicating to New Machines

### Prerequisites
- NixOS 25.11 installer USB
- Internet connection
- This GitHub repository: `https://github.com/paulblazevic/nixos`

---

## 📝 Step-by-Step Installation

### STEP 1: Boot NixOS Installer

Boot from NixOS installer USB on your new machine.

---

### STEP 2: Partition and Format Drives

**For UEFI systems:**

```bash
# Partition the disk
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/sda -- set 1 esp on
sudo parted /dev/sda -- mkpart primary 512MiB 100%

# Format partitions
sudo mkfs.fat -F 32 -n boot /dev/sda1
sudo mkfs.ext4 -L nixos /dev/sda2

# Mount filesystems
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

**For BIOS/Legacy systems:**

```bash
sudo parted /dev/sda -- mklabel msdos
sudo parted /dev/sda -- mkpart primary 1MiB 100%
sudo mkfs.ext4 -L nixos /dev/sda1
sudo mount /dev/disk/by-label/nixos /mnt
```

---

### STEP 3: Generate Hardware Configuration

```bash
sudo nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/hardware-configuration.nix` specific to this machine's hardware.

---

### STEP 4: Clone Fleet Configuration from GitHub

**First, set up GitHub authentication:**

```bash
# Create a credential file on the installer (replace YOUR_TOKEN with your actual token)
cat > /tmp/git-credentials << 'EOF'
https://paulblazevic:YOUR_TOKEN@github.com
EOF

sudo cp /tmp/git-credentials /root/.git-credentials
sudo chmod 600 /root/.git-credentials
rm /tmp/git-credentials
```

**Now clone the repository:**

```bash
# Save the auto-generated hardware config
sudo mv /mnt/etc/nixos/hardware-configuration.nix /tmp/hardware-configuration.nix

# Remove default configs
sudo rm -rf /mnt/etc/nixos/*

# Clone the fleet configuration
cd /mnt/etc
sudo git clone https://github.com/paulblazevic/nixos.git nixos

# Restore hardware-specific config
sudo mv /tmp/hardware-configuration.nix /mnt/etc/nixos/

# Set proper permissions
sudo chown -R root:root /mnt/etc/nixos

# Configure git
cd /mnt/etc/nixos
sudo git config user.name "paulblazevic"
sudo git config user.email "paul@blazevic.com.au"
sudo git config credential.helper store
```

---

### STEP 5: Customize Machine Identity

Edit the hostname for this specific machine:

```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

**Find and change these lines:**

```nix
# Change hostname (line ~27)
networking.hostName = "clone1";  # Change to: clone1, clone2, clone3, etc.

# Change Samba identity for network discovery (around line ~100)
services.samba.settings.global = {
  "workgroup" = "WORKGROUP";
  "server string" = "clone1";      # Match hostname
  "netbios name" = "clone1";       # Match hostname
  # ... rest of config
};
```

**Save and exit** (Ctrl+X, Y, Enter)

---

### STEP 6: Add Machine to Flake (if needed)

If you're creating **clone4** or higher, add it to `flake.nix`:

```bash
sudo nano /mnt/etc/nixos/flake.nix
```

Add your new machine:

```nix
outputs = { self, nixpkgs, home-manager, ... }:
let
  system = "x86_64-linux";
  commonModules = [ ./configuration.nix ./home.nix ];
in {
  nixosConfigurations.paulsbox = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      ./configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.paul = import ./home.nix;
      }
    ];
  };
  
  nixosConfigurations.clone1 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
  nixosConfigurations.clone2 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
  nixosConfigurations.clone3 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
  nixosConfigurations.clone4 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };  # ADD THIS
  nixosConfigurations.clone5 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };  # ADD THIS
};
```

---

### STEP 7: Install NixOS

```bash
# Install using the flake configuration
sudo nixos-install --flake /mnt/etc/nixos#clone1  # Use your machine name

# When prompted, set the root password
# Enter new UNIX password for root: ********
```

Installation will take 15-30 minutes depending on internet speed.

---

### STEP 8: Reboot

```bash
sudo reboot
```

Remove the installer USB and boot into your new system.

---

## ⚙️ Post-Installation Setup

### First Login

Login as user: **paul**  
Default password: **nixos**

### Essential Setup Commands

```bash
# 1. Change your user password
passwd

# 2. Set Samba password for network sharing
sudo smbpasswd -a paul

# 3. Create directories for Hyprland
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Pictures/Screenshots

# 4. (Optional) Download a wallpaper
# Place your wallpaper at: ~/Pictures/Wallpapers/wallpaper.jpg
```

### Test Network Sharing

From another device on your network:
- Windows: `\\clone1\home` or `\\clone1\root`
- Mac: `smb://clone1/home` or `smb://clone1/root`
- Linux: `smb://clone1/home` or `smb://clone1/root`

---

## 🎨 Using Hyprland

### Switch to Hyprland

1. Log out of KDE Plasma
2. At SDDM login screen, select **Hyprland** from session dropdown
3. Log in

### Key Bindings (SUPER = Windows Key)

**Essential Shortcuts:**
- `SUPER + RETURN` - Terminal (Kitty)
- `SUPER + D` - App launcher (Wofi)
- `SUPER + Q` - Close window
- `SUPER + B` - Firefox browser
- `SUPER + E` - Thunar file manager

**Window Management:**
- `SUPER + H/J/K/L` - Move focus (Vim keys)
- `SUPER + 1-9` - Switch workspace
- `SUPER + SHIFT + 1-9` - Move window to workspace
- `SUPER + F` - Toggle fullscreen

**Screenshots:**
- `SUPER + SHIFT + S` - Screenshot selection

---

## 🔄 Updating All Machines

### Making Changes

**On any machine where you make changes:**

```bash
cd /etc/nixos

# Make your edits to configuration.nix, home.nix, etc.

# Test locally first
sudo nixos-rebuild switch --flake .#clone1  # Use correct machine name

# If everything works, commit and push
git add .
git commit -m "Description of changes"
git push origin main
```

### Pulling Updates to Other Machines

**On all other machines:**

```bash
cd /etc/nixos

# Pull latest changes from GitHub
sudo git pull origin main

# Rebuild with new configuration
sudo nixos-rebuild switch --flake .#clone2  # Use correct machine name

# Reboot if kernel or major system changes
sudo reboot
```

---

## 🔑 GitHub Authentication Setup

**Store your credentials locally on each machine (never pushed to GitHub):**

```bash
# Replace YOUR_TOKEN with your actual GitHub Personal Access Token
echo "https://paulblazevic:YOUR_TOKEN@github.com" | sudo tee /root/.git-credentials
sudo chmod 600 /root/.git-credentials

cd /etc/nixos
sudo git config credential.helper store
```

Keep your token in a secure note - you'll need it for each new machine installation.

---

## 🛠️ Troubleshooting

### Cannot access network shares

```bash
# Restart Samba services
sudo systemctl restart smbd nmbd

# Check firewall
sudo systemctl status firewall
```

### Hyprland crashes or won't start

```bash
# Switch back to KDE Plasma from TTY
sudo systemctl restart sddm
```

### Git sync issues

```bash
cd /etc/nixos

# Check status
git status

# If conflicts, reset to remote
git fetch origin
git reset --hard origin/main
```

---

## 📦 Installed Software Summary

### Desktop & Window Managers
- KDE Plasma 6, Hyprland, Waybar, Rofi, Dunst

### File Managers
- Nemo (with network support), Thunar, Dolphin (KDE)

### Browsers
- Firefox, Brave, Vivaldi, Tor Browser

### CAD & Engineering
- FreeCAD, LibreCAD, OpenSCAD, Blender, SweetHome3D, KiCad

### 3D Printing
- PrusaSlicer, Cura, OrcaSlicer

### Graphics & Photo
- GIMP, Inkscape, Krita, Darktable, RawTherapee, Digikam, Scribus

### Video Production
- DaVinci Resolve, Kdenlive, Shotcut, OBS Studio, Handbrake, VLC

### Productivity
- LibreOffice, VSCode, Joplin, Homebank

### Communication
- Signal, Telegram

### Virtualization & Containers
- Podman, Virt-Manager, QEMU/KVM, Distrobox

### Network Services
- Samba, Plex, Nextcloud, Syncthing, Cockpit

---

## 🎯 Machine Naming Convention

- **paulsbox** - Main/primary machine
- **clone1** - First replica
- **clone2** - Second replica
- **clone3** - Third replica
- etc.

Each machine is 99% identical with only hardware-specific and hostname differences.

---

## 📊 System Specifications

- **OS**: NixOS 25.11 (unstable)
- **Desktop**: KDE Plasma 6 / Hyprland
- **Shell**: Fish with Starship prompt
- **Theme**: Catppuccin Mocha
- **Network**: Full SMB sharing with guest and authenticated access

---

## 🤝 Contributing

This is a personal fleet configuration, but feel free to fork and adapt for your own use!

---

## 📝 License

Personal use configuration - adapt as needed for your own systems.

---

## 🎉 Credits

Built by Paul Blazevic for managing a fleet of identical NixOS workstations.

**Inspired by:**
- end_4's Hyprland dotfiles
- NixOS community configurations

---

**Last Updated**: December 2024  
**Repository**: https://github.com/paulblazevic/nixos
