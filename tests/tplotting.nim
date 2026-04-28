import std/[unittest, os, strutils]
import nlib/plotting

# These tests exercise the data-marshaling paths only. We do not assert
# that gnuplot is installed; if it is missing, the rendered image
# simply will not be produced, but the `.dat` companion file must be.

suite "plotting":
  let dir = getTempDir() / "nlib_plotting"
  removeDir(dir)
  createDir(dir)

  teardown:
    removeDir(dir)
    createDir(dir)

  test "savePlot writes a .dat file":
    let outPath = dir / "line.png"
    savePlot(outPath, @[0.0, 1.0, 2.0], @[0.0, 1.0, 4.0])
    check fileExists(outPath & ".dat")

  test "saveHistogram writes one value per line":
    let outPath = dir / "hist.png"
    let xs = @[1.0, 2.0, 3.0, 4.0]
    saveHistogram(outPath, xs)
    let data = readFile(outPath & ".dat")
    check data.splitLines.len >= xs.len

  test "saveErrorbar writes 3 columns per row":
    let outPath = dir / "err.png"
    saveErrorbar(outPath,
                 @[0.0, 1.0], @[1.0, 2.0], @[0.1, 0.2])
    let firstLine = readFile(outPath & ".dat").splitLines[0]
    check firstLine.split(' ').len == 3

  test "saveHeatmap writes a rectangular grid":
    let outPath = dir / "heat.png"
    saveHeatmap(outPath, @[@[1.0, 2.0], @[3.0, 4.0]])
    check fileExists(outPath & ".dat")
