## Wall-clock timing helper.

import std/times

proc timef*(f: proc(), ns = 1000, dt = 60.0): float =
  ## Calls `f` repeatedly and returns the average wall-clock time per
  ## call, capped at `ns` iterations or `dt` seconds.
  let t0 = epochTime()
  var t = t0
  var k = 1
  while k < ns:
    f()
    t = epochTime()
    if t - t0 > dt: break
    inc k
  result = (t - t0) / float(k)
