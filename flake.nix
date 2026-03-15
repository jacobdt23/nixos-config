{
  description = "Jacob's NixOS Golden Build - Modular Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ADD THIS: The Stable COSMIC Epoch 1 Flake
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
  };

  outputs = { self, nixpkgs, home-manager, nixos-cosmic, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        # ADD THIS: Pulls in the COSMIC logic
        nixos-cosmic.nixosModules.default
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
