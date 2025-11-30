{
  description = "Paul's fleet — main machine + 5+ identical clones";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    commonModules = [ ./configuration.nix ./home.nix ];
  in {
    # Your main machine
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

    # Future identical clones (just add more when you get them)
    nixosConfigurations.clone1 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
    nixosConfigurations.clone2 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
    nixosConfigurations.clone3 = nixpkgs.lib.nixosSystem { inherit system; modules = commonModules; };
    # …add clone4, clone5, etc. whenever you want
  };
}
