{   haskellCompiler ? "ghc8103"
,   withLGPL        ? true
,   pkgs            ? import ./nixpkgs
}:

let
    ghcSetup      = import ./nixpkgs/ghc-setup.nix { inherit haskellCompiler; inherit withLGPL; inherit pkgs; };
    ghcEnv        = ghcSetup.ghc;
    linuxSpecific = with pkgs; stdenv.lib.optionals stdenv.isLinux [ locale glibcLocales ];
in

with pkgs; mkShell {
    name = "liquid-demo";

    # The packages in the `buildInputs` list will be added to the PATH in our shell
    # Python-specific guide:
    # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md

    buildInputs = [
        # see https://nixos.org/nixos/packages.html
        # usually required as python runtime dependencies
        ncurses
        libxml2
        libxslt
        libzip
        zlib
        # root CA certificates
        cacert
        which
        gnumake

        libiconv  # required for building Cabal
        gmp       # required for GHC
        z3        # liquid haskell
        ghcEnv
    ] ++ linuxSpecific;
    shellHook = ''
        # Set SOURCE_DATE_EPOCH so that we can use python wheels.
        # This compromises immutability, but is what we need
        # to allow package installs from PyPI
        export SOURCE_DATE_EPOCH=$(date +%s)

        export LANG=en_GB.UTF-8
        export LOCALE=en_GB.UTF-8
        export LC_ALL=en_GB.UTF-8

        # Dirty fix for Linux systems
        # https://nixos.wiki/wiki/Packaging/Quirks_and_Caveats
        export LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib/:$LD_LIBRARY_PATH
    '';
}
