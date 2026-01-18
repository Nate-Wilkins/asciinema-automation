{
  description                                                 = "asciinema-automation";

  inputs                                                      = {
    systems.url                                               = "path:./flake.systems.nix";
    systems.flake                                             = false;

    nixpkgs.url                                               = "github:Nate-Wilkins/nixpkgs/nixos-unstable";

    flake-utils.url                                           = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows                        = "systems";

    # task-documentation.url                                    = "gitlab:ox_os/task-documentation/3.0.1";
    # task-documentation.inputs.systems.follows                 = "systems";
    # task-documentation.inputs.nixpkgs.follows                 = "nixpkgs";
    # task-documentation.inputs.flake-utils.follows             = "flake-utils";
    # task-documentation.inputs.gitignore.follows               = "gitignore";
    # task-documentation.inputs.fenix.follows                   = "fenix";
    # task-documentation.inputs.asciinema-automation.follows    = "";
    # task-documentation.inputs.jikyuu.follows                  = "jikyuu";

    # task-runner.url                                           = "gitlab:ox_os/task-runner/4.0.0";
    # task-runner.inputs.systems.follows                        = "systems";
    # task-runner.inputs.nixpkgs.follows                        = "nixpkgs";
    # task-runner.inputs.flake-utils.follows                    = "flake-utils";
    # task-runner.inputs.gitignore.follows                      = "gitignore";
    # task-runner.inputs.fenix.follows                          = "fenix";
    # task-runner.inputs.asciinema-automation.follows           = "";
    # task-runner.inputs.jikyuu.follows                         = "jikyuu";
    # task-runner.inputs.task-documentation.follows             = "task-documentation";

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Transatives
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # gitignore.url                                             = "github:hercules-ci/gitignore.nix";
    # gitignore.inputs.nixpkgs.follows                          = "nixpkgs";

    # rust-analyzer-src.url                                     = "github:rust-lang/rust-analyzer/nightly";
    # rust-analyzer-src.flake                                   = false;

    # fenix.url                                                 = "github:nix-community/fenix";
    # fenix.inputs.nixpkgs.follows                              = "nixpkgs";
    # fenix.inputs.rust-analyzer-src.follows                    = "rust-analyzer-src";

    fenix.url                                                 = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows                              = "nixpkgs";
    fenix.inputs.rust-analyzer-src.follows                    = "rust-analyzer-src";

    jikyuu.url                                                  = "github:Nate-Wilkins/jikyuu/2.0.4";
    jikyuu.inputs.systems.follows                               = "systems";
    jikyuu.inputs.nixpkgs.follows                               = "nixpkgs";
    jikyuu.inputs.flake-utils.follows                           = "flake-utils";
    jikyuu.inputs.fenix.follows                                 = "fenix";
    jikyuu.inputs.rust-analyzer-src.follows                     = "rust-analyzer-src";
    jikyuu.inputs.asciinema-automation.follows                  = "";

    rust-analyzer-src.url                                       = "github:rust-lang/rust-analyzer/nightly";
    rust-analyzer-src.flake                                     = false;
  };

  outputs                                            = {
    nixpkgs,
    flake-utils,
    # task-runner,
    # task-documentation,
    ...
  }:
    let
      mkPkgs                                         =
        system:
          pkgs: (
            # NixPkgs
            import pkgs { inherit system; }
            //
            # Custom Packages.
            {
              # task-documentation                    = task-documentation.defaultPackage."${system}";
            }
          );

    in (
      flake-utils.lib.eachDefaultSystem (system: (
        let
          pkgs                                       = mkPkgs system nixpkgs;
          manifest                                   = (pkgs.lib.importTOML ./pyproject.toml).project;
          environment                                = {
            inherit pkgs;
            inherit manifest;
          };
          name                                       = manifest.name;
        in rec {
          packages.${name}                           = pkgs.callPackage ./default.nix environment;
          legacyPackages                             = packages;

          # `nix build`
          defaultPackage                             = packages.${name};

          # `nix run`
          apps.${name}                               = flake-utils.lib.mkApp {
            inherit name;
            drv                                      = packages.${name};
          };
          defaultApp                                 = apps.${name};

          # `nix develop`
          devShells.default                          = import ./shell/default.nix (
            environment
          // {
            # taskRunner                               = task-runner.taskRunner.${system};
          });
        }
      )
    )
  );
}

