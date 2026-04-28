import std/[unittest, os, json]
import nlib/persistent

suite "persistent":
  let path = getTempDir() / "nlib_test.sqlite"

  setup:
    removeFile(path)

  teardown:
    removeFile(path)

  test "round-trip primitive value":
    let p = newPersistentDictionary(path)
    p["pi"] = %3.141592653589793
    check "pi" in p
    check p["pi"].getFloat == 3.141592653589793
    p.close()

  test "round-trip object payload":
    let p = newPersistentDictionary(path)
    p["row"] = %*{"x": 1, "y": "two", "z": [3, 4]}
    let r = p["row"]
    check r["x"].getInt == 1
    check r["y"].getStr == "two"
    check r["z"][0].getInt == 3
    p.close()

  test "missing key reads as nil":
    let p = newPersistentDictionary(path)
    check p["nope"].isNil
    p.close()

  test "values survive a reopen":
    block:
      let p = newPersistentDictionary(path)
      p["alive"] = %42
      p.close()
    let q = newPersistentDictionary(path)
    check q["alive"].getInt == 42
    q.close()

  test "del removes a key":
    let p = newPersistentDictionary(path)
    p["doomed"] = %1
    p.del("doomed")
    check "doomed" notin p
    p.close()
