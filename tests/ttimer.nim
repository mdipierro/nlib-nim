import std/[unittest, os]
import nlib/timer

suite "timer":
  test "timef returns a non-negative average":
    proc fast() = discard
    let dt = timef(fast, ns = 100, dt = 1.0)
    check dt >= 0.0

  test "timef bounded by `dt`":
    proc slow() = sleep(5)
    let dt = timef(slow, ns = 1_000_000, dt = 0.05)
    check dt > 0.0
    # average per call must be at least the sleep duration
    check dt >= 0.005 * 0.5
