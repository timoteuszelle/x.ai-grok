{ config, lib, pkgs, ... }:
let
  cfg = config.programs.grok-cli;
in
{
  options.programs.grok-cli = {
    enable = lib.mkEnableOption "xAI Grok CLI";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./pkgs/grok-cli.nix { };
      description = "Grok CLI package to install system-wide.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
