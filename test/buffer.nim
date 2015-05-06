import unittest
import "../RingBuffer"

var buffer: RingBuffer[int]

suite "Indexs":
  buffer = newRingBuffer[int](3)
  buffer[0] = 1
  buffer[1] = 2
  buffer[2] = 3

  test "Checking size":
    check buffer.len == 3

  test "Getting":
    check buffer[0] == 1
    check buffer[1] == 2
    check buffer[2] == 3

  test "Overwriting":
    buffer[1] = 15
    check buffer[1] == 15
    check len(buffer) == 3

suite "Adding":
  buffer = newRingBuffer[int](3)
  buffer.add([1, 2, 3])

  test "Getting":
    check buffer[0] == 1
    check buffer[1] == 2
    check buffer[2] == 3

  test "Circular add":
    buffer.add(4)
    check buffer[0] == 2
    buffer.add(5)
    buffer.add(6)
    let s = @buffer
    check s == @[4, 5, 6]

  test "Circular openArray add":
    buffer.add([7, 8])
    let s = @buffer
    check s == @[6, 7, 8]

  test "Maintains correct size & length":
    check buffer.len == 3
    check buffer.length == 3

  test "Popping":
    let r = buffer.pop()
    check r == 8
    check buffer.len == 2
    let s = @buffer
    check s == @[6, 7]

import sequtils

suite "Sequence utilities":
  buffer = newRingBuffer[int](3)
  buffer.add([1, 2, 3])
  buffer.add([4, 5])

  test "`@` operator":
    let s = @buffer
    check s == @[3, 4, 5]

  test "`find`":
    var contained = buffer.find(1)
    check contained == -1
    contained = buffer.find(5)
    check contained == 2

  test "`contains`":
    var contained = 1 in buffer
    check contained == false
    contained = 5 in buffer
    check contained == true

