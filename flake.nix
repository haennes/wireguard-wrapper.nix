{
  description =
    "A simple to use wireguard wrapper to connect multiple networks";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in {
      nixosModules = rec {
        wireguard-wrapper = import ./wireguard-wrapper.nix;
        default = wireguard-wrapper;
      };
    };

}
