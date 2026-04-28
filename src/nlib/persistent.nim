## A simple persistent key/value store backed by a JSON file. The
## chapters call this `PersistentDictionary`; the book sketch used
## SQLite, but a JSON file has no external dependencies and serves
## the memoization and cached-stock-data use cases just as well.

import std/[json, os, tables]

type
  PersistentDictionary* = ref object
    path*: string
    cache*: Table[string, JsonNode]

proc load(p: PersistentDictionary) =
  if fileExists(p.path):
    let raw = readFile(p.path)
    if raw.len > 0:
      let root = parseJson(raw)
      for k, v in root:
        p.cache[k] = v

proc save(p: PersistentDictionary) =
  var root = newJObject()
  for k, v in p.cache:
    root[k] = v
  writeFile(p.path, $root)

proc newPersistentDictionary*(path: string): PersistentDictionary =
  result = PersistentDictionary(path: path,
                                cache: initTable[string, JsonNode]())
  load(result)

proc close*(p: PersistentDictionary) =
  save(p)

proc `[]=`*(p: PersistentDictionary, key: string, value: JsonNode) =
  p.cache[key] = value
  save(p)

proc `[]`*(p: PersistentDictionary, key: string): JsonNode =
  if key in p.cache: p.cache[key] else: nil

proc contains*(p: PersistentDictionary, key: string): bool =
  key in p.cache

proc del*(p: PersistentDictionary, key: string) =
  p.cache.del(key)
  save(p)
