{
  pkgs,
  lib,
  manifest,
}: (
  let
    name                                          = manifest.name;
    version                                       = manifest.version;
    package                                       = pkgs.python39Packages.buildPythonPackage rec {
      inherit name version;
      src                                         = lib.cleanSource ./.;
      pyproject                                   = true;
      nativeBuildInputs                           = [ buildInputs ];
      buildInputs                                 = with pkgs; [ python39Packages.setuptools python39Packages.wheel ];
    };
    pythonEnvironment                             = pkgs.python39.withPackages(pkgsPython: [
      package
      pkgsPython.pexpect
    ]);
    dependencies = with pkgs; [
      asciinema
    ];
  in (
    pkgs.stdenv.mkDerivation {
      pname                                       = name;
      version                                     = version;

      src                                         = lib.cleanSource ./.;

      nativeBuildInputs                           = with pkgs; [
        makeWrapper
        pythonEnvironment
      ] ++ dependencies;

      installPhase                                = ''
        mkdir -p "$out/bin"
        ln -sf "${pythonEnvironment}/bin/asciinema-automation" "$out/bin/${name}"
      '';

      postFixup                                   = ''
        wrapProgram "$out/bin/${name}" \
          --prefix PATH : ${lib.makeBinPath dependencies}
      '';
    }
  )
)

