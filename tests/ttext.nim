import std/unittest
import nlib/text

suite "text":
  test "lcs matches known sequences":
    check lcs("ABCBDAB", "BDCAB") == 4
    check lcs("AGGTAB", "GXTXAYB") == 4
    check lcs("", "ABC") == 0
    check lcs("ABC", "") == 0
    check lcs("ABCDE", "ABCDE") == 5

  test "needlemanWunsch matrix has expected shape":
    let z = needlemanWunsch("ATGC", "ATGC")
    check z.len == 4
    check z[0].len == 4
    # Diagonal should grow with each match
    check z[3][3] >= 4.0 * 0.5

  test "needlemanWunsch identical strings score n":
    let z = needlemanWunsch("AAAA", "AAAA")
    check z[3][3] == 4.0
