{
  description = "Nix-native xAI Grok CLI package and modules (flake + Home Manager + plain NixOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
    in
    {
      overlays.default = final: _prev: {
        grok-cli = final.callPackage ./pkgs/grok-cli.nix { };
      };

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          grok-cli = pkgs.callPackage ./pkgs/grok-cli.nix { };
          default = self.packages.${system}.grok-cli;
        });

      apps = forAllSystems (system: {
        grok = {
          type = "app";
          program = "${self.packages.${system}.grok-cli}/bin/grok";
        };
        default = self.apps.${system}.grok;
      });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [ self.packages.${system}.grok-cli ];
          };
        });

      nixosModules.default = import ./nixos.nix;
      homeManagerModules.default = import ./home.nix;
      homeModules = self.homeManagerModules;
    };
}
