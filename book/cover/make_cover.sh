#!/usr/bin/env bash
#
# Build KDP cover assets for "Numerical Algorithms in Nim".
#
#   Usage:  bash make_cover.sh <PAGE_COUNT>
#   e.g.    bash make_cover.sh 312
#
# Produces, in this directory:
#   front.jpg   -> Kindle eBook cover   (1600 x 2560 px, sRGB JPEG)  <-- upload to KDP eBook
#   wrap.pdf    -> Paperback full wrap  (6x9 trim, 0.125" bleed)     <-- upload to KDP paperback
#
# Requirements: rsvg-convert + ImageMagick (`magick`/`convert`).
# (These hang inside the Claude Code sandbox due to a fontconfig issue,
#  but run fine in a normal terminal. If fonts look wrong, run `fc-cache -f` first.)
#
set -euo pipefail
cd "$(dirname "$0")"

PAGES="${1:-}"
if [[ -z "$PAGES" ]]; then
  echo "ERROR: page count required.  Usage: bash make_cover.sh <PAGE_COUNT>" >&2
  exit 1
fi

# ---- KDP geometry (6 x 9 trim, white interior paper) -----------------------
DPI=300
TRIM_W=6 ; TRIM_H=9 ; BLEED=0.125
PAPER=0.0025                     # inches/page, white paper B&W interior
                                 # (use 0.002347 for full-color interior)

read FULL_W FULL_H SPINE_PX BACK_R SPINE_R BLEED_PX SAFE <<EOF
$(awk -v p="$PAGES" -v dpi="$DPI" -v tw="$TRIM_W" -v th="$TRIM_H" \
      -v bl="$BLEED" -v pt="$PAPER" 'BEGIN{
  spine = p*pt;
  fw = (tw*2 + spine + bl*2)*dpi;
  fh = (th + bl*2)*dpi;
  spx = spine*dpi;
  blpx = bl*dpi;
  backr = blpx + tw*dpi;          # right edge of back panel / left of spine
  spiner = backr + spx;           # right edge of spine / left of front panel
  safe = 0.25*dpi;                # safe margin from trim
  printf "%.0f %.0f %.0f %.0f %.0f %.0f %.0f", fw, fh, spx, backr, spiner, blpx, safe;
}')
EOF

echo ">> pages=$PAGES  spine=${SPINE_PX}px  full=${FULL_W}x${FULL_H}px"

# Front panel left edge + center (in full-wrap coordinates)
FRONT_L=$SPINE_R
FC=$(awk -v b="$FRONT_L" 'BEGIN{printf "%.0f", b+900}')   # center of 6" front trim
CROWN_X=$(awk -v c="$FC" 'BEGIN{printf "%.0f", c-309}')   # crown box (600*1.03)/2
BIO_X=$((BLEED_PX + SAFE))                                 # back-panel left text edge
BIO_W=1500                                                 # justified bio column width (px) ~50% wider
YEL="#FFE953" ; BG="#141414" ; FG="#f2f2f2"

# ============================================================================
#  1) eBook front cover  (standalone 1600 x 2560)
# ============================================================================
rsvg-convert -w 1600 -h 2560 front.svg -o front.png
magick front.png -colorspace sRGB -quality 92 front.jpg
echo ">> wrote front.jpg (Kindle eBook cover)"

# ============================================================================
#  2) Paperback full wrap  (back | spine | front)
# ============================================================================
# helper: front-panel x given an inset from the front trim's left edge
fx(){ awk -v b="$FRONT_L" -v s="$1" 'BEGIN{printf "%.0f", b+s}'; }
bx(){ awk -v s="$1" 'BEGIN{printf "%.0f", s}'; }     # back-panel x = absolute

cat > wrap.svg <<SVG
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${FULL_W}" height="${FULL_H}"
     viewBox="0 0 ${FULL_W} ${FULL_H}" font-family="Liberation Sans, DejaVu Sans, sans-serif">
  <rect x="0" y="0" width="${FULL_W}" height="${FULL_H}" fill="${BG}"/>

  <!-- ============ FRONT PANEL (right) ============ -->
  <!-- Nim-style crown as a 2D plot -->
  <g transform="translate(${CROWN_X},$((SAFE+40)) ) scale(1.03)">
    <g stroke="#2c2c2c" stroke-width="2">
      <line x1="40" y1="20" x2="40" y2="420"/>   <line x1="92" y1="20" x2="92" y2="420"/>
      <line x1="144" y1="20" x2="144" y2="420"/> <line x1="196" y1="20" x2="196" y2="420"/>
      <line x1="248" y1="20" x2="248" y2="420"/> <line x1="300" y1="20" x2="300" y2="420"/>
      <line x1="352" y1="20" x2="352" y2="420"/> <line x1="404" y1="20" x2="404" y2="420"/>
      <line x1="456" y1="20" x2="456" y2="420"/> <line x1="508" y1="20" x2="508" y2="420"/>
      <line x1="560" y1="20" x2="560" y2="420"/>
      <line x1="40" y1="60" x2="560" y2="60"/>   <line x1="40" y1="110" x2="560" y2="110"/>
      <line x1="40" y1="160" x2="560" y2="160"/> <line x1="40" y1="210" x2="560" y2="210"/>
      <line x1="40" y1="260" x2="560" y2="260"/> <line x1="40" y1="310" x2="560" y2="310"/>
      <line x1="40" y1="360" x2="560" y2="360"/> <line x1="40" y1="410" x2="560" y2="410"/>
    </g>
    <g stroke="#5a5a5a" stroke-width="3">
      <line x1="40" y1="410" x2="560" y2="410"/> <line x1="40" y1="410" x2="40" y2="20"/>
    </g>
    <polygon points="40,410 150,110 225,300 300,55 375,300 450,110 560,410" fill="${YEL}" fill-opacity="0.12"/>
    <polyline points="40,410 150,110 225,300 300,55 375,300 450,110 560,410 40,410"
              fill="none" stroke="${YEL}" stroke-width="9" stroke-linejoin="round" stroke-linecap="round"/>
    <g fill="${BG}" stroke="${YEL}" stroke-width="6">
      <circle cx="150" cy="110" r="13"/> <circle cx="225" cy="300" r="13"/>
      <circle cx="300" cy="55" r="13"/>  <circle cx="375" cy="300" r="13"/>
      <circle cx="450" cy="110" r="13"/>
    </g>
  </g>
  <g font-weight="bold" fill="${YEL}" text-anchor="middle">
    <text x="${FC}" y="$(bx $((SAFE+730)))" font-size="185" letter-spacing="-4">NUMERICAL</text>
    <text x="${FC}" y="$(bx $((SAFE+925)))" font-size="185" letter-spacing="-4">ALGORITHMS</text>
    <text x="${FC}" y="$(bx $((SAFE+1120)))" font-size="185" letter-spacing="-4">IN NIM</text>
  </g>
  <text x="${FC}" y="$(bx $((SAFE+1260)))" text-anchor="middle" font-size="62" fill="${FG}">Applications in Physics, Biology, Finance</text>
  <rect x="$((FC-150))" y="$(bx $((SAFE+1310)))" width="300" height="9" fill="${YEL}"/>
  <text x="${FC}" y="$(bx $((FULL_H-SAFE-150)))" text-anchor="middle" font-weight="bold" font-size="100" fill="#ffffff">Massimo Di Pierro</text>
  <text x="${FC}" y="$(bx $((FULL_H-SAFE-70)))"  text-anchor="middle" font-size="50" fill="${YEL}" letter-spacing="2">EXPERTS4SOLUTIONS</text>

  <!-- ============ SPINE ============ -->
  <g transform="translate($((BACK_R + SPINE_PX/2)), $((FULL_H/2))) rotate(90)"
     text-anchor="middle">
    <text x="0" y="20" font-size="56">
      <tspan font-weight="bold" fill="${YEL}">NUMERICAL ALGORITHMS IN NIM</tspan><tspan dx="44" fill="${FG}">Massimo Di Pierro</tspan>
    </text>
  </g>

  <!-- ============ BACK PANEL (left) ============ -->
  <rect x="$((BLEED_PX + SAFE))" y="$((SAFE))" width="280" height="16" fill="${YEL}"/>
  <text x="$((BLEED_PX + SAFE))" y="$((SAFE+120))" font-weight="bold" font-size="62" fill="${YEL}">About the Author</text>
  <!-- bio: left-aligned, ~50% wider column -->
  <g font-size="40" fill="${FG}">
    <text x="${BIO_X}" y="$((SAFE+230))">Massimo Di Pierro is a physicist, computer scientist, software</text>
    <text x="${BIO_X}" y="$((SAFE+286))">architect, and educator with deep experience in scientific computing,</text>
    <text x="${BIO_X}" y="$((SAFE+342))">simulation, web technologies, and financial systems. He has held</text>
    <text x="${BIO_X}" y="$((SAFE+398))">academic and industry leadership roles, including serving as a tenured</text>
    <text x="${BIO_X}" y="$((SAFE+454))">Professor of Computer Science at DePaul University and leading</text>
    <text x="${BIO_X}" y="$((SAFE+510))">the simulation applications team at SpaceX.</text>
  </g>
  <text x="$((BLEED_PX + SAFE))" y="$((FULL_H-SAFE-70))" font-size="44" fill="${YEL}" letter-spacing="2">EXPERTS4SOLUTIONS</text>
</svg>
SVG

# Render wrap to a 300-DPI raster, then wrap as a single-page PDF at 6x9+bleed.
rsvg-convert -w "$FULL_W" -h "$FULL_H" wrap.svg -o wrap.png
magick wrap.png -colorspace sRGB -units PixelsPerInch -density $DPI wrap.pdf
echo ">> wrote wrap.pdf (paperback full wrap, ${PAGES} pages)"
echo "Done."
