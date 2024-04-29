{
  description =
    "A simple to use wireguard wrapper to connect multiple networks";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = {...}:{
      nixosModules = rec {
        wireguard-wrapper = import ./wireguard-wrapper.nix;
        default = wireguard-wrapper;
      };
    };

}
