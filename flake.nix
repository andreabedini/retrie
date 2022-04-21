{
  description = "Retrie is a powerful, easy-to-use codemodding tool for Haskell.";

  inputs = {
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    haskellNix.url = "github:input-output-hk/haskell.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          retrie =
            final.haskell-nix.cabalProject' {
              src = ./.;
              compiler-nix-name = "ghc922";
              index-state = "2022-04-21T00:00:00Z";
              modules = [{ reinstallableLibGhc = true; }];
              shell.tools = {
                cabal = {};
              };
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.retrie.flake { };
    in flake // {
      defaultPackage = flake.packages."retrie:exe:retrie";
    });

  nixConfig = {
    extra-substituters = [
      "https://hydra.iohk.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };
}
