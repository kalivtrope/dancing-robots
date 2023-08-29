# Generating inputs
You can generate new inputs via the `./main.lua generate` command.

## Generator arguments
- If a generator requires `N` named arguments (with names `<arg1>,...,<argN>`
    and respective values `<val1>,...,<valN>`), specify them space-separated like this:
      `<arg1> <val1> <arg2> <val2> ... <argN> <valN>`
- you can pass whatever arguments you want to the generators, but they may choose to ignore them or replace them if you provide an unfit value
- there is a common argument `seed` which you can pass to the generator via the option `-s` or `--seed <num>`
  - this value defaults to 42 if not provided
  - again, some generators are not required to use randomness (and for example they expect the caller to tell them the exact problem size)
### comb
- recognized arguments/options: `-s, --seed, seed, n, m`
- this generator uses randomness to determine item placement
- `n,m` are used as defined in the problem statement
  - if you dont provide a valid value for either of these numbers, they default to `n=10` and `m=8`
- example generation:
```
./main.lua generate comb comb_n30 n 30 m 1
```
### matrix
- recognized arguments/options: `-s, --seed, seed, n, m`
- this generator uses randomness to place the edges
- `n,m` define number of vertices and edges respectively
- default values:
  - `n=10`
  - `m=math.random(2*n-1,math.min(4*n, n*(n-1)//2-1))`
### sortp
- recognized arguments/options: `-s, --seed, seed, n`
- this generator uses randomness to create a random permutation
- default value:
  - `n=10`
### spiral
- recognized arguments/options: `n`
- default: `n=10`
### wave
- recognized arguments/options: `n`
- default: `n=10`
