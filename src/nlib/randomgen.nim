## Pseudo-random number generators and probability distributions.
##
## Two custom generators are provided for didactic purposes (an LCG and
## a 32-bit Mersenne Twister) alongside a `RandomSource` adapter that
## wraps any `proc(): float` and exposes the distributions used in the
## book (uniform, Bernoulli, binomial, Poisson, exponential, Pareto,
## point-on-circle/sphere, etc.).

import std/[bitops, math, options, random]

# --- Linear congruential generator -------------------------------------

type
  MCG* = ref object
    x*, a*, m*: int

proc newMCG*(seed: int, a = 66539, m = 1 shl 31): MCG =
  MCG(x: seed, a: a, m: m)

proc next*(g: MCG): int =
  g.x = (g.a * g.x) mod g.m
  g.x

proc random*(g: MCG): float =
  float(g.next()) / float(g.m)

proc leapfrog*(mcg: MCG, k: int): seq[MCG] =
  ## Generate `k` independent leapfrog sub-streams from `mcg`.
  # Compute (mcg.a^k) mod mcg.m incrementally to avoid integer overflow.
  var a = 1
  for _ in 0 ..< k:
    a = (a * mcg.a) mod mcg.m
  for i in 0 ..< k:
    result.add newMCG(mcg.next(), a, mcg.m)

# --- 32-bit Mersenne Twister (MT19937) ---------------------------------

type
  MarsenneTwister* = ref object
    w*: array[625, uint32]
    wi*: int

proc newMarsenneTwister*(seed: uint32 = 4357'u32): MarsenneTwister =
  result = MarsenneTwister()
  result.w[0] = seed
  for i in 1 ..< 625:
    result.w[i] = 69069'u32 * result.w[i-1]
  result.wi = 624

proc random*(g: MarsenneTwister): float =
  const
    N = 624
    M = 397
    U = 0x80000000'u32
    L = 0x7fffffff'u32
  let K = [0'u32, 0x9908b0df'u32]
  var y: uint32 = 0
  if g.wi >= N:
    var kk = 0
    while kk < N - M:
      y = (g.w[kk] and U) or (g.w[kk + 1] and L)
      g.w[kk] = g.w[kk + M] xor (y shr 1) xor K[y and 1'u32]
      inc kk
    while kk < N - 1:
      y = (g.w[kk] and U) or (g.w[kk + 1] and L)
      g.w[kk] = g.w[kk + (M - N)] xor (y shr 1) xor K[y and 1'u32]
      inc kk
    y = (g.w[N - 1] and U) or (g.w[0] and L)
    g.w[N - 1] = g.w[M - 1] xor (y shr 1) xor K[y and 1'u32]
    g.wi = 0
  y = g.w[g.wi]; inc g.wi
  y = y xor (y shr 11)
  y = y xor ((y shl 7) and 0x9d2c5680'u32)
  y = y xor ((y shl 15) and 0xefc60000'u32)
  y = y xor (y shr 18)
  result = float(y) / float(0xffffffff'u32)

# --- RandomSource adapter ----------------------------------------------

type
  RandomSource* = ref object
    generator*: proc(): float    # any uniform `[0, 1)` source

proc newRandomSource*(generator: proc(): float = nil): RandomSource =
  let g = if generator.isNil: (proc(): float = rand(1.0)) else: generator
  RandomSource(generator: g)

proc random*(r: RandomSource): float = r.generator()

proc randint*(r: RandomSource, a, b: int): int =
  a + int(float(b - a + 1) * r.random())

proc choice*[T](r: RandomSource, S: openArray[T]): T =
  S[r.randint(0, S.len - 1)]

proc bernoulli*(r: RandomSource, p: float): int =
  if r.random() < p: 1 else: 0

proc lookup*[K](r: RandomSource, table: seq[(K, float)],
                epsilon = 1e-6): K =
  var u = r.random()
  for (key, p) in table:
    if u < p + epsilon: return key
    u = u - p
  raise newException(ArithmeticDefect, "invalid probability")

# --- Fishman-Yarberry tree lookup --------------------------------------

type
  FishmanYarberry*[K] = ref object
    table*: seq[(K, float)]
    t*: int
    a*: seq[seq[float]]

proc newFishmanYarberry*[K](table0: seq[(K, float)]):
                            FishmanYarberry[K] =
  var table = table0
  var n = table.len
  while (n and (n - 1)) != 0:
    table.add (default(K), 0.0)
    n = table.len
  let t = fastLog2(n)
  var a: seq[seq[float]] = @[]
  for i in 0 ..< t:
    var row: seq[float] = @[]
    if i == 0:
      for j in 0 ..< n: row.add table[j][1]
    else:
      let prev = a[i - 1]
      for j in 0 ..< (n shr i):
        row.add prev[2 * j] + prev[2 * j + 1]
    a.add row
  FishmanYarberry[K](table: table, t: t, a: a)

proc discreteMap*[K](fy: FishmanYarberry[K], u: float): K =
  var i = fy.t - 1
  var j = 0
  var b = 0.0
  var u = u
  while i > 0:
    if u > b + fy.a[i][j]:
      b += fy.a[i][j]
      j = 2 * j + 2
    else:
      j = 2 * j
    dec i
  if u > b + fy.a[i][j]:
    j += 1
  fy.table[j][0]

# --- Discrete distributions --------------------------------------------

proc binomial*(r: RandomSource, n: int, p: float,
               epsilon = 1e-6): int =
  var u = r.random()
  var q = pow(1.0 - p, float(n))
  for k in 0 .. n:
    if u < q + epsilon: return k
    u = u - q
    q = q * float(n - k) / float(k + 1) * p / (1.0 - p)
  raise newException(ArithmeticDefect, "invalid probability")

proc negativeBinomial*(r: RandomSource, k: int, p: float,
                       epsilon = 1e-6): int =
  var u = r.random()
  var n = k
  var q = pow(p, float(k))
  while true:
    if u < q + epsilon: return n
    u = u - q
    q = q * float(n) / float(n - k + 1) * (1.0 - p)
    n += 1

proc poisson*(r: RandomSource, lamb: float, epsilon = 1e-6): int =
  var u = r.random()
  var q = exp(-lamb)
  var k = 0
  while true:
    if u < q + epsilon: return k
    u = u - q
    q = q * lamb / float(k + 1)
    k += 1

# --- Continuous distributions ------------------------------------------

proc uniform*(r: RandomSource, a, b: float): float =
  a + (b - a) * r.random()

proc exponential*(r: RandomSource, lamb: float): float =
  -ln(r.random()) / lamb

proc pareto*(r: RandomSource, alpha, xm: float): float =
  let u = r.random()
  xm * pow(1.0 - u, -1.0 / alpha)

proc pointOnCircle*(r: RandomSource, radius = 1.0): (float, float) =
  let angle = 2.0 * PI * r.random()
  (radius * cos(angle), radius * sin(angle))

proc pointInCircle*(r: RandomSource, radius = 1.0): (float, float) =
  while true:
    let x = r.uniform(-radius, radius)
    let y = r.uniform(-radius, radius)
    if x * x + y * y < radius * radius:
      return (x, y)

proc pointInSphere*(r: RandomSource, radius = 1.0):
                   (float, float, float) =
  while true:
    let x = r.uniform(-radius, radius)
    let y = r.uniform(-radius, radius)
    let z = r.uniform(-radius, radius)
    if x * x + y * y + z * z < radius * radius:
      return (x, y, z)

proc pointOnSphere*(r: RandomSource, radius = 1.0):
                   (float, float, float) =
  let (x, y, z) = r.pointInSphere(radius)
  let nrm = sqrt(x * x + y * y + z * z)
  (x / nrm, y / nrm, z / nrm)

# --- Marsaglia-polar Gaussian via cached pair --------------------------

type
  GaussRandomSource* = ref object
    base*: RandomSource
    other*: Option[float]

proc newGaussRandomSource*(base: RandomSource): GaussRandomSource =
  GaussRandomSource(base: base, other: none(float))

proc gauss*(g: GaussRandomSource, mu = 0.0, sigma = 1.0): float =
  var thisVal: float
  if g.other.isSome:
    thisVal = g.other.get()
    g.other = none(float)
  else:
    var v1, v2, r: float
    while true:
      v1 = g.base.uniform(-1.0, 1.0)
      v2 = g.base.uniform(-1.0, 1.0)
      r = v1 * v1 + v2 * v2
      if r < 1: break
    thisVal = sqrt(-2.0 * ln(r) / r) * v1
    g.other = some(sqrt(-2.0 * ln(r) / r) * v2)
  mu + sigma * thisVal

# --- Confidence intervals & resampling ---------------------------------

const CONFIDENCE* = [
  (0.68,    1.0),
  (0.80,    1.281551565545),
  (0.90,    1.644853626951),
  (0.95,    1.959963984540),
  (0.98,    2.326347874041),
  (0.99,    2.575829303549),
  (0.995,   2.807033768344),
  (0.998,   3.090232306168),
  (0.999,   3.290526731492),
  (0.9999,  3.890591886413),
  (0.99999, 4.417173413469)
]

proc confidenceIntervals*(mu, sigma: float): seq[(float, float, float)] =
  for (a, b) in CONFIDENCE:
    result.add (a, mu - b * sigma, mu + b * sigma)

proc resample*[T](S: openArray[T], size = -1): seq[T] =
  let n = if size < 0: S.len else: size
  for _ in 0 ..< n: result.add sample(S)
