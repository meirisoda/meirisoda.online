{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    gitignore.url = "github:hercules-ci/gitignore.nix";
    htms.url = "github:tnichols217/htms";
  };
  outputs = {...} @ inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = (import inputs.nixpkgs) {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in {
        devShells = rec {
          htms-shell = pkgs.mkShell {
            packages = with pkgs; [
              inputs.htms.packages.${system}.htms
            ];
          };
          default = htms-shell;
        };
        formatter = let
          treefmtconfig = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs = {
              alejandra.enable = true;
              black.enable = true;
              toml-sort.enable = true;
              yamlfmt.enable = true;
              mdformat.enable = true;
              prettier.enable = true;
              shellcheck.enable = true;
              shfmt.enable = true;
            };
            settings.formatter.shellcheck.excludes = [".envrc"];
          };
        in
          treefmtconfig.config.build.wrapper;
        apps = rec {
          build = {
            type = "app";
            program = ''${pkgs.writeShellScriptBin "build" ''
                ${inputs.htms.packages.${system}.htms}/bin/htms build -i ./src -o ./out -c ./config.nix
              ''}/bin/build'';
          };
          watch = {
            type = "app";
            program = ''${pkgs.writeShellScriptBin "watch" ''
                ${inputs.htms.packages.${system}.htms}/bin/htms build -i ./src -o ./out -c ./config.nix
                cd out

                (trap 'kill 0' SIGINT;
                  ${pkgs.python3}/bin/python -m "http.server" &
                  ${inputs.htms.packages.${system}.htms}/bin/htms watch -i ../src -o ../out -c ../config.nix &
                  wait
                )
              ''}/bin/watch'';
          };
          default = watch;
        };
        packages = rec {
          # build = pkgs.callPackage ./nix/build.nix { inherit (inputs.htms.packages.${system}) htms; };
          # default = build;
        };
      }
    );
}
