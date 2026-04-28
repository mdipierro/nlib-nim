## Generic memoization utility.

import std/tables

proc memoize*[K, V](f: proc(self: proc(x: K): V, x: K): V):
                     proc(x: K): V =
  ## Returns a memoized version of `f`. The recursive function `f`
  ## takes the memoized closure as its first argument so it can recurse
  ## through the cache.
  var storage = initTable[K, V]()
  proc memoized(x: K): V =
    if x in storage: return storage[x]
    result = f(memoized, x)
    storage[x] = result
  return memoized
