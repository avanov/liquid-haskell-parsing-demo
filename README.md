Liquid Haskell Example
======================

This is a self-contained [Liquid Haskell](https://ucsd-progsys.github.io/liquidhaskell-blog/) example.

```bash
nix-shell --run "make run"
```


Consider the function [`apiCallProvideRedundancy`](https://github.com/avanov/liquid-haskell-parsing-demo/blob/fd4fca50079ac9ecd0b55fa34156428c6d3d4259/app/Main.hs#L37-L43).

Imagine it's a part of the core API that needs to be safe and free from redundant case-analysis of input data.
LiquidHaskell helps me to express and filter predicates that go beyond `NonEmpty` kinds of constructors.
As soon as I declare that `type Destinations` is a list of at least two non-empty textual values,
the compiler requires me to prove that the data I call `apiCallProvideRedundancy` with does satisfy
that criteria of the firsrt argument.
Hence [the helper parsing functions](https://github.com/avanov/liquid-haskell-parsing-demo/blob/fd4fca50079ac9ecd0b55fa34156428c6d3d4259/app/Main.hs#L50-L77)
have to exist at the boundaries of my API, and not somewhere inside `apiCallProvideRedundancy`.
