{
  description = "Nix devshell for Kast Mommy, a Mommy alternative written in Kast";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kast.url = "github:kast-lang/kast";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = import inputs.nixpkgs { inherit system overlays; };
        kast = inputs.kast.packages.${system}.default;
      in with pkgs; {
        devShells.default = mkShell {
          packages = [
            (pkgs.writeShellScriptBin "kast" ''
               ${kast}/bin/kast "$@"
            '')
          ];
        };
      });
}
