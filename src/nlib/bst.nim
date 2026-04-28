## Binary search tree, recursively implemented.

type
  BinarySearchTree*[K, V] = ref object
    key*: K
    value*: V
    hasKey*: bool
    left*, right*: BinarySearchTree[K, V]

proc newBinarySearchTree*[K, V](): BinarySearchTree[K, V] =
  BinarySearchTree[K, V]()

proc `[]=`*[K, V](t: BinarySearchTree[K, V], key: K, value: V) =
  if not t.hasKey:
    t.key = key; t.value = value; t.hasKey = true
  elif key == t.key:
    t.value = value
  elif key < t.key:
    if t.left.isNil: t.left = newBinarySearchTree[K, V]()
    t.left[key] = value
  else:
    if t.right.isNil: t.right = newBinarySearchTree[K, V]()
    t.right[key] = value

proc `[]`*[K, V](t: BinarySearchTree[K, V], key: K): V =
  if not t.hasKey: return default(V)
  if key == t.key: return t.value
  elif key < t.key and not t.left.isNil: return t.left[key]
  elif key > t.key and not t.right.isNil: return t.right[key]
  else: return default(V)

proc min*[K, V](t: BinarySearchTree[K, V]): (K, V) =
  var node = t
  while not node.left.isNil: node = node.left
  (node.key, node.value)

proc max*[K, V](t: BinarySearchTree[K, V]): (K, V) =
  var node = t
  while not node.right.isNil: node = node.right
  (node.key, node.value)
