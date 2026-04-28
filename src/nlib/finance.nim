## Financial routines: fake stock-price generation, Markowitz tangency
## portfolio, simple trading strategy, continuum knapsack, and a
## random-vector iterator with a given covariance.

import std/[algorithm, math, random]
import ./matrix
import ./linalg
import ./fitting

# --- Random vectors with prescribed covariance --------------------------

iterator randomList*(a: Matrix): seq[float] =
  ## Yields successive random vectors with covariance matrix `a`.
  let l = cholesky(a)
  while true:
    var u = newMatrix(l.nrows, 1)
    for c in 0 ..< l.nrows: u[c, 0] = gauss(0.0, 1.0)
    yield (l * u).flatten()

# --- Markowitz portfolio ------------------------------------------------

proc markowitz*(mu, a: Matrix, rFree: float):
                (seq[float], float, float) =
  ## Markowitz tangency portfolio. Returns (weights, return, risk).
  var x = (1.0 / a) * (mu - rFree)
  var s = 0.0
  for r in 0 ..< x.nrows: s += x[r, 0]
  x = x / s
  var portfolio: seq[float] = @[]
  for r in 0 ..< x.nrows: portfolio.add x[r, 0]
  let ret = (mu.T * x)[0, 0]
  let risk = sqrt((x.T * (a * x))[0, 0])
  (portfolio, ret, risk)

# --- Knapsack (continuous variant) --------------------------------------

proc continuumKnapsack*(a, b: seq[float], c: float):
                       (float, seq[(int, float)]) =
  ## Greedy continuous knapsack. Returns (total return, [(index, fraction)]).
  var table: seq[(float, int)] = @[]
  for i in 0 ..< a.len: table.add (a[i] / b[i], i)
  table.sort(SortOrder.Descending)
  var f = 0.0
  var x: seq[(int, float)] = @[]
  var c = c
  for (y, i) in table:
    let quantity = min(c / b[i], 1.0)
    x.add (i, quantity)
    c -= b[i] * quantity
    f += a[i] * quantity
  (f, x)

# --- Simple trading strategy and synthetic prices ----------------------

type
  Trader* = ref object

proc model*(t: Trader, window: seq[float]): float =
  var points: seq[(float, float, float)] = @[]
  for i, v in window:
    points.add (float(i), v, 1.0)
  let (_, _, fittingF) = fitLeastSquares(points, QUADRATIC)
  fittingF(float(points.len))

proc strategy*(t: Trader, history: seq[float], ndays = 7): string =
  if history.len < ndays: return ""
  let todayClose = history[^1]
  let tomorrowPrediction = t.model(history[^ndays .. ^1])
  if tomorrowPrediction > todayClose: "buy" else: "sell"

proc simulate*(t: Trader, data: seq[float],
               cash = 1000.0, shares = 0.0,
               dailyRate = 0.03 / 360.0): float =
  var cash = cash
  var shares = shares
  for tIdx in 0 ..< data.len:
    let suggestion = t.strategy(data[0 ..< tIdx])
    let todayClose = data[max(tIdx - 1, 0)]
    if cash > 0 and suggestion == "buy":
      let sharesBought = float(int(cash / todayClose))
      shares += sharesBought
      cash -= sharesBought * todayClose
    elif shares > 0 and suggestion == "sell":
      cash += shares * todayClose
      shares = 0.0
    cash *= exp(dailyRate)
  cash + shares * data[^1]

proc fakeStockPrices*(startPrice = 100.0, averageReturn = 0.05,
                     volatility = 0.30, days = 100): seq[float] =
  let dailyVolatility = volatility / sqrt(250.0)
  let dailyReturn = averageReturn / 250.0
  var s: seq[float] = @[]
  for _ in 0 ..< days - 1: s.add gauss(0.0, dailyVolatility)
  var sumS = 0.0
  for v in s: sumS += v
  let mu = dailyReturn - sumS / float(days - 1)
  var v = @[startPrice]
  for item in s:
    v.add v[^1] * exp(mu + item)
  result = v
