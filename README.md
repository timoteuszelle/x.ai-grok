# x.ai-grok
Nix-native packaging for the xAI Grok CLI.

This repo avoids the mutable `curl -fsSL https://x.ai/cli/install.sh | bash` installer path and instead provides:
- Reproducible package (`pkgs/grok-cli.nix`) pinned by version and hash
- Flake outputs for package/app/dev shell
- NixOS module (`nixos.nix`)
- Home Manager module (`home.nix`)
- Non-flake compatibility (`default.nix`, `shell.nix`)

## Pinned upstream version
The source of truth for the pinned Grok CLI version is `pkgs/grok-cli.nix` (`version = "...";` plus architecture-specific hashes).

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
5. Create a git tag `v<current-version>` (matching `pkgs/grok-cli.nix`) and publish a GitHub Release with the same version tag to keep repository releases aligned with upstream Grok versioning.

## Automation (GitHub Actions)
This repository includes two workflows to automate updates and releases:

- `.github/workflows/update-grok-cli.yml`
  - Triggers: scheduled (`17 4,16 * * *`) and manual (`workflow_dispatch`)
  - Checks `https://x.ai/cli/stable` for the latest version
  - If newer than the current pin, updates:
    - `pkgs/grok-cli.nix` version
    - `pkgs/grok-cli.nix` x86_64 and aarch64 hashes
  - Runs validation (`nix flake show` and `NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#grok-cli`)
  - Opens a PR with the update and applies the `automerge` label

- `.github/workflows/release-from-pin.yml`
  - Triggers: push to `main` when `pkgs/grok-cli.nix` changes, and manual (`workflow_dispatch`)
  - Reads the pinned version from `pkgs/grok-cli.nix`
  - Uses tag format `v<version>`
  - Creates a release if missing, or reuses the existing release for that tag

- `.github/workflows/automerge-grok-cli-bumps.yml`
  - Triggers: `pull_request_target` changes and completed `check_suite` events
  - Targets only regular automated bump PRs (`chore: bump grok-cli to ...` on `chore/grok-cli-...`)
  - Requires:
    - PR author `github-actions[bot]`
    - `automerge` label (create this label once in the repository)
    - PR is open and non-draft
    - `mergeable_state == clean` (no conflicts and required checks green)
  - Enables GitHub auto-merge for matching PRs

Manual dispatch examples:
- `gh workflow run update-grok-cli.yml --repo timoteuszelle/x.ai-grok`
- `gh workflow run release-from-pin.yml --repo timoteuszelle/x.ai-grok`

Note: pushing workflow-file changes over HTTPS requires a token with `workflow` scope.

## License
Repository code: see `LICENSE`.
Upstream Grok CLI binary: licensed by xAI.
