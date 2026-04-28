import std/[unittest, random]
import nlib/neural

suite "neural":
  test "XOR network learns within tolerance":
    randomize(123)
    let pat = @[(@[0.0, 0.0], @[0.0]),
                (@[0.0, 1.0], @[1.0]),
                (@[1.0, 0.0], @[1.0]),
                (@[1.0, 1.0], @[0.0])]
    let n = newNeuralNetwork(2, 4, 1)
    n.train(pat, iterations = 2000)
    check n.update(@[0.0, 0.0])[0] < 0.3
    check n.update(@[0.0, 1.0])[0] > 0.7
    check n.update(@[1.0, 0.0])[0] > 0.7
    check n.update(@[1.0, 1.0])[0] < 0.3

  test "constructor sets dimensions correctly":
    let n = newNeuralNetwork(3, 5, 2)
    check n.ni == 4   # +1 for bias
    check n.nh == 5
    check n.no == 2
    check n.wi.nrows == 4 and n.wi.ncols == 5
    check n.wo.nrows == 5 and n.wo.ncols == 2

  test "update rejects wrong-sized input":
    let n = newNeuralNetwork(2, 3, 1)
    expect ValueError:
      discard n.update(@[1.0])
