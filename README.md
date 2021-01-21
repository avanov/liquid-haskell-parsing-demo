Liquid Haskell Example
======================

This is a self-contained [Liquid Haskell](https://ucsd-progsys.github.io/liquidhaskell-blog/) example.

```bash
nix-shell --run "make run"
```


Consider the function [`apiCallProvideRedundancy`](https://github.com/avanov/liquid-haskell-parsing-demo/blob/7df6316d5356fe3bbcb460df5553614d47a9d697/app/Main.hs#L38-L44).

Imagine it's a part of the core API that needs to be safe and free from redundant case-analysis of input data.
LiquidHaskell helps me to express and filter predicates that go beyond `NonEmpty` kinds of constructors.
As soon as I declare that `type Destinations` is a list of at least two non-empty textual values,
the compiler requires me to prove that the data I call `apiCallProvideRedundancy` with does satisfy
that criteria of the firsrt argument.
Hence [the helper parsing functions](https://github.com/avanov/liquid-haskell-parsing-demo/blob/7df6316d5356fe3bbcb460df5553614d47a9d697/app/Main.hs#L51-L78)
have to exist at the boundaries of my API, and not somewhere inside `apiCallProvideRedundancy`.
