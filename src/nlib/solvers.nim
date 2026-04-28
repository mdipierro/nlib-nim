## One- and multi-dimensional root finders and optimizers.

import std/math
import ./matrix
import ./calculus
import ./linalg

# --- 1D root finders ----------------------------------------------------

proc solveFixedPoint*(f: proc(x: float): float, x0: float,
                      ap = 1e-6, rp = 1e-4, ns = 100): float =
  let g = proc(x: float): float = f(x) + x
  let Dg = D(g)
  var x = x0
  for k in 0 ..< ns:
    if abs(Dg(x)) >= 1:
      raise newException(ArithmeticDefect, "error D(g)(x)>=1")
    let xOld = x
    x = g(x)
    if k > 2 and norm(xOld - x) < max(ap, norm(x) * rp):
      return x
  raise newException(ArithmeticDefect, "no convergence")

proc solveBisection*(f: proc(x: float): float, a0, b0: float,
                     ap = 1e-6, rp = 1e-4, ns = 100): float =
  var a = a0
  var b = b0
  var fa = f(a)
  var fb = f(b)
  if fa == 0: return a
  if fb == 0: return b
  if fa * fb > 0:
    raise newException(ArithmeticDefect,
                       "f(a) and f(b) must have opposite sign")
  for k in 0 ..< ns:
    let x = (a + b) / 2.0
    let fx = f(x)
    if fx == 0 or norm(b - a) < max(ap, norm(x) * rp):
      return x
    if fx * fa < 0:
      b = x; fb = fx
    else:
      a = x; fa = fx
  raise newException(ArithmeticDefect, "no convergence")

proc solveNewton*(f: proc(x: float): float, x0: float,
                  ap = 1e-6, rp = 1e-4, ns = 20): float =
  var x = x0
  for k in 0 ..< ns:
    let fx = f(x)
    let Dfx = D(f)(x)
    if norm(Dfx) < ap:
      raise newException(ArithmeticDefect, "unstable solution")
    let xOld = x
    x = x - fx / Dfx
    if k > 2 and norm(x - xOld) < max(ap, norm(x) * rp):
      return x
  raise newException(ArithmeticDefect, "no convergence")

proc solveSecant*(f: proc(x: float): float, x0: float,
                  ap = 1e-6, rp = 1e-4, ns = 20): float =
  var x = x0
  var fx = f(x)
  var Dfx = D(f)(x)
  for k in 0 ..< ns:
    if norm(Dfx) < ap:
      raise newException(ArithmeticDefect, "unstable solution")
    let xOld = x
    let fxOld = fx
    x = x - fx / Dfx
    if k > 2 and norm(x - xOld) < max(ap, norm(x) * rp):
      return x
    fx = f(x)
    Dfx = (fx - fxOld) / (x - xOld)
  raise newException(ArithmeticDefect, "no convergence")

# --- 1D optimizers ------------------------------------------------------

proc optimizeBisection*(f: proc(x: float): float, a, b: float,
                        ap = 1e-6, rp = 1e-4, ns = 100): float =
  solveBisection(D(f), a, b, ap, rp, ns)

proc optimizeNewton*(f: proc(x: float): float, x0: float,
                     ap = 1e-6, rp = 1e-4, ns = 20): float =
  var x = x0
  let f1 = D(f)
  let f2 = DD(f)
  for k in 0 ..< ns:
    let fx = f1(x)
    let Dfx = f2(x)
    if Dfx == 0: return x
    if norm(Dfx) < ap:
      raise newException(ArithmeticDefect, "unstable solution")
    let xOld = x
    x = x - fx / Dfx
    if norm(x - xOld) < max(ap, norm(x) * rp): return x
  raise newException(ArithmeticDefect, "no convergence")

proc optimizeSecant*(f: proc(x: float): float, x0: float,
                     ap = 1e-6, rp = 1e-4, ns = 100): float =
  var x = x0
  let f1 = D(f)
  let f2 = DD(f)
  var fx = f1(x)
  var Dfx = f2(x)
  for k in 0 ..< ns:
    if fx == 0: return x
    if norm(Dfx) < ap:
      raise newException(ArithmeticDefect, "unstable solution")
    let xOld = x
    let fxOld = fx
    x = x - fx / Dfx
    if norm(x - xOld) < max(ap, norm(x) * rp): return x
    fx = f1(x)
    Dfx = (fx - fxOld) / (x - xOld)
  raise newException(ArithmeticDefect, "no convergence")

proc optimizeGoldenSearch*(f: proc(x: float): float, a0, b0: float,
                           ap = 1e-6, rp = 1e-4, ns = 100): float =
  var a = a0
  var b = b0
  let tau = (sqrt(5.0) - 1.0) / 2.0
  var x1 = a + (1.0 - tau) * (b - a)
  var x2 = a + tau * (b - a)
  var fa = f(a); var f1 = f(x1); var f2 = f(x2); var fb = f(b)
  for k in 0 ..< ns:
    if f1 > f2:
      a = x1; fa = f1; x1 = x2; f1 = f2
      x2 = a + tau * (b - a); f2 = f(x2)
    else:
      b = x2; fb = f2; x2 = x1; f2 = f1
      x1 = a + (1.0 - tau) * (b - a); f1 = f(x1)
    if k > 2 and norm(b - a) < max(ap, norm(b) * rp): return b
  raise newException(ArithmeticDefect, "no convergence")

# --- Multi-dim solvers and optimizers -----------------------------------

proc solveNewtonMulti*(f: proc(x: seq[float]): seq[float],
                       x0: seq[float],
                       ap = 1e-6, rp = 1e-4, ns = 20): seq[float] =
  var x = newMatrix(x0)
  for k in 0 ..< ns:
    let fx = newMatrix(f(x.flatten()))
    let J = jacobian(f, x.flatten())
    if norm(J) < ap:
      raise newException(ArithmeticDefect, "unstable solution")
    let xOld = x
    x = x - (1.0 / J) * fx
    if k > 2 and norm(x - xOld) < max(ap, norm(x) * rp):
      return x.flatten()
  raise newException(ArithmeticDefect, "no convergence")

proc optimizeNewtonMulti*(f: proc(x: seq[float]): float,
                          x0: seq[float],
                          ap = 1e-6, rp = 1e-4, ns = 20): seq[float] =
  var x = newMatrix(x0)
  for k in 0 ..< ns:
    let grad = gradient(f, x.flatten())
    let H = hessian(f, x.flatten())
    if norm(H) < ap:
      raise newException(ArithmeticDefect, "unstable solution")
    let xOld = x
    x = x - (1.0 / H) * grad
    if k > 2 and norm(x - xOld) < max(ap, norm(x) * rp):
      return x.flatten()
  raise newException(ArithmeticDefect, "no convergence")

proc optimizeNewtonMultiImproved*(
    f: proc(x: seq[float]): float, x0: seq[float],
    ap = 1e-6, rp = 1e-4, ns = 20, hStart = 10.0): seq[float] =
  ## Newton optimizer with line-search fallback to steepest descent.
  var x = newMatrix(x0)
  var fx = f(x.flatten())
  var h = hStart
  for k in 0 ..< ns:
    let grad = gradient(f, x.flatten())
    let H = hessian(f, x.flatten())
    if norm(H) < ap:
      raise newException(ArithmeticDefect, "unstable solution")
    var fxOld = fx
    var xOld = x
    x = x - (1.0 / H) * grad
    fx = f(x.flatten())
    while fx > fxOld:
      fx = fxOld; x = xOld
      let normGrad = norm(grad)
      xOld = x
      x = x - grad * (h / normGrad)
      fxOld = fx
      fx = f(x.flatten())
      h = h / 2.0
    h = norm(x - xOld) * 2.0
    if k > 2 and h / 2.0 < max(ap, norm(x) * rp):
      return x.flatten()
  raise newException(ArithmeticDefect, "no convergence")
