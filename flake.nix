{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          pname = "sql_fun";
          version = "1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.cmake ];
          buildInputs = [ pkgs.gcc ];
          installPhase = ''
            mkdir -p $out/bin
            cp sql_fun $out/bin/
            cp compile_commands.json $out
          '';
        };
      };
    });
}
