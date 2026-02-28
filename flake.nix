{
  description = "Jacob's NixOS Golden Build - Modular Flake Configuration";

  inputs = {
    # NixOS official package source (25.11 Xantusia branch)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Home Manager source matching the system version
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # System hostname: nixos
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        # Integrates Home Manager logic into the system build
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
