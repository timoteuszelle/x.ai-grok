{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  packages = [
    (pkgs.callPackage ./pkgs/grok-cli.nix { })
  ];
}
