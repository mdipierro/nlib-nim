## Thin wrappers around `gnuplot` for the figures in the book. Each
## helper writes its data to `<filename>.dat` and then invokes
## `gnuplot` to render `<filename>` (the output format is determined by
## the file extension; PNG is the default in the templates below).

import std/[math, osproc, strutils]

proc writeXY(path: string, xs, ys: openArray[float]) =
  var f = open(path, fmWrite)
  for i in 0 ..< xs.len:
    f.writeLine xs[i].formatFloat(ffDecimal, 6) & " " &
                ys[i].formatFloat(ffDecimal, 6)
  f.close()

proc savePlot*(filename: string, xs, ys: openArray[float],
               title = "", xlab = "x", ylab = "y") =
  ## Line plot of `(xs, ys)`.
  let dataPath = filename & ".dat"
  writeXY(dataPath, xs, ys)
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set title '" & title & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "plot '" & dataPath & "' with lines\"")

proc saveHistogram*(filename: string, xs: openArray[float],
                    title = "", xlab = "x", ylab = "count",
                    bins = 20) =
  ## 1-D histogram of the values in `xs`.
  let dataPath = filename & ".dat"
  var f = open(dataPath, fmWrite)
  for x in xs: f.writeLine x.formatFloat(ffDecimal, 6)
  f.close()
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set title '" & title & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "set style fill solid; " &
                  "binwidth = " & $((xs.len.float).pow(0.5)) & "; " &
                  "bin(x, w) = w*floor(x/w); " &
                  "plot '" & dataPath &
                  "' using (bin($1, binwidth)):(1.0) " &
                  "smooth freq with boxes\"")

proc saveErrorbar*(filename: string,
                   xs, ys, dys: openArray[float],
                   title = "", xlab = "x", ylab = "y") =
  ## Plot `(xs, ys)` with vertical error bars `dys`.
  let dataPath = filename & ".dat"
  var f = open(dataPath, fmWrite)
  for i in 0 ..< xs.len:
    f.writeLine xs[i].formatFloat(ffDecimal, 6) & " " &
                ys[i].formatFloat(ffDecimal, 6) & " " &
                dys[i].formatFloat(ffDecimal, 6)
  f.close()
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set title '" & title & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "plot '" & dataPath &
                  "' using 1:2:3 with errorbars\"")

proc saveErrorbarSeries*[K](filename: string,
                            data: openArray[(K, seq[(float, float, float)])],
                            xlab = "x", ylab = "y") =
  ## Plot a family of error-bar series indexed by `K`. Each series has
  ## the form `(x, y, dy)` triples.
  let dataPath = filename & ".dat"
  var f = open(dataPath, fmWrite)
  for (label, series) in data:
    f.writeLine "# series " & $label
    for (x, y, dy) in series:
      f.writeLine x.formatFloat(ffDecimal, 6) & " " &
                  y.formatFloat(ffDecimal, 6) & " " &
                  dy.formatFloat(ffDecimal, 6)
    f.writeLine ""
    f.writeLine ""
  f.close()
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "plot for [i=0:*] '" & dataPath &
                  "' index i using 1:2:3 with errorbars\"")

proc saveHeatmap*(filename: string, grid: seq[seq[float]],
                  title = "", xlab = "x", ylab = "y") =
  ## Render a 2-D matrix as a heatmap.
  let dataPath = filename & ".dat"
  var f = open(dataPath, fmWrite)
  for row in grid:
    for v in row:
      f.write v.formatFloat(ffDecimal, 6) & " "
    f.writeLine ""
  f.close()
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set title '" & title & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "plot '" & dataPath &
                  "' matrix with image\"")
