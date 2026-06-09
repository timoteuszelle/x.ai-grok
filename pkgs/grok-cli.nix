{ lib
, stdenv
, stdenvNoCC
, fetchurl
, autoPatchelfHook
}:
let
  # Upstream Grok CLI version pinned by this package.
  version = "0.2.38";
  artifacts = {
    x86_64-linux = {
      url = "https://x.ai/cli/grok-${version}-linux-x86_64";
      hash = "sha256-Z0tHXiPhF/70jnQhRNVFEidt8C5JFhmp18kCIbeu4FM=";
    };
    aarch64-linux = {
      url = "https://x.ai/cli/grok-${version}-linux-aarch64";
      hash = "sha256-R3fnL6fKnlGA9cOIPQJfx91cCnZXBvXu72kkVRHWmDk=";
    };
  };
  artifact =
    artifacts.${stdenv.hostPlatform.system}
      or (throw "grok-cli: unsupported system ${stdenv.hostPlatform.system}. Add an artifact entry in pkgs/grok-cli.nix.");
in
stdenvNoCC.mkDerivation {
  pname = "grok-cli";
  inherit version;

  src = fetchurl {
    inherit (artifact) url hash;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/libexec/grok"
    mkdir -p "$out/bin"
    ln -s "$out/libexec/grok" "$out/bin/grok"
    ln -s "$out/libexec/grok" "$out/bin/agent"
    runHook postInstall
  '';

  meta = {
    description = "xAI Grok CLI packaged for Nix/NixOS";
    homepage = "https://x.ai";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames artifacts;
    mainProgram = "grok";
    maintainers = [ ];
  };
}
