## Numerical integration: trapezoidal, adaptive trapezoidal, and
## Vandermonde quadrature.

import std/math
import ./matrix
import ./linalg

proc integrateNaive*(f: proc(x: float): float,
                     a, b: float, n = 20): float =
  ## Trapezoidal integration of `f` over `[a, b]` with `n` slices.
  let h = (b - a) / float(n)
  result = h / 2.0 * (f(a) + f(b))
  for i in 1 ..< n:
    result += h * f(a + h * float(i))

proc integrate*(f: proc(x: float): float, a, b: float,
                ap = 1e-4, rp = 1e-4, ns = 20): float =
  ## Iteratively-refined trapezoidal integration to a target precision.
  var I = integrateNaive(f, a, b, 1)
  for k in 1 ..< ns:
    let IOld = I
    I = integrateNaive(f, a, b, 2 ^ k)
    if k > 2 and norm(I - IOld) < max(ap, norm(I) * rp):
      return I
  raise newException(ArithmeticDefect, "no convergence")

type
  QuadratureIntegrator* = ref object
    w*: Matrix

proc newQuadratureIntegrator*(order = 4): QuadratureIntegrator =
  let h = 1.0 / float(order - 1)
  let A = newMatrix(order, order,
    proc(r, c: int): float = (float(c) * h) ^ r)
  let s = newMatrix(order, 1,
    proc(r, c: int): float = 1.0 / float(r + 1))
  result = QuadratureIntegrator(w: (1.0 / A) * s)

proc integrate*(q: QuadratureIntegrator,
                f: proc(x: float): float, a, b: float): float =
  let order = q.w.nrows
  let h = (b - a) / float(order - 1)
  for i in 0 ..< order:
    result += q.w[i, 0] * f(a + float(i) * h)
  result *= (b - a)

proc integrateQuadratureNaive*(f: proc(x: float): float,
                               a, b: float, n = 20, order = 4): float =
  let h = (b - a) / float(n)
  let q = newQuadratureIntegrator(order = order)
  for i in 0 ..< n:
    result += q.integrate(f, a + float(i) * h,
                            a + float(i) * h + h)
