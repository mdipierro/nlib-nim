## Linear and nonlinear least-squares fitting.

import std/math
import ./matrix
import ./linalg
import ./solvers

type
  FitFunc* = proc(x: float): float

proc fitLeastSquares*(points: seq[(float, float, float)],
                      f: seq[FitFunc]):
                      (seq[float], float, proc(x: float): float) =
  ## Linear least-squares fit. Returns (coefficients, chi2, fit function).
  let n = points.len
  let m = f.len
  let a = newMatrix(n, m)
  let b = newMatrix(n, 1)
  for i in 0 ..< n:
    let weight = 1.0 / points[i][2]
    b[i, 0] = weight * points[i][1]
    for j in 0 ..< m:
      a[i, j] = weight * f[j](points[i][0])
  let c = (1.0 / (a.T * a)) * (a.T * b)
  let chi = a * c - b
  let chi2Val = norm(chi, 2) ^ 2
  let cs = c.flatten()
  let fittingF = proc(x: float): float =
    var s = 0.0
    for i in 0 ..< f.len: s += f[i](x) * cs[i]
    s
  (cs, chi2Val, fittingF)

proc polynomial*(n: int): seq[FitFunc] =
  ## Returns the basis [1, x, x^2, ..., x^n] as a sequence of FitFuncs.
  proc monomial(power: int): FitFunc =
    # Wrap closure creation in a separate proc so each closure
    # captures its own `power` parameter.
    result = proc(x: float): float = x ^ power
  for p in 0 .. n:
    result.add monomial(p)

let CONSTANT*  = polynomial(0)
let LINEAR*    = polynomial(1)
let QUADRATIC* = polynomial(2)
let CUBIC*     = polynomial(3)
let QUARTIC*   = polynomial(4)

# --- Generic chi^2 fit (linear in `a`, nonlinear in `b`) ----------------

type
  NonlinearFit* = proc(b: seq[float], x: float): float

proc fit*(data: seq[(float, float, float)],
          fs: seq[NonlinearFit],
          b0: seq[float],
          ap = 1e-6, rp = 1e-4, ns = 200,
          constraint: proc(b: seq[float]): float = nil
          ): (seq[float], float) =
  ## Fits `\sum_j a_j fs[j](b, x)` to weighted points (x, y, dy);
  ## linear in the `a_j` and nonlinear in the parameter vector `b`.
  let na = fs.len
  proc core(b: seq[float]): (seq[float], float) =
    let A = newMatrix(data.len, na,
      proc(r, c: int): float = fs[c](b, data[r][0]) / data[r][2])
    let z = newMatrix(data.len, 1,
      proc(r, c: int): float = data[r][1] / data[r][2])
    let a = (1.0 / (A.T * A)) * (A.T * z)
    let chi2Val = norm(A * a - z) ^ 2
    (a.flatten(), chi2Val)
  proc g(b: seq[float]): float =
    let (_, chi2v) = core(b)
    var s = chi2v
    if constraint != nil: s += constraint(b)
    s
  let b = optimizeNewtonMultiImproved(g, b0, ap, rp, ns)
  let (a, chi2v) = core(b)
  (a & b, chi2v)
