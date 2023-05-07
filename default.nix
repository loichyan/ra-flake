{ pkgs
, lib
, darwin
, fetchFromGitHub
, libiconv
, makeRustPlatform
, stdenv
, ...
}:
let
  inherit (builtins) fromJSON isAttrs listToAttrs map readFile throw;
  inherit (lib) findFirst hasPrefix optionals;
in
rec {
  versions = fromJSON (readFile ./data/versions.json);
  findVersionFor = rust:
    findFirst
      (ver: hasPrefix rust ver.rust)
      (throw "Rust version ${rust} does not match any release")
      versions;
  make =
    { pname ? "rust-analyzer"
    , version
    , sha256 ? ""
    , outputHashes ? { }
    , cargo ? pkgs.cargo
    , rustc ? pkgs.rustc
    , override ? (_: { })
    }:
    let
      rustPlatform =
        makeRustPlatform { inherit cargo rustc; };
      ver =
        if isAttrs version && version ? "rust"
        then (findVersionFor version.rust).rust_analyzer
        else version;
      drv = rec {
        inherit pname;
        version = ver;
        src = fetchFromGitHub {
          owner = "rust-lang";
          repo = "rust-analyzer";
          rev = version;
          inherit sha256;
        };
        cargoLock = {
          inherit outputHashes;
          lockFile = "${src}/Cargo.lock";
        };
        buildInputs =
          optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreServices
            libiconv
          ];
        cargoBuildFlags = [ "-p" "rust-analyzer" ];
        doCheck = false;
        CARGO_INCREMENTAL = 0;
        RUST_ANALYZER_REV = version;
        meta = {
          description = "A modular compiler frontend for the Rust language";
          homepage = "https://rust-analyzer.github.io";
          license = with lib.licenses; [ mit asl20 ];
          mainProgram = "rust-analyzer";
        };
      };
    in
    rustPlatform.buildRustPackage (drv // override drv);
}
