import std/[unittest, math, random]
import nlib/montecarlo

# `method` declarations must be top-level in Nim, so the engine
# subclass used to test MCEngine is declared outside the test block.
type PiSimulator = ref object of MCEngine

method simulateOnce(e: PiSimulator): float =
  let x = rand(1.0); let y = rand(1.0)
  if x*x + y*y < 1.0: 4.0 else: 0.0

suite "montecarlo":
  randomize(0)

  test "bootstrap 68% interval brackets the true mean":
    randomize(1)
    var xs: seq[float] = @[]
    for _ in 0 ..< 200: xs.add gauss(2.0, 1.0)
    let (lo, mu, hi) = bootstrap(xs)
    check lo <= mu and mu <= hi
    # the sample mean of 200 N(2, 1) draws is well within [1.5, 2.5]
    check mu > 1.5 and mu < 2.5

  test "MCEngine subclass converges":
    randomize(2024)
    # ap = rp = 0 disables early termination so all `ns` iterations
    # run, giving a tight estimate of pi.
    let s = PiSimulator()
    let (_, mu, _) = s.simulateMany(ap = 0.0, rp = 0.0, ns = 20000)
    check abs(mu - 3.14159) < 0.1

  test "valueAtRisk requires populated results":
    let s = MCEngine(results: @[1.0, 2.0, 3.0])
    expect ArithmeticDefect:
      discard s.valueAtRisk(95)

  test "integrateMc approximates sin from 0 to pi":
    proc f(x: float): float = sin(x)
    let v = integrateMc(f, 0.0, PI, N = 20000)
    check abs(v - 2.0) < 0.1
