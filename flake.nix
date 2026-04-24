{
  description = "Acer WMI extensions for fan control and battery charging";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages."${system}".default = pkgs.callPackage ./default.nix {
        kernel = pkgs.linux;
      };
    };
}