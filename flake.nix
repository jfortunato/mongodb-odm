{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { 
          inherit system;
          config.allowUnfree = true;
        };
        phpEnv = nixpkgs.legacyPackages.${system}.php83.buildEnv {
          extensions = { enabled, all }: enabled ++ (with all; [ mongodb bcmath ]);
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            phpEnv
            phpEnv.packages.composer
            mongodb-ce
          ];

          # Once we enter the shell, we should be able to start mongodb with:
          #   mongod --dbpath /tmp/mongodb-test-data --setParameter enableTestCommands=1
          shellHook = ''
            mkdir /tmp/mongodb-test-data
            ulimit -n 64000
          '';
        };
      }
    );
}
