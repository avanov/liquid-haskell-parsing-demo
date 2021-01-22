Liquid Haskell Example
======================

This is a self-contained [Liquid Haskell](https://ucsd-progsys.github.io/liquidhaskell-blog/) example.

```bash
nix-shell --run "make run"
```


Consider the function [`apiCallProvideRedundancy`](https://github.com/avanov/liquid-haskell-parsing-demo/blob/460f1fd8e352fe815ea41920d9a3683d10e3026d/app/Main.hs#L36-L42).

Imagine it's a part of "Core API" that needs to be safe and free from redundant case-analysis of input data.
Liquid Haskell helps us to express types and filter values based on predicates that go beyond `NonEmpty` kinds of constructors.
As soon as I declare that `type Destinations` is a list of at least two non-empty textual values,
the compiler requires me to prove that the data I call `apiCallProvideRedundancy` with does satisfy
that criteria of the firsrt argument.
Hence [the helper parsing functions](https://github.com/avanov/liquid-haskell-parsing-demo/blob/460f1fd8e352fe815ea41920d9a3683d10e3026d/app/Main.hs#L49-L76)
have to exist at the boundaries of my API, and not somewhere inside `apiCallProvideRedundancy`.
