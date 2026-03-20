{
  description = "Jacob's Golden Build - CachyOS Kernel Playground";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    # CachyOS Kernel for NixOS
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cosmic, nix-cachyos-kernel, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # LINE 27 FIXED: Using the plural nixosModules.default
        inputs.nix-cachyos-kernel.nixosModules.default
        ./configuration.nix
        ./hardware-configuration.nix
        ./nvidia.nix
        ./creative.nix
        nixos-cosmic.nixosModules.default
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
