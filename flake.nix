{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    forSystems = lib.genAttrs ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [inputs.fenix.overlays.default];
      };
  in {
    devShells = forSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShell {
        name = "kakounite-dev";
        packages = with pkgs; [
          cachix
          cargo-expand
          fenix.stable.toolchain
          gtk4
          openssl
          pkg-config
        ];
        RUST_BACKTRACE = 1;
        shellHook = ''[ -n "$PS1" ] && exec $SHELL'';
      };
    });
  };
}
