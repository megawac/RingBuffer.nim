# Package
version       = "0.1.4"
author        = "Graeme Yeates"
description   = "Circular buffer implementation"
license       = "MIT"

# Dependencies
requires "nim >= 0.10.0"

# Tasks
task test, "Runs the test suite":
  exec "nim c -r -f test/buffer.nim"
