import std/[unittest, random, sequtils]
from std/algorithm import sort
import nlib/sorting

suite "sorting":
  randomize(42)

  test "insertionSort":
    var a = @[5, 3, 8, 1, 4, 2]
    insertionSort(a)
    check a == @[1, 2, 3, 4, 5, 8]

  test "insertionSort empty":
    var a: seq[int] = @[]
    insertionSort(a)
    check a.len == 0

  test "insertionSort already sorted":
    var a = @[1, 2, 3, 4, 5]
    insertionSort(a)
    check a == @[1, 2, 3, 4, 5]

  test "mergesort random":
    var a = newSeq[int](200)
    for i in 0 ..< 200: a[i] = rand(1000)
    var expected = a; expected.sort()
    mergesort(a)
    check a == expected

  test "mergesortNonrecursive matches mergesort":
    var a = newSeq[int](100)
    for i in 0 ..< 100: a[i] = rand(1000)
    var b = a
    mergesort(a)
    mergesortNonrecursive(b)
    check a == b

  test "quicksort random":
    var a = newSeq[int](200)
    for i in 0 ..< 200: a[i] = rand(1000)
    var expected = a; expected.sort()
    quicksort(a)
    check a == expected

  test "countingsort":
    var a = @[3, 0, 5, 7, 2, 5, 1]
    countingsort(a)
    check a == @[0, 1, 2, 3, 5, 5, 7]

  test "countingsort rejects negatives":
    var a = @[-1, 2, 3]
    expect ValueError:
      countingsort(a)

  test "binarySearch hit":
    let a = @[1, 3, 5, 7, 9, 11]
    check binarySearch(a, 7) == 3
    check binarySearch(a, 1) == 0
    check binarySearch(a, 11) == 5

  test "binarySearch miss":
    let a = @[1, 3, 5, 7, 9]
    check binarySearch(a, 4) == -1
    check binarySearch(a, 100) == -1
