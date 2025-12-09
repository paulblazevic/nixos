{
  description = "Paul's NixOS fleet - nixos + clones";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    commonModules = [ 
      ./configuration.nix 
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.paul = import ./home.nix;
      }
    ];
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules;
    };
    
    nixosConfigurations.nixos1 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules;
    };
    
    nixosConfigurations.nixos2 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules;
    };
    
    nixosConfigurations.nixos3 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules;
    };
    
    nixosConfigurations.nixos4 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules;
    };
    
    nixosConfigurations.nixos5 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = commonModules;
    };
  };
}
