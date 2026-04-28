import std/[unittest, math]
import nlib/integration

suite "integration":
  test "trapezoidal on sin from 0 to pi":
    proc f(x: float): float = sin(x)
    check abs(integrateNaive(f, 0.0, PI, n = 200) - 2.0) < 1e-3

  test "adaptive integrate matches analytical sin integral":
    proc f(x: float): float = sin(x)
    check abs(integrate(f, 0.0, 3.0) - (1.0 - cos(3.0))) < 1e-3

  test "quadrature integrator at order 4":
    # A 4-point quadrature spanning the whole [0, 3] interval is only
    # accurate to ~h^4; the integralQuadratureNaive driver below is the
    # accurate variant that subdivides the domain.
    proc f(x: float): float = sin(x)
    let q = newQuadratureIntegrator(order = 4)
    check abs(q.integrate(f, 0.0, 3.0) - (1.0 - cos(3.0))) < 5e-2

  test "quadrature naive driver":
    proc f(x: float): float = x * x
    # Integral of x^2 from 0 to 1 is 1/3
    check abs(integrateQuadratureNaive(f, 0.0, 1.0,
                                        n = 5, order = 3) - 1.0/3.0) < 1e-6
