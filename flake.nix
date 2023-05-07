{
  description = "A little flake that provides rust-analyzer for older versions of Rust.";
  outputs = { ... }: {
    overlays.default = _: prev: {
      ra-flake = prev.callPackage ./. { };
    };
  };
}
