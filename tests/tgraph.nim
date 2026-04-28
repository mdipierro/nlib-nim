import std/[unittest, random, sequtils]
import nlib/graph

suite "graph":
  randomize(0)

  test "BFS visits everything reachable":
    let vertices = @["A", "B", "C", "D", "E"]
    let links = @[(0, 1), (1, 2), (1, 3), (2, 4)]
    let order = breadthFirstSearch((vertices, links), 0)
    check order.len == 5
    check 0 in order and 4 in order

  test "DFS visits everything reachable":
    let vertices = @["A", "B", "C", "D", "E"]
    let links = @[(0, 1), (1, 2), (1, 3), (2, 4)]
    let order = depthFirstSearch((vertices, links), 0)
    check order.len == 5

  test "DisjointSets join / joined / len":
    let ds = newDisjointSets(5)
    check ds.len == 5
    check ds.joined(0, 1) == false
    check ds.join(0, 1) == true
    check ds.len == 4
    check ds.joined(0, 1) == true
    check ds.join(0, 1) == false   # already joined
    check ds.join(2, 3) == true
    check ds.join(1, 3) == true
    check ds.len == 2

  test "makeMaze tears down enough walls":
    let (remaining, tornDown) = makeMaze(5, 2)
    # In any 5x5 maze, exactly 24 walls must be torn down to connect
    # all 25 cells (one per cell minus one).
    check tornDown.len == 24
    check remaining.len > 0

  test "Kruskal MST":
    let vertices = @["A", "B", "C", "D"]
    let links = @[(0, 1, 1.0), (1, 2, 2.0), (0, 2, 4.0),
                  (2, 3, 3.0), (1, 3, 5.0)]
    let mst = kruskal((vertices, links))
    check mst.len == 3                   # n - 1 edges
    var totalWeight = 0.0
    for (_, _, w) in mst: totalWeight += w
    check abs(totalWeight - 6.0) < 1e-9   # 1 + 2 + 3

  test "Prim returns n-1 links":
    let vertices = toSeq(0 ..< 5)
    var links: seq[(int, int, float)] = @[]
    for i in vertices:
      for j in vertices:
        if i != j:
          links.add (i, j, abs(float((i - j) * (i - j))))
    let mst = prim((vertices, links), 0)
    check mst.len == 4

  test "Dijkstra distances are non-negative and finite":
    let vertices = toSeq(0 ..< 4)
    let links = @[(0, 1, 1.0), (1, 0, 1.0),
                  (1, 2, 2.0), (2, 1, 2.0),
                  (2, 3, 1.0), (3, 2, 1.0),
                  (0, 3, 10.0), (3, 0, 10.0)]
    let paths = dijkstra((vertices, links), 0)
    for (_, _, d) in paths:
      check d >= 0
      check d < 1e50
