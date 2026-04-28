import std/[unittest, math]
import nlib/cluster

suite "cluster":
  test "agglomerative cluster reduces count toward 1":
    proc metric(a, b: seq[float]): float =
      var s = 0.0
      for i in 0 ..< a.len: s += (a[i] - b[i]) ^ 2
      sqrt(s)
    let points = @[@[0.0, 0.0], @[0.1, 0.1], @[0.2, 0.0],
                    @[5.0, 5.0], @[5.1, 4.9], @[4.9, 5.1]]
    let c = newCluster[seq[float]](points, metric)
    check c.k == 6
    let (_, clusters) = c.find(2)
    check clusters.len == 2
    # the 6 points should split 3 / 3 between the two near-clusters
    check clusters[0].len + clusters[1].len == 6

  test "find 1 collapses to a single cluster":
    proc metric(a, b: seq[float]): float =
      sqrt((a[0] - b[0]) ^ 2)
    let points = @[@[0.0], @[1.0], @[2.0]]
    let c = newCluster[seq[float]](points, metric)
    let (_, clusters) = c.find(1)
    check clusters.len == 1
    check clusters[0].len == 3
