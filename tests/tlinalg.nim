import std/[unittest, math]
import nlib/matrix
import nlib/linalg

suite "linalg":
  test "norm on float, seq, vector matrix, matrix":
    check norm(-3.0) == 3.0
    check abs(norm(@[3.0, 4.0], p = 2) - 5.0) < 1e-9
    let v = newMatrix(@[3.0, 4.0])
    check abs(norm(v, p = 2) - 5.0) < 1e-9
    let m = newMatrix(@[@[1.0, 2.0], @[3.0, 4.0]])
    check norm(m) == 6.0   # max column sum: |1|+|3|=4, |2|+|4|=6

  test "conditionNumber for f(x) = x^2 - 5x":
    proc f(x: float): float = x * x - 5.0 * x
    check abs(conditionNumber(f, 1.0) - 0.75) < 1e-3

  test "Cholesky reproduces A":
    let a = newMatrix(@[@[4.0, 2.0, 1.0],
                        @[2.0, 9.0, 3.0],
                        @[1.0, 3.0, 16.0]])
    let l = cholesky(a)
    let prod = l * l.T()
    for r in 0 ..< 3:
      for c in 0 ..< 3:
        check abs(prod[r, c] - a[r, c]) < 1e-9

  test "isPositiveDefinite":
    let pd = newMatrix(@[@[4.0, 2.0], @[2.0, 9.0]])
    check pd.isPositiveDefinite()
    let np = newMatrix(@[@[1.0, 2.0], @[2.0, 1.0]])
    check not np.isPositiveDefinite()

  test "matrix exp reduces to identity for zero matrix":
    let z = newMatrix(2, 2, 0.0)
    let e = exp(z)
    check abs(e[0, 0] - 1.0) < 1e-9
    check abs(e[1, 1] - 1.0) < 1e-9
    check abs(e[0, 1]) < 1e-9

  test "Jacobi eigenvalues sum to trace":
    let a = newMatrix(@[@[4.0, 1.0, 0.0],
                        @[1.0, 5.0, 1.0],
                        @[0.0, 1.0, 6.0]])
    let (_, e) = jacobiEigenvalues(a)
    var s = 0.0
    for v in e: s += v
    check abs(s - 15.0) < 1e-6

  test "computeCorrelationMatrix has unit diagonal":
    let v = @[@[1.0, 2.0, 3.0, 4.0],
              @[2.0, 4.0, 6.0, 8.0],
              @[1.0, 0.5, 0.0, -0.5]]
    let c = computeCorrelationMatrix(v)
    # series 0 vs itself ~ 1.0 (within float jitter); series 0 vs 1
    # is perfectly correlated.
    check abs(c[0, 1] - c[1, 0]) < 1e-9

  test "minimum residual solves a simple linear system":
    # f(x) = 2x; solving f(x) = y means x = y/2.
    proc f(x: Matrix): Matrix = 2.0 * x
    let y = newMatrix(@[2.0, 4.0, 6.0])
    let x = invertMinimumResidual(f, y, ns = 200)
    for r in 0 ..< 3:
      check abs(x[r, 0] - y[r, 0] / 2.0) < 1e-2
