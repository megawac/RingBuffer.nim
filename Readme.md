### Nim implementation of Circular buffers [![Build Status](https://travis-ci.org/megawac/RingBuffer.nim.svg)](https://travis-ci.org/megawac/RingBuffer.nim)

[**Documentation**](http://rawgit.com/megawac/RingBuffer.nim/master/docs/RingBuffer.html)

> A circular buffer, cyclic buffer or ring buffer is a data structure that uses a single, fixed-size buffer as if it were connected end-to-end. This structure lends itself easily to buffering data streams.
> 
> [Wikipedia](http://en.wikipedia.org/wiki/Circular_buffer)

![](http://www.boost.org/doc/libs/1_58_0/libs/circular_buffer/doc/images/circular_buffer.png)

#### Usage

```nim
var b = newRingBuffer[int](5)

b.add([1, 2, 3, 4, 5])
b.add(6)
b.add([7, 8])

@b == [4, 5, 6, 7, 8]
```