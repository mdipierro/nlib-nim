## Max-heap operations on a `seq[T]`. The standard library's `std/heapqueue`
## is a min-heap; this module is the max-heap counterpart used in the book.

proc heapParent(i: int): int = (i - 1) div 2
proc heapLeftChild(i: int): int = 2 * i + 1
proc heapRightChild(i: int): int = 2 * i + 2

proc heapifyOne*[T](a: var seq[T], i: int, heapsize = -1) =
  ## Restore the max-heap property at index `i`.
  let heapsize = if heapsize < 0: a.len else: heapsize
  let left = heapLeftChild(i)
  let right = heapRightChild(i)
  var largest = i
  if left < heapsize and a[left] > a[largest]:
    largest = left
  if right < heapsize and a[right] > a[largest]:
    largest = right
  if largest != i:
    swap(a[i], a[largest])
    heapifyOne(a, largest, heapsize)

proc heapify*[T](a: var seq[T]) =
  ## Reorder `a` into a max-heap. O(n).
  for i in countdown(a.len div 2 - 1, 0):
    heapifyOne(a, i)

proc heapsort*[T](a: var seq[T]) =
  ## In-place heapsort. O(n log n).
  heapify(a)
  for i in countdown(a.len - 1, 1):
    swap(a[0], a[i])
    heapifyOne(a, 0, i)

proc heapPop*[T](a: var seq[T]): T =
  ## Remove and return the maximum element of the heap.
  if a.len < 1:
    raise newException(IndexDefect, "Heap Underflow")
  result = a[0]
  a[0] = a[^1]
  a.setLen(a.len - 1)
  if a.len > 0:
    heapifyOne(a, 0)

proc heapPush*[T](a: var seq[T], value: T) =
  ## Insert `value` into the heap, preserving the max-heap property.
  a.add value
  var i = a.len - 1
  while i > 0:
    let j = heapParent(i)
    if a[j] < a[i]:
      swap(a[i], a[j])
      i = j
    else:
      break
