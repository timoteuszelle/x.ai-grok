{ pkgs ? import <nixpkgs> { } }:
pkgs.callPackage ./pkgs/grok-cli.nix { }
