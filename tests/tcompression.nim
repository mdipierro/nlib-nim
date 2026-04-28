import std/[unittest, tables]
import nlib/compression

suite "compression":
  test "Huffman round-trip":
    let input = "this is a nice day"
    let (keys, encoded) = encodeHuffman(input)
    check encoded.len > 0
    check decodeHuffman(keys, encoded) == input

  test "Huffman compresses below 8 bits per character":
    let input = "AAAAAAAAABCD"
    let (_, encoded) = encodeHuffman(input)
    check encoded.len < 8 * input.len

  test "Huffman empty string":
    let (_, encoded) = encodeHuffman("")
    check encoded == ""

  test "Huffman single-symbol input":
    let (keys, encoded) = encodeHuffman("aaaa")
    check encoded.len == 4
    check decodeHuffman(keys, encoded) == "aaaa"
