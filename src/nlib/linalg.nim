## Cholesky factorization, eigenvalues, norms, condition number,
## matrix exponential, and iterative solvers for sparse systems.

import std/math
import ./matrix
import ./calculus

# --- Norms ---------------------------------------------------------------

proc norm*(x: float, p = 1): float = abs(x)

proc norm*(xs: seq[float], p = 1): float =
  var s = 0.0
  for x in xs: s += abs(x).pow(float(p))
  result = s.pow(1.0 / float(p))

proc norm*(a: Matrix, p = 1): float =
  if a.nrows == 1 or a.ncols == 1:
    var s = 0.0
    for r in 0 ..< a.nrows:
      for c in 0 ..< a.ncols:
        s += abs(a[r, c]).pow(float(p))
    return s.pow(1.0 / float(p))
  if p == 1:
    var best = 0.0
    for c in 0 ..< a.ncols:
      var s = 0.0
      for r in 0 ..< a.nrows: s += abs(a[r, c])
      if s > best: best = s
    return best
  raise newException(ValueError, "norm not implemented for p != 1 on matrix")

proc conditionNumber*(f: proc(x: float): float, x: float,
                      h = 1e-6): float =
  D(f, h)(x) * x / f(x)

proc conditionNumber*(a: Matrix): float =
  norm(a) * norm(1.0 / a)

# --- Matrix exponential -------------------------------------------------

proc exp*(a: Matrix, ap = 1e-6, rp = 1e-4, ns = 40): Matrix =
  ## Matrix exponential by Taylor series.
  var t = identity(a.ncols)
  var s = identity(a.ncols)
  for k in 1 ..< ns:
    t = t * a * (1.0 / float(k))
    s = s + t
    if norm(t) < max(ap, norm(s) * rp):
      return s
  raise newException(ArithmeticDefect, "no convergence")

# --- Cholesky decomposition ---------------------------------------------

proc cholesky*(a: Matrix): Matrix =
  ## Returns L such that L * L.T == a.
  if not isAlmostSymmetric(a):
    raise newException(ArithmeticDefect, "not symmetric")
  let l = newMatrix(a.tolist())
  for k in 0 ..< l.ncols:
    if l[k, k] <= 0:
      raise newException(ArithmeticDefect, "not positive definite")
    let p = sqrt(l[k, k])
    l[k, k] = p
    for i in k + 1 ..< l.nrows:
      l[i, k] = l[i, k] / p
    for j in k + 1 ..< l.nrows:
      let pj = l[j, k]
      for i in k + 1 ..< l.nrows:
        l[i, j] = l[i, j] - pj * l[i, k]
  for i in 0 ..< l.nrows:
    for j in i + 1 ..< l.ncols:
      l[i, j] = 0
  result = l

proc isPositiveDefinite*(a: Matrix): bool =
  if not isAlmostSymmetric(a):
    return false
  try:
    discard cholesky(a)
    return true
  except Defect:        # cholesky raises ArithmeticDefect on indefinites
    return false
  except CatchableError:
    return false

# --- Jacobi eigenvalue decomposition ------------------------------------

proc jacobiEigenvalues*(a: Matrix): (Matrix, seq[float]) =
  ## Returns (U, e) so that `a == U * diagonal(e) * U.T`.
  proc maxind(m: Matrix, k: int): int =
    var j = k + 1
    for i in k + 2 ..< m.ncols:
      if abs(m[k, i]) > abs(m[k, j]): j = i
    j
  let n = a.nrows
  if n != a.ncols:
    raise newException(ArithmeticDefect, "matrix not squared")
  let s = newMatrix(a.tolist())
  let eMat = identity(n)
  var state = n
  var ind = newSeq[int](n)
  var e = newSeq[float](n)
  var changed = newSeq[bool](n)
  for k in 0 ..< n:
    ind[k] = maxind(s, k)
    e[k] = s[k, k]
    changed[k] = true
  while state > 0:
    var m = 0
    for k in 1 ..< n - 1:
      if abs(s[k, ind[k]]) > abs(s[m, ind[m]]): m = k
    let k = m
    let h = ind[m]
    let p = s[k, h]
    var y = (e[h] - e[k]) / 2.0
    var t = abs(y) + sqrt(p * p + y * y)
    var sv = sqrt(p * p + t * t)
    var c = t / sv
    var ss = p / sv
    t = p * p / t
    if y < 0:
      ss = -ss
      t = -t
    s[k, h] = 0
    y = e[k]
    e[k] = y - t
    if changed[k] and y == e[k]:
      changed[k] = false; dec state
    elif (not changed[k]) and y != e[k]:
      changed[k] = true; inc state
    y = e[h]
    e[h] = y + t
    if changed[h] and y == e[h]:
      changed[h] = false; dec state
    elif (not changed[h]) and y != e[h]:
      changed[h] = true; inc state
    for i in 0 ..< k:
      let a1 = c * s[i, k] - ss * s[i, h]
      let a2 = ss * s[i, k] + c * s[i, h]
      s[i, k] = a1; s[i, h] = a2
    for i in k + 1 ..< h:
      let a1 = c * s[k, i] - ss * s[i, h]
      let a2 = ss * s[k, i] + c * s[i, h]
      s[k, i] = a1; s[i, h] = a2
    for i in h + 1 ..< n:
      let a1 = c * s[k, i] - ss * s[h, i]
      let a2 = ss * s[k, i] + c * s[h, i]
      s[k, i] = a1; s[h, i] = a2
    for i in 0 ..< n:
      let a1 = c * eMat[k, i] - ss * eMat[h, i]
      let a2 = ss * eMat[k, i] + c * eMat[h, i]
      eMat[k, i] = a1; eMat[h, i] = a2
    ind[k] = maxind(s, k)
    ind[h] = maxind(s, h)
  for i in 1 ..< n:
    var j = i
    while j > 0 and e[j - 1] > e[j]:
      swap(e[j], e[j - 1])
      eMat.swapRows(j, j - 1)
      dec j
  let u = newMatrix(n, n)
  for i in 0 ..< n:
    var s2 = 0.0
    for j in 0 ..< n: s2 += eMat[i, j] ^ 2
    let nrm = sqrt(s2)
    for j in 0 ..< n: u[j, i] = eMat[i, j] / nrm
  (u, e)

proc computeCorrelationMatrix*(v: seq[seq[float]]): Matrix =
  ## Pearson correlation matrix of `v` (rows are series).
  let m = v.len
  let n = v[0].len
  var mus = newSeq[float](m)
  var vars = newSeq[float](m)
  for i in 0 ..< m:
    var s = 0.0
    for k in 0 ..< n: s += v[i][k]
    mus[i] = s / float(n)
    var s2 = 0.0
    for k in 0 ..< n: s2 += v[i][k] ^ 2
    vars[i] = s2 / float(n) - mus[i] ^ 2
  result = newMatrix(m, m,
    proc(i, j: int): float =
      var s = 0.0
      for k in 1 ..< n: s += v[i][k] * v[j][k]
      (s / float(n) - mus[i] * mus[j]) / sqrt(vars[i] * vars[j]))

# --- Sparse iterative solvers -------------------------------------------

proc invertMinimumResidual*(f: proc(x: Matrix): Matrix,
                            x: Matrix,
                            ap = 1e-4, rp = 1e-4, ns = 200): Matrix =
  ## Minimum residual iterative solver for `f(x) = y` on sparse linear ops.
  var y = newMatrix(x.tolist())
  var r = x - f(x)
  for k in 0 ..< ns:
    let q = f(r)
    let alpha = (q.T * r)[0, 0] / (q.T * q)[0, 0]
    y = y + alpha * r
    r = r - alpha * q
    let residue = sqrt((r.T * r)[0, 0] / float(r.nrows))
    if residue < max(ap, norm(y) * rp): return y
  raise newException(ArithmeticDefect, "no convergence")

proc invertBicgstab*(f: proc(x: Matrix): Matrix,
                     x: Matrix,
                     ap = 1e-4, rp = 1e-4, ns = 200): Matrix =
  ## Stabilized bi-conjugate gradient iterative solver.
  var y = newMatrix(x.tolist())
  var r = x - f(x)
  let q = newMatrix(r.tolist())
  var p = newMatrix(r.nrows, 1)
  var s = newMatrix(r.nrows, 1)
  var rhoOld = 1.0
  var alpha = 1.0
  var omega = 1.0
  for k in 0 ..< ns:
    let rho = (q.T * r)[0, 0]
    let beta = (rho / rhoOld) * (alpha / omega)
    rhoOld = rho
    p = beta * p + r - (beta * omega) * s
    s = f(p)
    alpha = rho / (q.T * s)[0, 0]
    r = r - alpha * s
    let tt = f(r)
    omega = (tt.T * r)[0, 0] / (tt.T * tt)[0, 0]
    y = y + omega * r + alpha * p
    let residue = sqrt((r.T * r)[0, 0] / float(r.nrows))
    if residue < max(ap, norm(y) * rp): return y
    r = r - omega * tt
  raise newException(ArithmeticDefect, "no convergence")
