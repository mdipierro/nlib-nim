import std/unittest
import nlib/bst

suite "bst":
  test "insert and lookup":
    let t = newBinarySearchTree[int, string]()
    t[5] = "aaa"
    t[3] = "bbb"
    t[8] = "ccc"
    check t[3] == "bbb"
    check t[5] == "aaa"
    check t[8] == "ccc"

  test "missing key returns default":
    let t = newBinarySearchTree[int, string]()
    t[5] = "x"
    check t[42] == ""    # default(string)

  test "min and max":
    let t = newBinarySearchTree[int, string]()
    for (k, v) in [(5, "five"), (3, "three"), (8, "eight"),
                   (1, "one"), (9, "nine")]:
      t[k] = v
    check t.min() == (1, "one")
    check t.max() == (9, "nine")

  test "update overwrites":
    let t = newBinarySearchTree[int, string]()
    t[5] = "old"
    t[5] = "new"
    check t[5] == "new"
