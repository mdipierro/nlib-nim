# nlib --- Annotated Algorithms in Nim

`nlib` is the companion Nim package to *Annotated Algorithms in Nim --- With
Applications in Physics, Biology, Finance* by Massimo Di Pierro. The book is
a port to Nim of a previous edition originally assembled in Python from a
decade of lectures at the School of Computing of DePaul University. The
material covers the core ideas behind the design and analysis of algorithms,
scientific computing, Monte Carlo simulations, and parallel algorithms, with
worked examples in finance, physics, biology, and computer science.

The library is the working code that grows alongside the book: every
algorithm in the text is defined here and used by later chapters.

## Layout

```
nim/
├── book/             # the book sources (LaTeX, figures)
├── src/
│   ├── nlib.nim      # umbrella module; re-exports every submodule
│   └── nlib/
│       ├── sorting.nim     bst.nim       heap.nim
│       ├── graph.nim       text.nim      compression.nim
│       ├── matrix.nim      linalg.nim    calculus.nim
│       ├── taylor.nim      solvers.nim   fitting.nim
│       ├── integration.nim stats.nim     randomgen.nim
│       ├── montecarlo.nim  cluster.nim   neural.nim
│       ├── finance.nim     memoize.nim   persistent.nim
│       ├── plotting.nim    timer.nim
└── tests/            # one test file per submodule
```

A consumer only needs `import nlib` to reach every public name; submodules
can also be imported individually for a smaller dependency footprint.

## What's inside

| Topic                | Submodule              | A few representative names                               |
|----------------------|------------------------|----------------------------------------------------------|
| Sorts and search     | `nlib/sorting`         | `insertionSort`, `mergesort`, `quicksort`, `binarySearch` |
| Heaps                | `nlib/heap`            | `heapify`, `heapsort`, `heapPush`, `heapPop`              |
| Trees                | `nlib/bst`             | `BinarySearchTree`                                       |
| Graphs               | `nlib/graph`           | `breadthFirstSearch`, `kruskal`, `prim`, `dijkstra`       |
| Compression          | `nlib/compression`     | `encodeHuffman`, `decodeHuffman`                         |
| Sequence alignment   | `nlib/text`            | `lcs`, `needlemanWunsch`                                 |
| Matrix algebra       | `nlib/matrix`          | `Matrix`, `+`, `*`, `inv`, `T`                           |
| Numerical linalg     | `nlib/linalg`          | `cholesky`, `jacobiEigenvalues`, `invertBicgstab`         |
| Differential calculus| `nlib/calculus`        | `D`, `DD`, `partial`, `gradient`, `hessian`, `jacobian`   |
| Taylor approximations| `nlib/taylor`          | `myexp`, `mysin`, `mycos`                                 |
| Solvers / optimizers | `nlib/solvers`         | `solveBisection`, `optimizeNewton`, `solveNewtonMulti`    |
| Curve fitting        | `nlib/fitting`         | `fitLeastSquares`, `polynomial`, `fit`                    |
| Integration          | `nlib/integration`     | `integrate`, `QuadratureIntegrator`                       |
| Statistics           | `nlib/stats`           | `mean`, `variance`, `correlation`                         |
| Random generators    | `nlib/randomgen`       | `MCG`, `MarsenneTwister`, `RandomSource`, distributions   |
| Monte Carlo          | `nlib/montecarlo`      | `bootstrap`, `MCEngine`, `valueAtRisk`                    |
| Clustering           | `nlib/cluster`         | `Cluster`, hierarchical agglomeration                    |
| Neural network       | `nlib/neural`          | `NeuralNetwork`, back-propagation                        |
| Finance              | `nlib/finance`         | `markowitz`, `Trader`, `fakeStockPrices`                  |
| Memoization          | `nlib/memoize`         | `memoize`                                                 |
| Persistence          | `nlib/persistent`      | `PersistentDictionary` (JSON-backed)                      |
| Plotting             | `nlib/plotting`        | `savePlot`, `saveHistogram`, ... (gnuplot wrappers)       |
| Timing               | `nlib/timer`           | `timef`                                                   |

## Building

The repository ships with a [`rigx`](https://github.com/example/rigx)
config that exposes two targets:

```sh
rigx build pdf       # render book/book_numerical.pdf
rigx test            # build and run the Nim test suite
```

Direct invocations work too:

```sh
nim r --path:src tests/all.nim    # run every test
nimble test                       # via the package manifest
```

Tests use only Nim's standard library; the plotting helpers shell out to
`gnuplot` when it is available.

## License

BSD 3-Clause. Released by the author.
