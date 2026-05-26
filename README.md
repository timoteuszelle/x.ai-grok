# x.ai-grok
Nix-native packaging for the xAI Grok CLI.

This repo avoids the mutable `curl -fsSL https://x.ai/cli/install.sh | bash` installer path and instead provides:
- Reproducible package (`pkgs/grok-cli.nix`) pinned by version and hash
- Flake outputs for package/app/dev shell
- NixOS module (`nixos.nix`)
- Home Manager module (`home.nix`)
- Non-flake compatibility (`default.nix`, `shell.nix`)

## Why this exists
NixOS users usually want declarative, reproducible installs that:
- live in the Nix store
- work with rollbacks
- avoid mutating dotfiles and ad-hoc paths

## Quick start (flake)
Run Grok directly:
`nix run github:timoteuszelle/x.ai-grok#grok -- --help`

Install to your profile:
`nix profile install github:timoteuszelle/x.ai-grok#grok-cli`

Use as dev shell:
`nix develop github:timoteuszelle/x.ai-grok`

## NixOS module usage
In your flake inputs:
`xai-grok.url = "github:timoteuszelle/x.ai-grok";`

In your NixOS modules list:
`xai-grok.nixosModules.default`

Then enable:
`programs.grok-cli.enable = true;`

Optional package override:
`programs.grok-cli.package = pkgs.callPackage /path/to/your/custom-grok.nix { };`

## Home Manager usage
In your flake inputs:
`xai-grok.url = "github:timoteuszelle/x.ai-grok";`

In your Home Manager modules list:
`xai-grok.homeManagerModules.default`

Then enable:
`programs.grok-cli.enable = true;`

## Non-flake usage
From this repo directory:
- Install package with nix-env:
  `nix-env -if .`
- Start shell containing Grok:
  `nix-shell`

## Unfree package note
The upstream Grok binary is unfree, so Nix builds/installations may require:
- `nixpkgs.config.allowUnfree = true;`
or
- `NIXPKGS_ALLOW_UNFREE=1` (with `--impure` for flake commands)

## Updating to new Grok versions
1. Update `version` in `pkgs/grok-cli.nix`
2. Prefetch hashes:
   - `nix store prefetch-file --json https://x.ai/cli/grok-<version>-linux-x86_64`
   - `nix store prefetch-file --json https://x.ai/cli/grok-<version>-linux-aarch64`
3. Replace hashes in `pkgs/grok-cli.nix`
4. Validate:
   - `nix flake show`
   - `NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#grok-cli`

## License
Repository code: see `LICENSE`.
Upstream Grok CLI binary: licensed by xAI.
