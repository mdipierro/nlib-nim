import std/unittest
import nlib/solvers

suite "solvers (1D)":
  test "fixed-point on f(x) = (x - 2)*(x - 5) / 10":
    proc f(x: float): float = (x - 2.0) * (x - 5.0) / 10.0
    check abs(solveFixedPoint(f, 1.0, rp = 0.0) - 2.0) < 1e-3

  test "bisection on (x - 2)*(x - 5)":
    proc f(x: float): float = (x - 2.0) * (x - 5.0)
    check abs(solveBisection(f, 1.0, 3.0) - 2.0) < 1e-4

  test "Newton on (x - 2)*(x - 5)":
    proc f(x: float): float = (x - 2.0) * (x - 5.0)
    check abs(solveNewton(f, 1.0) - 2.0) < 1e-4

  test "secant on (x - 2)*(x - 5)":
    proc f(x: float): float = (x - 2.0) * (x - 5.0)
    check abs(solveSecant(f, 1.0) - 2.0) < 1e-4

  test "bisection requires sign change":
    proc f(x: float): float = x * x + 1.0
    expect ArithmeticDefect:
      discard solveBisection(f, 0.0, 1.0)

suite "optimizers (1D)":
  test "minimum of (x - 2)*(x - 5) at x = 3.5":
    proc f(x: float): float = (x - 2.0) * (x - 5.0)
    check abs(optimizeBisection(f, 2.0, 5.0) - 3.5) < 1e-3
    check abs(optimizeNewton(f, 3.0) - 3.5) < 1e-3
    check abs(optimizeSecant(f, 3.0) - 3.5) < 1e-3
    check abs(optimizeGoldenSearch(f, 2.0, 5.0) - 3.5) < 1e-3

suite "solvers (multi-d)":
  test "Newton-multi finds (1, -1) root":
    proc f(x: seq[float]): seq[float] =
      @[x[0] + x[1], x[0] + x[1] * x[1] - 2.0]
    let x = solveNewtonMulti(f, @[0.0, 0.0])
    check abs(x[0] - 1.0) < 1e-3
    check abs(x[1] + 1.0) < 1e-3

  test "Newton-multi optimizer finds (2, 3)":
    proc f(x: seq[float]): float =
      (x[0] - 2.0) * (x[0] - 2.0) + (x[1] - 3.0) * (x[1] - 3.0)
    let x = optimizeNewtonMulti(f, @[0.0, 0.0])
    check abs(x[0] - 2.0) < 1e-3
    check abs(x[1] - 3.0) < 1e-3
