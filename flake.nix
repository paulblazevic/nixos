{
  description = "Paul's fleet — main machine + 5+ identical clones";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
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
    nixosConfigurations.clone1 = nixpkgs.lib.nixosSystem { inherit system; modules = [ ./configuration.nix ./home.nix ]; };
    nixosConfigurations.clone2 = nixpkgs.lib.nixosSystem { inherit system; modules = [ ./configuration.nix ./home.nix ]; };
    nixosConfigurations.clone3 = nixpkgs.lib.nixosSystem { inherit system; modules = [ ./configuration.nix ./home.nix ]; };
    # …add clone4, clone5, etc. whenever you want
  };
}
