import std/[unittest, math]
import nlib/stats

suite "stats":
  test "mean of small sample":
    check abs(mean(@[1.0, 2.0, 3.0, 4.0, 5.0]) - 3.0) < 1e-9

  test "variance and sd":
    let xs = @[1.0, 2.0, 3.0, 4.0, 5.0]
    check abs(variance(xs) - 2.0) < 1e-9
    check abs(sd(xs) - sqrt(2.0)) < 1e-9

  test "E with arbitrary f":
    proc f(x: float): float = x * x
    check abs(E(f, @[1.0, 2.0, 3.0]) - (1.0 + 4.0 + 9.0) / 3.0) < 1e-9

  test "covariance/correlation of perfectly correlated series":
    let xs = @[1.0, 2.0, 3.0, 4.0]
    let ys = @[2.0, 4.0, 6.0, 8.0]
    check abs(correlation(xs, ys) - 1.0) < 1e-9
    check covariance(xs, ys) > 0

  test "correlation of anti-correlated series":
    let xs = @[1.0, 2.0, 3.0, 4.0]
    let ys = @[4.0, 3.0, 2.0, 1.0]
    check abs(correlation(xs, ys) + 1.0) < 1e-9

  test "mean of empty sample is zero":
    check mean(@[]) == 0.0
