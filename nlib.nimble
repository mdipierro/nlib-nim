# Package

version       = "0.1.0"
author        = "Massimo Di Pierro"
description   = "Numerical algorithms accompanying the book Annotated Algorithms in Nim."
license       = "BSD-3-Clause"
srcDir        = "src"
skipDirs      = @["tests"]
installExt    = @["nim"]

# Dependencies

requires "nim >= 1.6.0"

task test, "run the test suite":
  exec "nim r tests/all.nim"
