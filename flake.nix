{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-ustable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs: {
    nixosConfigurations.tankles = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs system;
      };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
