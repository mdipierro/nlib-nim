import std/[unittest, math]
import nlib/taylor

suite "taylor":
  test "myexp matches std/math.exp":
    for k in 0 ..< 10:
      let x = 0.1 * float(k)
      check abs(myexp(x) - exp(x)) < 1e-4
      check abs(myexp(-x) - exp(-x)) < 1e-4

  test "mysin matches std/math.sin":
    for k in 0 ..< 20:
      let x = 0.3 * float(k)
      check abs(mysin(x) - sin(x)) < 1e-3

  test "mycos matches std/math.cos":
    for k in 0 ..< 20:
      let x = 0.3 * float(k)
      check abs(mycos(x) - cos(x)) < 1e-3

  test "edge cases":
    check myexp(0.0) == 1.0
    check mysin(0.0) == 0.0
    check mycos(0.0) == 1.0
