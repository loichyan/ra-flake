# 🦀 rust-analyzer-flake

A small flake that provides rust-analyzer for older versions of Rust.

## 🔍 Usage

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    ra-flake.url = "github:loichyan/ra-flake";
  };

  outputs = { nixpkgs, flake-utils, ra-flake, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ra-flake.overlays.default
          ];
        };
        rust-analyzer =
          pkgs.ra-flake.make {
            # Select the latest rust-analyzer between 1.56 and 1.57.
            version.rust = "1.56";
            # Or use a release tag directly.
            # version = "2021-11-29";

            # Checksum is required.
            sha256 = "sha256-vh7z8jupVxXPOko3sWUsOB7eji/7lKfwJ/CE3iw97Sw=";

            # Provide hashes of some git dependencies for early versions of rust-analyzer.
            # outputHashes = {
            #   "<crate>" = "<sha256>";
            # };

            # Replace the builtin toolchain with a custom one.
            # cargo = rust;
            # rustc = rust;

            # Additional arguments can be passed to buildRustPackage.
            # override = self: {
            #   "<key>" = "<value>";
            # };
          };
      in
      {
        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = [
              rust-analyzer
            ];
          };
        };
      }
    );
}
```

## ⚖️ License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  <http://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or
  <http://opensource.org/licenses/MIT>)

at your option.
