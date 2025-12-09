nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {  # Changed from "paulsbox"
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

# Clone machines
nixosConfigurations.nixos1 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
nixosConfigurations.nixos2 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
nixosConfigurations.nixos3 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
nixosConfigurations.nixos4 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
nixosConfigurations.nixos5 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
