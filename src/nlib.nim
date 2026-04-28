## nlib --- numerical algorithms accompanying the book
## *Annotated Algorithms in Nim* by Massimo Di Pierro.
##
## This is a thin umbrella module that re-exports the contents of
## every submodule under `src/nlib/`, so that user code can simply do
##
##   import nlib
##
## and have access to the whole library. Submodules can also be
## imported individually if a smaller dependency footprint is desired.

import nlib/sorting;        export sorting
import nlib/heap;           export heap
import nlib/bst;            export bst
import nlib/graph;          export graph
import nlib/compression;    export compression
import nlib/text;           export text
import nlib/matrix;         export matrix
import nlib/calculus;       export calculus
import nlib/taylor;         export taylor
import nlib/linalg;         export linalg
import nlib/solvers;        export solvers
import nlib/fitting;        export fitting
import nlib/integration;    export integration
import nlib/stats;          export stats
import nlib/randomgen;      export randomgen
import nlib/montecarlo;     export montecarlo
import nlib/cluster;        export cluster
import nlib/neural;         export neural
import nlib/memoize;        export memoize
import nlib/persistent;     export persistent
import nlib/finance;        export finance
import nlib/timer;          export timer
import nlib/plotting;       export plotting
