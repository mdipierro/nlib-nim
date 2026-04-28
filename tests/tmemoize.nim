import std/unittest
import nlib/memoize

suite "memoize":
  test "memoized fib produces correct values":
    let fib = memoize[int, int](
      proc(self: proc(x: int): int, n: int): int =
        if n < 2: n else: self(n - 1) + self(n - 2))
    check fib(0) == 0
    check fib(1) == 1
    check fib(11) == 89
    check fib(20) == 6765

  test "memoized factorial":
    let fact = memoize[int, int](
      proc(self: proc(x: int): int, n: int): int =
        if n <= 1: 1 else: n * self(n - 1))
    check fact(0) == 1
    check fact(5) == 120
    check fact(10) == 3628800

  test "memoize caches calls":
    var calls = 0
    let f = memoize[int, int](
      proc(self: proc(x: int): int, n: int): int =
        inc calls
        if n < 2: n else: self(n - 1) + self(n - 2))
    discard f(15)
    let firstCalls = calls
    discard f(15)
    # second call should be a cache hit
    check calls == firstCalls
