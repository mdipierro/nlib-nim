import std/[unittest, math, random]
import nlib/finance
import nlib/matrix

suite "finance":
  randomize(0)

  test "fakeStockPrices length and positivity":
    let prices = fakeStockPrices(days = 100)
    check prices.len == 100
    for p in prices: check p > 0

  test "Markowitz tangency portfolio sums to 1":
    let cov = newMatrix(@[@[0.04, 0.006, 0.02],
                          @[0.006, 0.09, 0.06],
                          @[0.02, 0.06, 0.16]])
    let mu = newMatrix(@[0.10, 0.12, 0.15])
    let (x, ret, risk) = markowitz(mu, cov, 0.05)
    var s = 0.0
    for w in x: s += w
    check abs(s - 1.0) < 1e-9
    check ret > 0
    check risk > 0

  test "continuumKnapsack respects capacity":
    let a = @[60.0, 100.0, 120.0]
    let b = @[10.0, 20.0, 30.0]
    let (f, x) = continuumKnapsack(a, b, 50.0)
    var spent = 0.0
    for (i, q) in x: spent += q * b[i]
    check spent <= 50.0 + 1e-9
    check f > 0

  test "Trader.simulate returns finite cash":
    let prices = fakeStockPrices(days = 100, averageReturn = 0.05)
    let final = Trader().simulate(prices, cash = 1000.0)
    check classify(final) notin {fcNaN, fcInf, fcNegInf}

  test "randomList produces vectors with finite components":
    let cov = newMatrix(@[@[1.0, 0.1], @[0.1, 1.0]])
    var n = 0
    for v in randomList(cov):
      check v.len == 2
      for c in v:
        check classify(c) notin {fcNaN, fcInf, fcNegInf}
      inc n
      if n >= 5: break
