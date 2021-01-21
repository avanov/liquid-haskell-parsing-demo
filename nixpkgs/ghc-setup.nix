# To see the list of available compilers, run
# nix-env -f "<nixpkgs>" -qaP -A haskell.compiler
# nix-env -f "<nixpkgs>" -qaP -A haskell.compiler.integer-simple

# Useful guide to overrides and more precise control of Haskell packages
# https://discourse.nixos.org/t/nix-haskell-development-2020/6170
{
    haskellCompiler,
    withLGPL       ,
    pkgs           ? import ./default.nix,
}:

let
    # Common patterns
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/lib.nix

    # Sometimes nix packages are thought to be broken, and have their `meta.broken` set to `true`.
    # This does not necessarily mean that they indeed are broken - the flags may be artifacts of
    # previous nixpkgs revisions that had known issues, and people disabled certain packages to
    # make Nix Hydra (Nix CI infrastructure) green. As the flags are not automatic,
    # people need to set/unset them explicitly through pull requests, or inside their own derivations.
    unbreak = pkgs.haskell.lib.markUnbroken;

    # A common issue with pulling in extra or different packages is that
    # we have to build them ourselves. Haskell build times are reasonable (depending on the library),
    # but often the tests are slow. We can "fix" this by adding `dontCheck` in front of the dependency
    # we know works or just want to test out. Distributed Builds can help when we don’t want to skip
    # tests or just want faster build times.
    dontCheck   = pkgs.haskell.lib.dontCheck;

    # `doJailbreak` is a very common pattern, allows to remove package  dependencies' boundaries,
    # for instance:
    # mu-protobuf     = pkgs.haskell.lib.doJailbreak (unbreak super.mu-protobuf);
    # ^^^ says that `mu-protobuf` should be exactly as it's described in the original package set,
    #     yet we want to explicitly mark that it's not broken.
    doJailbreak = pkgs.haskell.lib.doJailbreak;

    overrideCabal        = pkgs.haskell.lib.overrideCabal;
    appendBuildFlags     = pkgs.haskell.lib.appendBuildFlags;
    appendConfigureFlags = pkgs.haskell.lib.appendConfigureFlags;
    addBuildDepends      = pkgs.haskell.lib.addBuildDepends;
    addBuildTools        = pkgs.haskell.lib.addBuildTools;
    dontHaddock          = pkgs.haskell.lib.dontHaddock;

    # This attribute will contain a set with a selected GHC compiler and all its packages.
    # We use 'integer-simple' version of GHC here to be able to link statically without violating
    # LGPL license of GMP. Read more about 'integer-simple' and 'integer-gmp' at
    # https://gitlab.haskell.org/ghc/ghc/-/wikis/commentary/libraries/integer
    # https://gitlab.haskell.org/ghc/ghc/-/wikis/replacing-gmp-notes
    ghcVariant = if withLGPL then pkgs.haskell.packages
                             else pkgs.haskell.packages.integer-simple;

    ghcPackageSetWithOverrides = ghcVariant.${haskellCompiler}.override {
        overrides = self: original: {
            # haddock issues - https://github.com/ucsd-progsys/liquidhaskell/issues/1727
            liquid-base     = dontHaddock (unbreak (addBuildTools original.liquid-base [pkgs.z3]));
            liquid-ghc-prim = dontHaddock (unbreak (addBuildTools original.liquid-ghc-prim [pkgs.z3]));
        };
    };

    # This is a complete set of Haskell dependencies needed to build our project
    # Stack binary is shared between the dev env and the build env
    haskellLibraries = hackagePkgSet: with hackagePkgSet; [
        cabal-install
        liquid-base
        cmdargs
    ];

    # `ghc` is a derivation that contains GHC + required project libraries,
    # we can use it other shells and derivations as a single derivation
    # that represents our Haskell project with all its dependencies
    ghc = ghcPackageSetWithOverrides.ghcWithPackages haskellLibraries;

in
    # evaluate this Nix file to a set of the following attributes (`inherit name` means `name=name`)
    {
        inherit pkgs;
        inherit ghc;
        inherit ghcPackageSetWithOverrides;
        inherit haskellCompiler;
        inherit haskellLibraries;
    }
