import std/[unittest, math]
import nlib/fitting

suite "fitting":
  test "linear least squares recovers polynomial coefficients":
    var points: seq[(float, float, float)] = @[]
    for k in 0 ..< 30:
      let x = float(k)
      points.add (x, 5.0 + 0.8 * x + 0.3 * x * x, 1.0)
    let (cs, _, fittingF) = fitLeastSquares(points, QUADRATIC)
    check abs(cs[0] - 5.0) < 1e-6
    check abs(cs[1] - 0.8) < 1e-6
    check abs(cs[2] - 0.3) < 1e-6
    check abs(fittingF(10.0) - (5.0 + 8.0 + 30.0)) < 1e-6

  test "polynomial(n) returns n+1 basis functions":
    let p = polynomial(4)
    check p.len == 5
    check p[0](7.0) == 1.0
    check p[2](3.0) == 9.0
    check p[4](2.0) == 16.0

  test "fitLeastSquares uses error-bar weighting":
    var points: seq[(float, float, float)] = @[
      (0.0, 0.0, 1.0),
      (1.0, 1.0, 1.0),
      (2.0, 2.0, 1.0)
    ]
    let (cs, chi2, _) = fitLeastSquares(points, LINEAR)
    check abs(cs[0]) < 1e-9
    check abs(cs[1] - 1.0) < 1e-9
    check chi2 < 1e-12
