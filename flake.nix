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
          overlays =
            let rustChannel = pkgs.rustChannelOf {
              channel = "stable";
              sha256 = "c522de65a51d139979f185f2bfbef61909a6be7d96e75c06370ad53fb778a9ea";
            };
            in [
              (import "${nixpkgs-mozilla}/rust-overlay.nix")
              (self: super:
                {
                  rustc = rustChannel.rust;
                  inherit (rustChannel) cargo rust rust-fmt rust-std clippy;
                  crate2nix = (import crate2nix { inherit pkgs; });
                }
              )
            ];
        };
        cargoNix = pkgs.callPackage ./Cargo.nix { 
          inherit pkgs; 
          defaultCrateOverrides = pkgs.defaultCrateOverrides // {
            bzip2-sys = attrs: {
              buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
                CoreFoundation
              ];
            };
          };
        };
      in {

        defaultPackage = cargoNix.rootCrate.build;
      });
}
