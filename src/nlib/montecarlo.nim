## Generic Monte Carlo engine, bootstrap resampling, MC integration.

import std/[algorithm, math, random]
import ./stats
import ./randomgen

# --- Bootstrap ---------------------------------------------------------

proc bootstrap*(x: seq[float], confidence = 0.68, nsamples = 100):
                (float, float, float) =
  ## Bootstrap confidence interval. Returns (lower, mean, upper).
  var means: seq[float] = @[]
  for _ in 0 ..< nsamples: means.add mean(resample(x))
  means.sort()
  let leftTail = int(((1.0 - confidence) / 2.0) * float(nsamples))
  let rightTail = nsamples - 1 - leftTail
  (means[leftTail], mean(x), means[rightTail])

# --- Generic Monte Carlo engine ----------------------------------------

type
  MCEngine* = ref object of RootObj
    results*: seq[float]
    convergence*: bool

method simulateOnce*(e: MCEngine): float {.base.} =
  raise newException(CatchableError, "simulateOnce not implemented")

proc simulateMany*(e: MCEngine, ap = 0.1, rp = 0.1, ns = 1000):
                  (float, float, float) =
  e.results = @[]
  var s1 = 0.0
  var s2 = 0.0
  e.convergence = false
  for k in 1 ..< ns:
    let x = e.simulateOnce()
    e.results.add x
    s1 += x
    s2 += x * x
    let mu = s1 / float(k)
    let variance = s2 / float(k) - mu * mu
    let dmu = sqrt(variance / float(k))
    if k > 10 and abs(dmu) < max(ap, abs(mu) * rp):
      e.convergence = true
      break
  e.results.sort()
  bootstrap(e.results)

proc valueAtRisk*(e: MCEngine, confidence = 95): float =
  let index = int(0.01 * float(e.results.len) * float(confidence) + 0.999)
  if e.results.len - index < 5:
    raise newException(ArithmeticDefect, "not enough data, not reliable")
  e.results[index]

# --- Monte Carlo integration -------------------------------------------

proc integrateMc*(f: proc(x: float): float, a, b: float,
                  N = 1000): float =
  ## Naive Monte Carlo integration: average of `f` at uniform samples.
  for _ in 0 ..< N: result += f(rand(b - a) + a)
  result = result / float(N) * (b - a)
