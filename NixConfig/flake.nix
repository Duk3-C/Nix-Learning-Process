{

  description = "Hyprland";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfiguration.Duk3-NIX = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.duk3 = import ./home.nix;
          };
        }
      ];
    };
  }; 
  

}
