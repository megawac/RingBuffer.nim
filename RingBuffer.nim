import macros

type
  RingBuffer*[T] = object
    data*: seq[T]
    first*, last*: int
    size*: int
    length*: int

template adjustFirstIndex(b: expr): stmt  =  
  b.first = (b.length + b.last - b.size + 1) mod b.length;

template adjustLastIndex(b, change: expr): stmt  =  
  b.last = (b.last + change) mod b.length

proc newRingBuffer*[T](length: int): RingBuffer[T] =
  let s = newSeq[T](length)
  RingBuffer[T](data: s, first: 0, last: -1, size: 0, length: length)

proc `[]`*[T](b: RingBuffer[T], idx: int): T {.inline} =
  ## Get an item at index (adjusted)
  b.data[(idx + b.first) mod b.length]

proc `[]=`*[T](b: var RingBuffer[T], idx: int, item: T) {.raises: [IndexError].} =
  ## Set an item at index (adjusted)
  if idx == b.size: inc(b.size)
  elif idx > b.size: raise newException(IndexError, "Index " & $idx & " out of bound")

  b.data[(idx + b.first) mod b.length] = item

proc len*(b: RingBuffer): int = b.size

iterator `items`*[T](b: RingBuffer[T]): T =
  for i in 0..b.size - 1:
    yield b[i]

iterator `pairs`*[T](b: RingBuffer[T]): tuple[a: int, b: T] =
  for i in 0..b.size - 1:
    yield (i, b[i])

proc `@`*[T](b: RingBuffer[T]): seq[T] =
  ## Convert the buffer to a sequence
  var s = newSeq[T](b.size)
  for i, item in b:
    s[i] = item
  result = s

converter toSeq*[T](b: RingBuffer[T]): seq[T] = @b

# Inheritted
# - find
# - contains
# - slice?
# - map?
# - filter?
# - max?
# - min?

proc isFull*(b: RingBuffer): bool =
  ## Is the buffer at capacity (pushes will overwrite)
  b.size == b.length

proc add*[T](b: var RingBuffer[T], item: T) =
  ## Add an element to the buffer 
  adjustLastIndex(b, 1)
  b.data[b.last] = item
  b.size = min(b.size + 1, b.length)
  adjustFirstIndex(b)

proc add*[T](b: var RingBuffer[T], data: openArray[T]) =
  ## Add elements to the buffer 
  for item in data:
    adjustLastIndex(b, 1)
    b.data[b.last] = item
  b.size = min(b.size + len(data), b.length)
  adjustFirstIndex(b)

proc pop*[T](b: var RingBuffer[T]): T =
  ## Remove an element from the buffer and return it
  result = b.data[b.last] # Note: will throw error if oob
  adjustLastIndex(b, -1)
  b.size -= 1
  adjustFirstIndex(b)

discard """
  Reimplement some of the sequence utility functions
  TODO: remove these when http://stackoverflow.com/q/30035574/1517919
  is fixed
"""

proc find*[T](b: RingBuffer[T], val: T): int =
  ## Find the first index of a value or -1
  for i, v in b:
    if v == val: return i
  return -1

proc contains*[T](b: RingBuffer[T], val: T): bool = b.find(val) != -1
