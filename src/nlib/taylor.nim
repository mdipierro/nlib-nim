## Taylor-series implementations of `exp`, `sin`, and `cos` --- pedagogical
## stand-ins for `std/math.exp`, `std/math.sin`, `std/math.cos`.

import std/math

proc myexp*(x: float, precision = 1e-6, maxSteps = 40): float =
  ## Taylor-series exponential.
  if x == 0:
    return 1.0
  if x > 0:
    return 1.0 / myexp(-x, precision, maxSteps)
  var t = 1.0
  var s = 1.0
  for k in 1 ..< maxSteps:
    t = t * x / float(k)
    s = s + t
    if abs(t) < precision: return s
  raise newException(ArithmeticDefect, "no convergence")

proc mysin*(x: float, precision = 1e-6, maxSteps = 40): float =
  ## Taylor-series sine, with domain reduction for large `x`.
  if x == 0:
    return 0
  if x < 0:
    return -mysin(-x, precision, maxSteps)
  if x > 2.0 * PI:
    return mysin(x mod (2.0 * PI), precision, maxSteps)
  if x > PI:
    return -mysin(2.0 * PI - x, precision, maxSteps)
  if x > PI / 2:
    return mysin(PI - x, precision, maxSteps)
  if x > PI / 4:
    return sqrt(1.0 - mysin(PI / 2 - x, precision, maxSteps) ^ 2)
  var t = x
  var s = x
  for k in 1 ..< maxSteps:
    t = t * (-1.0) * x * x / float(2 * k) / float(2 * k + 1)
    s = s + t
    let r = x ^ (2 * k + 1)
    if r < precision: return s
  raise newException(ArithmeticDefect, "no convergence")

proc mycos*(x: float, precision = 1e-6, maxSteps = 40): float =
  ## Taylor-series cosine, with domain reduction for large `x`.
  if x == 0:
    return 1.0
  if x < 0:
    return mycos(-x, precision, maxSteps)
  if x > 2.0 * PI:
    return mycos(x mod (2.0 * PI), precision, maxSteps)
  if x > PI:
    return mycos(2.0 * PI - x, precision, maxSteps)
  if x > PI / 2:
    return -mycos(PI - x, precision, maxSteps)
  if x > PI / 4:
    return sqrt(1.0 - mycos(PI / 2 - x, precision, maxSteps) ^ 2)
  var t = 1.0
  var s = 1.0
  for k in 1 ..< maxSteps:
    t = t * (-1.0) * x * x / float(2 * k) / float(2 * k - 1)
    s = s + t
    let r = x ^ (2 * k)
    if r < precision: return s
  raise newException(ArithmeticDefect, "no convergence")
