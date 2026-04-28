## Dense floating-point matrix with row-major storage and overloaded
## arithmetic. The book's NeuralNetwork, Markowitz, eigenvalue, and
## sparse-solver code all build on this type.

import std/sequtils

type
  Matrix* = ref object
    nrows*, ncols*: int
    data*: seq[float]    # row-major

proc newMatrix*(rows: int, cols = 1, fill = 0.0): Matrix =
  ## A `rows x cols` matrix filled with `fill`.
  Matrix(nrows: rows, ncols: cols,
         data: newSeqWith(rows * cols, fill))

proc newMatrix*(rows, cols: int, fill: proc(r, c: int): float): Matrix =
  ## A `rows x cols` matrix where element (r, c) is `fill(r, c)`.
  result = Matrix(nrows: rows, ncols: cols,
                  data: newSeq[float](rows * cols))
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      result.data[r * cols + c] = fill(r, c)

proc newMatrix*(rows: seq[seq[float]]): Matrix =
  ## Build from a sequence of rows.
  let n = rows.len
  let m = rows[0].len
  result = newMatrix(n, m)
  for r in 0 ..< n:
    for c in 0 ..< m:
      result.data[r * m + c] = rows[r][c]

proc newMatrix*(values: seq[float]): Matrix =
  ## Build a column vector from a flat sequence.
  newMatrix(values.len, 1, proc(r, c: int): float = values[r])

proc `[]`*(a: Matrix, i, j: int): float = a.data[i * a.ncols + j]
proc `[]=`*(a: Matrix, i, j: int, value: float) =
  a.data[i * a.ncols + j] = value

proc tolist*(a: Matrix): seq[seq[float]] =
  for r in 0 ..< a.nrows:
    var row = newSeq[float](a.ncols)
    for c in 0 ..< a.ncols: row[c] = a[r, c]
    result.add row

proc `$`*(a: Matrix): string = $a.tolist()

proc flatten*(a: Matrix): seq[float] = a.data

proc reshape*(a: Matrix, n, m: int): Matrix =
  if n * m != a.nrows * a.ncols:
    raise newException(ValueError, "Impossible reshape")
  let flat = a.data
  newMatrix(n, m, proc(r, c: int): float = flat[r * m + c])

proc swapRows*(a: Matrix, i, j: int) =
  for c in 0 ..< a.ncols:
    swap(a.data[i * a.ncols + c], a.data[j * a.ncols + c])

proc identity*(rows = 1, e = 1.0): Matrix =
  newMatrix(rows, rows,
    proc(r, c: int): float = (if r == c: e else: 0.0))

proc diagonal*(d: seq[float]): Matrix =
  newMatrix(d.len, d.len,
    proc(r, c: int): float = (if r == c: d[r] else: 0.0))

# Element-wise addition/subtraction; scalar broadcast for square or
# vector matrices follows the book's convention.

proc `+`*(a, b: Matrix): Matrix =
  if a.nrows != b.nrows or a.ncols != b.ncols:
    raise newException(ArithmeticDefect, "incompatible dimensions")
  result = newMatrix(a.nrows, a.ncols)
  for i in 0 ..< a.data.len:
    result.data[i] = a.data[i] + b.data[i]

proc `+`*(a: Matrix, x: float): Matrix =
  if a.nrows == a.ncols:
    return a + identity(a.nrows, x)
  if a.nrows == 1 or a.ncols == 1:
    return a + newMatrix(a.nrows, a.ncols, x)
  raise newException(ArithmeticDefect, "incompatible dimensions")

proc `+`*(x: float, a: Matrix): Matrix = a + x

proc `-`*(a: Matrix): Matrix =
  newMatrix(a.nrows, a.ncols, proc(r, c: int): float = -a[r, c])

proc `-`*(a, b: Matrix): Matrix = a + (-b)
proc `-`*(a: Matrix, x: float): Matrix = a + (-x)
proc `-`*(x: float, a: Matrix): Matrix = (-a) + x

proc `*`*(x: float, a: Matrix): Matrix =
  result = newMatrix(a.nrows, a.ncols)
  for i in 0 ..< a.data.len:
    result.data[i] = x * a.data[i]

proc `*`*(a: Matrix, x: float): Matrix = x * a

proc `*`*(a, b: Matrix): Matrix =
  ## Matrix multiplication. As a convenience, two equal-length column
  ## vectors return their scalar product wrapped in a 1x1 matrix.
  if a.ncols == 1 and b.ncols == 1 and a.nrows == b.nrows:
    var s = 0.0
    for r in 0 ..< a.nrows: s += a[r, 0] * b[r, 0]
    result = newMatrix(1, 1, s)
    return result
  if a.ncols != b.nrows:
    raise newException(ArithmeticDefect, "Incompatible dimension")
  result = newMatrix(a.nrows, b.ncols)
  for r in 0 ..< a.nrows:
    for c in 0 ..< b.ncols:
      var s = 0.0
      for k in 0 ..< a.ncols:
        s += a[r, k] * b[k, c]
      result[r, c] = s

proc inv*(a0: Matrix, x = 1.0): Matrix =
  ## Returns x * a^-1 using Gauss-Jordan elimination with partial pivoting.
  let n = a0.ncols
  if a0.nrows != n:
    raise newException(ArithmeticDefect, "matrix not squared")
  let a = newMatrix(a0.tolist())
  let b = identity(n, x)
  for c in 0 ..< n:
    for r in c + 1 ..< n:
      if abs(a[r, c]) > abs(a[c, c]):
        a.swapRows(r, c)
        b.swapRows(r, c)
    let p = a[c, c]
    for k in 0 ..< n:
      a[c, k] = a[c, k] / p
      b[c, k] = b[c, k] / p
    for r in 0 ..< n:
      if r == c: continue
      let pr = a[r, c]
      for k in 0 ..< n:
        a[r, k] = a[r, k] - a[c, k] * pr
        b[r, k] = b[r, k] - b[c, k] * pr
  result = b

proc `/`*(x: float, a: Matrix): Matrix = inv(a, x)
proc `/`*(a: Matrix, x: float): Matrix = (1.0 / x) * a
proc `/`*(a, b: Matrix): Matrix = a * (1.0 / b)

proc T*(a: Matrix): Matrix =
  ## Transpose of `a`.
  newMatrix(a.ncols, a.nrows, proc(r, c: int): float = a[c, r])

proc isAlmostSymmetric*(a: Matrix, ap = 1e-6, rp = 1e-4): bool =
  if a.nrows != a.ncols: return false
  for r in 0 ..< a.nrows:
    for c in 0 ..< r:
      let delta = abs(a[r, c] - a[c, r])
      if delta > ap and delta > max(abs(a[r, c]), abs(a[c, r])) * rp:
        return false
  return true

proc isAlmostZero*(a: Matrix, ap = 1e-6, rp = 1e-4): bool =
  for r in 0 ..< a.nrows:
    for c in 0 ..< a.ncols:
      let delta = abs(a[r, c] - a[c, r])
      if delta > ap and delta > max(abs(a[r, c]), abs(a[c, r])) * rp:
        return false
  return true
