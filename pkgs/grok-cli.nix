{ lib
, stdenv
, stdenvNoCC
, fetchurl
, autoPatchelfHook
}:
let
  # Upstream Grok CLI version pinned by this package.
  version = "0.2.14";
  artifacts = {
    x86_64-linux = {
      url = "https://x.ai/cli/grok-${version}-linux-x86_64";
      hash = "sha256-B78S/zoE2vo6LemYcJH7onU+/DRNE7F7KzgaEX55NBg=";
    };
    aarch64-linux = {
      url = "https://x.ai/cli/grok-${version}-linux-aarch64";
      hash = "sha256-0Cmt7Qm3f+4LyKCxFGJ0a/IMIzwHgWVjWRHORo0KZG4=";
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
