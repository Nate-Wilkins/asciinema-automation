{
  description                                       = "asciinema-automation";

  inputs                                            = {
    nixpkgs.url                                     = "github:NixOS/nixpkgs/23.11";

    flake-utils.url                                 = "github:numtide/flake-utils";

    task-runner.url                                 = "gitlab:ox_os/task-runner";
    task-documentation.url                          = "gitlab:ox_os/task-documentation";
  };

  outputs                                           = {
    nixpkgs,
    flake-utils,
    task-runner,
    task-documentation,
    ...
  }@inputs:
    let
      systems                                       = [ "x86_64-linux" ];
      mkPkgs                                        =
        system:
          pkgs: (
            # NixPkgs
            import pkgs { inherit system; }
            //
            # Custom Packages.
            {
              task-documentation                    = task-documentation.defaultPackage."${system}";
            }
          );

    in (
      flake-utils.lib.eachSystem systems (system: (
        let
          pkgs                                      = mkPkgs system nixpkgs;
          manifest                                  = (pkgs.lib.importTOML ./pyproject.toml).project;
          environment                               = {
            inherit pkgs;
            inherit manifest;
          };
          name                                      = manifest.name;
        in rec {
          packages.${name}                          = pkgs.callPackage ./default.nix environment;
          legacyPackages                            = packages;

          # `nix build`
          defaultPackage                            = packages.${name};

          # `nix run`
          apps.${name}                              = flake-utils.lib.mkApp {
            inherit name;
            drv                                     = packages.${name};
          };
          defaultApp                                = apps.${name};

          # `nix develop`
          devShells.default                         = import ./shell/default.nix {
            inherit mkPkgs system environment;
            flake-inputs                            = inputs;
          };
        }
      )
    )
  );
}

