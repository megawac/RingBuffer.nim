import macros

type
  RingBuffer*[T] = object
    ## A ring buffer is a sequence-like type which can store
    ## up to `length` elements. After `length` elements are
    ## added to the buffer, new items will begin to replace
    ## the oldest ones (i.e. the elements at the start of the
    ## buffer).
    data: seq[T]
    # indicates where elements should be positioned in data
    head, tail: int
    size, length*: int

template adjustHead(b: expr): stmt =  
  b.head = (b.length + b.tail - b.size + 1) mod b.length;

template adjustTail(b, change: expr): stmt =  
  b.tail = (b.tail + change) mod b.length

proc newRingBuffer*[T](length: int): RingBuffer[T] =
  ## Construct a new Ringbuffer which can hold up to `length` elements
  let s = newSeq[T](length)
  RingBuffer[T](data: s, head: 0, tail: -1, size: 0, length: length)

proc `[]`*[T](b: RingBuffer[T], idx: int): T {.inline} =
  ## Get an item at index (adjusted)
  b.data[(idx + b.head) mod b.length]

proc `[]=`*[T](b: var RingBuffer[T], idx: int, item: T) {.raises: [IndexError].} =
  ## Set an item at index (adjusted)
  if idx == b.size: inc(b.size)
  elif idx > b.size: raise newException(IndexError, "Index " & $idx & " out of bound")

  b.data[(idx + b.head) mod b.length] = item

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
  adjustTail(b, 1)
  b.data[b.tail] = item
  b.size = min(b.size + 1, b.length)
  adjustHead(b)

proc add*[T](b: var RingBuffer[T], data: openArray[T]) =
  ## Add elements to the buffer 
  for item in data:
    adjustTail(b, 1)
    b.data[b.tail] = item
  b.size = min(b.size + len(data), b.length)
  adjustHead(b)

proc pop*[T](b: var RingBuffer[T]): T =
  ## Remove an element from the buffer and return it
  result = b.data[b.tail] # Note: will throw error if oob
  adjustTail(b, -1)
  b.size -= 1
  adjustHead(b)

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

proc `contains`*[T](b: RingBuffer[T], val: T): bool = b.find(val) != -1
