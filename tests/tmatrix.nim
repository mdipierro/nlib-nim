import std/unittest
import nlib/matrix

suite "matrix":
  test "construction and indexing":
    let a = newMatrix(@[@[1.0, 2.0], @[3.0, 4.0]])
    check a.nrows == 2 and a.ncols == 2
    check a[0, 0] == 1.0 and a[1, 1] == 4.0
    a[0, 1] = 99.0
    check a[0, 1] == 99.0

  test "fill constructor":
    let a = newMatrix(2, 3, 7.0)
    check a[0, 0] == 7.0 and a[1, 2] == 7.0

  test "callable fill":
    let a = newMatrix(3, 3,
      proc(r, c: int): float = float(r * 10 + c))
    check a[2, 1] == 21.0

  test "identity, diagonal, transpose":
    let i = identity(3)
    check i[0, 0] == 1.0 and i[1, 0] == 0.0 and i[2, 2] == 1.0
    let d = diagonal(@[1.0, 2.0, 3.0])
    check d[1, 1] == 2.0
    let m = newMatrix(@[@[1.0, 2.0], @[3.0, 4.0]])
    let t = m.T()
    check t[0, 1] == 3.0 and t[1, 0] == 2.0

  test "addition, subtraction, scalar broadcast":
    let a = newMatrix(@[@[1.0, 2.0], @[3.0, 4.0]])
    let s = a + a
    check s[0, 0] == 2.0 and s[1, 1] == 8.0
    let n = -a
    check n[0, 0] == -1.0
    let p = a + 1.0          # square + scalar -> add identity
    check p[0, 0] == 2.0 and p[0, 1] == 2.0

  test "matrix multiplication":
    let a = newMatrix(@[@[1.0, 2.0], @[3.0, 4.0]])
    let b = a * a
    check b[0, 0] == 7.0
    check b[1, 0] == 15.0
    check b[1, 1] == 22.0

  test "scalar product of column vectors":
    let u = newMatrix(@[1.0, 2.0, 3.0])
    let v = newMatrix(@[4.0, 5.0, 6.0])
    let s = u * v
    check s.nrows == 1 and s.ncols == 1
    check s[0, 0] == 32.0

  test "inverse and division":
    let a = newMatrix(@[@[1.0, 2.0], @[4.0, 9.0]])
    let inv = 1.0 / a
    let i = a * inv
    check abs(i[0, 0] - 1.0) < 1e-9
    check abs(i[0, 1]) < 1e-9
    check abs(i[1, 1] - 1.0) < 1e-9

  test "isAlmostSymmetric":
    let s = newMatrix(@[@[1.0, 2.0], @[2.0, 4.0]])
    check s.isAlmostSymmetric()
    let n = newMatrix(@[@[1.0, 2.0], @[3.0, 4.0]])
    check not n.isAlmostSymmetric()

  test "reshape preserves data":
    let a = newMatrix(@[@[1.0, 2.0, 3.0], @[4.0, 5.0, 6.0]])
    let r = a.reshape(3, 2)
    check r.nrows == 3 and r.ncols == 2
    check r[0, 0] == 1.0 and r[2, 1] == 6.0
