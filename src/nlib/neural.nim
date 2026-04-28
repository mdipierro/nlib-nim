## Simple back-propagation neural network with one hidden layer.

import std/[math, random, sequtils]
import ./matrix

type
  NeuralNetwork* = ref object
    ni*, nh*, no*: int
    ai*, ah*, ao*: seq[float]
    wi*, wo*: Matrix
    ci*, co*: Matrix         # last weight change (momentum)

proc nnRand(a, b: float): float = (b - a) * rand(1.0) + a
proc sigmoid*(x: float): float = tanh(x)
proc dsigmoid*(y: float): float = 1.0 - y * y

proc newNeuralNetwork*(ni, nh, no: int): NeuralNetwork =
  result = NeuralNetwork(
    ni: ni + 1,                           # +1 for bias node
    nh: nh, no: no,
    ai: newSeqWith(ni + 1, 1.0),
    ah: newSeqWith(nh, 1.0),
    ao: newSeqWith(no, 1.0),
    wi: newMatrix(ni + 1, nh,
                  proc(r, c: int): float = nnRand(-0.2, 0.2)),
    wo: newMatrix(nh, no,
                  proc(r, c: int): float = nnRand(-2.0, 2.0)),
    ci: newMatrix(ni + 1, nh),
    co: newMatrix(nh, no))

proc update*(n: NeuralNetwork, inputs: seq[float]): seq[float] =
  if inputs.len != n.ni - 1:
    raise newException(ValueError, "wrong number of inputs")
  for i in 0 ..< n.ni - 1: n.ai[i] = inputs[i]
  for j in 0 ..< n.nh:
    var s = 0.0
    for i in 0 ..< n.ni: s += n.ai[i] * n.wi[i, j]
    n.ah[j] = sigmoid(s)
  for k in 0 ..< n.no:
    var s = 0.0
    for j in 0 ..< n.nh: s += n.ah[j] * n.wo[j, k]
    n.ao[k] = sigmoid(s)
  result = n.ao

proc backPropagate*(n: NeuralNetwork, targets: seq[float],
                    N, M: float): float =
  if targets.len != n.no:
    raise newException(ValueError, "wrong number of target values")
  var outputDeltas = newSeq[float](n.no)
  for k in 0 ..< n.no:
    let error = targets[k] - n.ao[k]
    outputDeltas[k] = dsigmoid(n.ao[k]) * error
  var hiddenDeltas = newSeq[float](n.nh)
  for j in 0 ..< n.nh:
    var error = 0.0
    for k in 0 ..< n.no: error += outputDeltas[k] * n.wo[j, k]
    hiddenDeltas[j] = dsigmoid(n.ah[j]) * error
  for j in 0 ..< n.nh:
    for k in 0 ..< n.no:
      let change = outputDeltas[k] * n.ah[j]
      n.wo[j, k] = n.wo[j, k] + N * change + M * n.co[j, k]
      n.co[j, k] = change
  for i in 0 ..< n.ni:
    for j in 0 ..< n.nh:
      let change = hiddenDeltas[j] * n.ai[i]
      n.wi[i, j] = n.wi[i, j] + N * change + M * n.ci[i, j]
      n.ci[i, j] = change
  for k in 0 ..< targets.len:
    result += 0.5 * (targets[k] - n.ao[k]) ^ 2

proc test*(n: NeuralNetwork, patterns: seq[(seq[float], seq[float])]) =
  for p in patterns:
    echo p[0], " -> ", n.update(p[0])

proc train*(n: NeuralNetwork,
            patterns: seq[(seq[float], seq[float])],
            iterations = 1000, N = 0.5, M = 0.1, check = false) =
  for i in 0 ..< iterations:
    var error = 0.0
    for p in patterns:
      discard n.update(p[0])
      error += n.backPropagate(p[1], N, M)
    if check and i mod 100 == 0:
      echo "error ", error
