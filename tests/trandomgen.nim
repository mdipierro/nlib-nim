import std/[unittest, math, random, sequtils, sets]
import nlib/randomgen

suite "randomgen":
  randomize(42)

  test "MCG produces values in [0, 1)":
    let g = newMCG(seed = 1071914055)
    for _ in 0 ..< 1000:
      let v = g.random()
      check v >= 0.0 and v < 1.0

  test "MCG is deterministic given a seed":
    let a = newMCG(seed = 42)
    let b = newMCG(seed = 42)
    for _ in 0 ..< 100:
      check a.random() == b.random()

  test "leapfrog produces independent streams":
    let g = newMCG(seed = 1)
    let streams = leapfrog(g, 4)
    check streams.len == 4
    var first: seq[float]
    for s in streams: first.add s.random()
    # very likely the four leapfrogged values are distinct
    check first.toHashSet().len == 4

  test "MarsenneTwister produces values in [0, 1)":
    let g = newMarsenneTwister()
    for _ in 0 ..< 1000:
      let v = g.random()
      check v >= 0.0 and v <= 1.0

  test "RandomSource defaults to std/random":
    let r = newRandomSource()
    for _ in 0 ..< 100:
      let v = r.random()
      check v >= 0.0 and v < 1.0

  test "uniform / randint / choice":
    let r = newRandomSource()
    for _ in 0 ..< 100:
      let v = r.uniform(2.0, 7.0)
      check v >= 2.0 and v < 7.0
    for _ in 0 ..< 100:
      let i = r.randint(3, 8)
      check i >= 3 and i <= 8
    let xs = @[10, 20, 30, 40]
    for _ in 0 ..< 100:
      check r.choice(xs) in xs

  test "bernoulli, binomial, poisson stay within range":
    let r = newRandomSource()
    for _ in 0 ..< 100:
      check r.bernoulli(0.5) in 0 .. 1
      check r.binomial(10, 0.3) in 0 .. 10
      check r.poisson(3.0) >= 0

  test "exponential / pareto give positive values":
    let r = newRandomSource()
    for _ in 0 ..< 100:
      check r.exponential(0.5) > 0
      check r.pareto(1.5, 100.0) >= 100.0

  test "pointInCircle stays inside the unit disk":
    let r = newRandomSource()
    for _ in 0 ..< 100:
      let (x, y) = r.pointInCircle(1.0)
      check x*x + y*y < 1.0

  test "pointOnSphere has unit length":
    let r = newRandomSource()
    for _ in 0 ..< 50:
      let (x, y, z) = r.pointOnSphere(1.0)
      check abs(sqrt(x*x + y*y + z*z) - 1.0) < 1e-9

  test "Gaussian source produces near-zero mean":
    let r = newRandomSource()
    let g = newGaussRandomSource(r)
    var s = 0.0
    for _ in 0 ..< 5000: s += g.gauss(0.0, 1.0)
    check abs(s / 5000.0) < 0.1

  test "confidenceIntervals returns 11 entries":
    let ints = confidenceIntervals(0.0, 1.0)
    check ints.len == 11

  test "resample preserves length":
    let xs = @[1.0, 2.0, 3.0, 4.0, 5.0]
    check resample(xs).len == xs.len
    check resample(xs, size = 7).len == 7

  test "FishmanYarberry yields keys from the table":
    let fy = newFishmanYarberry(@[(0, 0.5), (1, 0.25), (2, 0.25)])
    let r = newRandomSource()
    for _ in 0 ..< 100:
      let k = fy.discreteMap(r.random())
      check k in 0 .. 2
