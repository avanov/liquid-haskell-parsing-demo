let
    nixpkgs-src = builtins.fetchTarball {
        # https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs
        # Descriptive name to make the store path easier to identify
        name   = "nixpkgs-unstable-2021-01-20";
        url    = https://github.com/NixOS/nixpkgs/archive/92c884dfd7140a6c3e6c717cf8990f7a78524331.tar.gz;
        # hash obtained with `nix-prefetch-url --unpack <archive>`
        sha256 = "0wk2jg2q5q31wcynknrp9v4wc4pj3iz3k7qlxvfh7gkpd8vq33aa";
    };
in
    import nixpkgs-src {}
