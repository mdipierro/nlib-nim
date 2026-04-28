## Basic descriptive statistics.

import std/math

proc E*(f: proc(x: float): float, S: seq[float]): float =
  ## Expectation of `f` over the sample set `S`.
  if S.len == 0: return 0.0
  for x in S: result += f(x)
  result /= float(S.len)

proc mean*(X: seq[float]): float =
  E(proc(x: float): float = x, X)

proc variance*(X: seq[float]): float =
  let mu = mean(X)
  E(proc(x: float): float = (x - mu) ^ 2, X)

proc sd*(X: seq[float]): float = sqrt(variance(X))

proc covariance*(X, Y: seq[float]): float =
  for i in 0 ..< X.len: result += X[i] * Y[i]
  result = result / float(X.len) - mean(X) * mean(Y)

proc correlation*(X, Y: seq[float]): float =
  covariance(X, Y) / sd(X) / sd(Y)
