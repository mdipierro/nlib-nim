## Numerical derivatives, gradients, Hessians, and Jacobians.

import ./matrix

proc D*(f: proc(x: float): float, h = 1e-6): proc(x: float): float =
  ## First derivative of `f` (central difference).
  result = proc(x: float): float = (f(x + h) - f(x - h)) / 2.0 / h

proc DD*(f: proc(x: float): float, h = 1e-6): proc(x: float): float =
  ## Second derivative of `f` (central difference).
  result = proc(x: float): float =
    (f(x + h) - 2.0 * f(x) + f(x - h)) / (h * h)

proc partial*(f: proc(x: seq[float]): float, i: int, h = 1e-4):
              proc(x: seq[float]): float =
  ## i-th partial derivative of a scalar-valued multi-variate function.
  result = proc(x: seq[float]): float =
    var x = x
    x[i] += h
    let fPlus = f(x)
    x[i] -= 2.0 * h
    let fMinus = f(x)
    (fPlus - fMinus) / (2.0 * h)

proc partial*(f: proc(x: seq[float]): seq[float], i: int, h = 1e-4):
              proc(x: seq[float]): seq[float] =
  ## i-th partial derivative of a vector-valued function.
  result = proc(x: seq[float]): seq[float] =
    var x = x
    x[i] += h
    let fPlus = f(x)
    x[i] -= 2.0 * h
    let fMinus = f(x)
    result = newSeq[float](fPlus.len)
    for k in 0 ..< fPlus.len:
      result[k] = (fPlus[k] - fMinus[k]) / (2.0 * h)

proc gradient*(f: proc(x: seq[float]): float,
               x: seq[float], h = 1e-4): Matrix =
  newMatrix(x.len, 1, proc(r, c: int): float = partial(f, r, h)(x))

proc hessian*(f: proc(x: seq[float]): float,
              x: seq[float], h = 1e-4): Matrix =
  newMatrix(x.len, x.len,
    proc(r, c: int): float = partial(partial(f, r, h), c, h)(x))

proc jacobian*(f: proc(x: seq[float]): seq[float],
               x: seq[float], h = 1e-4): Matrix =
  var partials: seq[seq[float]] = @[]
  for c in 0 ..< x.len:
    partials.add partial(f, c, h)(x)
  newMatrix(partials[0].len, x.len,
    proc(r, c: int): float = partials[c][r])
