import std/[unittest, math]
import nlib/calculus
import nlib/matrix

suite "calculus":
  test "first derivative of x^2 - 5x":
    proc f(x: float): float = x * x - 5.0 * x
    let d = D(f)
    check abs(d(0.0) - (-5.0)) < 1e-4
    check abs(d(3.0) - 1.0) < 1e-4   # 2*3 - 5 = 1

  test "second derivative of x^2 - 5x":
    # DD uses central differences with `h^2` in the denominator, so
    # the achievable numerical precision is much looser than for D.
    proc f(x: float): float = x * x - 5.0 * x
    let dd = DD(f)
    check abs(dd(0.0) - 2.0) < 1e-2
    check abs(dd(7.0) - 2.0) < 1e-2

  test "first derivative of sin is cos":
    let d = D(sin)
    check abs(d(0.0) - 1.0) < 1e-4
    check abs(d(PI / 2.0)) < 1e-4

  test "partial of f(x, y, z)":
    proc f(x: seq[float]): float = 2.0*x[0] + 3.0*x[1] + 5.0*x[1]*x[2]
    let p0 = partial(f, 0)
    let p1 = partial(f, 1)
    let p2 = partial(f, 2)
    let x = @[1.0, 1.0, 1.0]
    check abs(p0(x) - 2.0) < 1e-3
    check abs(p1(x) - 8.0) < 1e-3
    check abs(p2(x) - 5.0) < 1e-3

  test "gradient and hessian have right shape":
    proc f(x: seq[float]): float = x[0]*x[0] + 2.0*x[1]*x[1]
    let g = gradient(f, @[1.0, 1.0])
    check g.nrows == 2 and g.ncols == 1
    check abs(g[0, 0] - 2.0) < 1e-3
    check abs(g[1, 0] - 4.0) < 1e-3
    let h = hessian(f, @[1.0, 1.0])
    check h.nrows == 2 and h.ncols == 2
    check abs(h[0, 0] - 2.0) < 1e-2
    check abs(h[1, 1] - 4.0) < 1e-2

  test "jacobian":
    proc f(x: seq[float]): seq[float] =
      @[2.0*x[0] + 3.0*x[1] + 5.0*x[1]*x[2], 2.0*x[0]]
    let J = jacobian(f, @[1.0, 1.0, 1.0])
    check J.nrows == 2 and J.ncols == 3
    check abs(J[0, 0] - 2.0) < 1e-3
    check abs(J[0, 1] - 8.0) < 1e-3
    check abs(J[1, 0] - 2.0) < 1e-3
