{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-mozilla = { url = github:mozilla/nixpkgs-mozilla; flake = false; };
    crate2nix = { url = github:kolloch/crate2nix; flake = false; };
    utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, nixpkgs-mozilla, crate2nix, utils }:# {
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        cargoNix = pkgs.callPackage ./Cargo.nix { 
          inherit pkgs; 
          defaultCrateOverrides = pkgs.defaultCrateOverrides // {
            bzip2-sys = attrs: {
              buildInputs = 
              with pkgs;
                stdenv.lib.optional stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
                  CoreFoundation
                ]);
            };
          };
        };
      in {

        defaultPackage = cargoNix.rootCrate.build;
      });
}
