## Huffman coding (a Shannon--Fano-style minimal-prefix code).

import std/[heapqueue, tables]

type
  HuffmanTreeKind* = enum hkLeaf, hkNode
  HuffmanTree* = ref object
    frequency*: int
    case kind*: HuffmanTreeKind
    of hkLeaf: symbol*: char
    of hkNode: left*, right*: HuffmanTree

  HuffmanNode* = object
    frequency*: int
    tree*: HuffmanTree

proc `<`*(a, b: HuffmanNode): bool = a.frequency < b.frequency

proc inorderTreeWalk(t: HuffmanTree, key: string,
                     keys: var Table[char, string]) =
  case t.kind
  of hkLeaf: keys[t.symbol] = key
  of hkNode:
    inorderTreeWalk(t.left, key & "0", keys)
    inorderTreeWalk(t.right, key & "1", keys)

proc encodeHuffman*(input: string): (Table[char, string], string) =
  ## Huffman-encode `input`. Returns (symbol table, bit string).
  var symbols = initTable[char, int]()
  for s in input:
    symbols[s] = symbols.getOrDefault(s, 0) + 1
  var heap = initHeapQueue[HuffmanNode]()
  for k, f in symbols:
    heap.push(HuffmanNode(frequency: f,
              tree: HuffmanTree(kind: hkLeaf, frequency: f, symbol: k)))
  while heap.len > 1:
    let n1 = heap.pop()
    let n2 = heap.pop()
    let merged = HuffmanTree(kind: hkNode,
                             frequency: n1.frequency + n2.frequency,
                             left: n1.tree, right: n2.tree)
    heap.push(HuffmanNode(frequency: merged.frequency, tree: merged))
  var symbolMap = initTable[char, string]()
  if heap.len == 1:
    let only = heap[0].tree
    case only.kind
    of hkLeaf: symbolMap[only.symbol] = "0"   # single-symbol input
    of hkNode: inorderTreeWalk(only, "", symbolMap)
  var encoded = ""
  for s in input: encoded.add symbolMap[s]
  (symbolMap, encoded)

proc decodeHuffman*(keys: Table[char, string], encoded: string): string =
  var reversed = initTable[string, char]()
  for k, v in keys: reversed[v] = k
  var i = 0
  for j in 1 .. encoded.len:
    let chunk = encoded[i ..< j]
    if chunk in reversed:
      result.add reversed[chunk]
      i = j
