# data-raw/create-logo.R
#
# Recreate the priogridR package logo deterministically.
#
# Development-only dependency for PNG rendering:
# install.packages("rsvg")
#
# Run this script from the package root:
# source("data-raw/create-logo.R")

output_dir <- file.path("man", "figures")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

svg_output <- file.path(output_dir, "logo.svg")
png_output <- file.path(output_dir, "logo.png")

# -------------------------------------------------------------------------
# Colour palette
# -------------------------------------------------------------------------

cream    <- "#F5EFE2"
teal     <- "#1F5651"
teal_mid <- "#2F6862"
teal_lit <- "#457A73"
rust     <- "#9A3E2D"
mustard  <- "#D6A84B"
charcoal <- "#171717"

# -------------------------------------------------------------------------
# SVG helpers
# -------------------------------------------------------------------------

svg_polygon <- function(points, fill) {
  sprintf('<polygon points="%s" fill="%s"/>', points, fill)
}

svg_circle <- function(cx, cy, radius, fill, stroke, stroke_width) {
  sprintf(
    paste0(
      '<circle cx="%s" cy="%s" r="%s" fill="%s" ',
      'stroke="%s" stroke-width="%s"/>'
    ),
    cx, cy, radius, fill, stroke, stroke_width
  )
}

# -------------------------------------------------------------------------
# Isometric tile field
# -------------------------------------------------------------------------

tiles <- data.frame(
  points = c(
    "335,535 410,492 485,535 410,578",
    "410,578 485,535 560,578 485,621",
    "485,621 560,578 635,621 560,664",
    "560,664 635,621 710,664 635,707",
    "260,578 335,535 410,578 335,621",
    "335,621 410,578 485,621 410,664",
    "410,664 485,621 560,664 485,707",
    "485,707 560,664 635,707 560,750",
    "185,621 260,578 335,621 260,664",
    "260,664 335,621 410,664 335,707",
    "335,707 410,664 485,707 410,750",
    "410,750 485,707 560,750 485,793",
    "110,664 185,621 260,664 185,707",
    "185,707 260,664 335,707 260,750",
    "260,750 335,707 410,750 335,793",
    "335,793 410,750 485,793 410,836"
  ),
  fill = c(
    teal_lit, teal_mid, teal_lit, teal_mid,
    teal_mid, teal_lit, mustard, teal_lit,
    teal_lit, teal_mid, teal_lit, teal_mid,
    teal_mid, teal_lit, teal_mid, teal_lit
  ),
  stringsAsFactors = FALSE
)

tile_svg <- vapply(
  seq_len(nrow(tiles)),
  function(i) svg_polygon(tiles$points[[i]], tiles$fill[[i]]),
  character(1)
)

# -------------------------------------------------------------------------
# Complete vector artwork
# -------------------------------------------------------------------------

svg <- c(
  '<svg xmlns="http://www.w3.org/2000/svg"',
  '     width="1000" height="1160" viewBox="0 0 1000 1160"',
  '     role="img" aria-labelledby="title desc">',
  '  <title id="title">priogridR package hex sticker</title>',
  paste0(
    '  <desc id="desc">A cream hexagon with a deep teal border, ',
    'the priogridR name, and an original isometric spatial tile ',
    'illustration with points and a path.</desc>'
  ),
  '',
  '  <!-- Transparent outside the sticker. -->',
  paste0(
    '  <path d="M500 30 L965 298 Q990 312 990 343 ',
    'L990 817 Q990 848 965 862 L500 1130 L35 862 ',
    'Q10 848 10 817 L10 343 Q10 312 35 298 L500 30 Z" ',
    'fill="', teal, '"/>'
  ),
  paste0(
    '  <path d="M500 76 L949 335 L949 825 L500 1084 ',
    'L51 825 L51 335 Z" fill="', cream, '"/>'
  ),
  '',
  '  <!-- Package name. -->',
  paste0(
    '  <text x="500" y="355" text-anchor="middle" ',
    'font-family="DejaVu Sans, Arial, sans-serif" ',
    'font-size="118" font-weight="700" letter-spacing="-6" ',
    'fill="', charcoal, '">priogrid',
    '<tspan fill="', rust, '">R</tspan></text>'
  ),
  '',
  '  <!-- Centre the complete grid assembly within the hexagon. -->',
  '  <g transform="translate(90 0)">',
  paste0(
    '  <g stroke="', cream, '" stroke-width="8" ',
    'stroke-linejoin="round">'
  ),
  paste0("    ", tile_svg),
  '  </g>',
  '',
  '  <!-- Transformation path across the grid. -->',
  paste0(
    '  <path d="M154 663 C240 605 305 675 374 646 ',
    'S500 600 568 662 S659 706 712 664" fill="none" ',
    'stroke="', rust, '" stroke-width="20" ',
    'stroke-linecap="round" stroke-linejoin="round"/>'
  ),
  paste0('  <g fill="', cream, '" stroke="', charcoal, '" stroke-width="9">'),
  paste0("    ", svg_circle(185, 646, 18, cream, charcoal, 9)),
  paste0("    ", svg_circle(374, 646, 18, cream, charcoal, 9)),
  paste0("    ", svg_circle(555, 652, 18, cream, charcoal, 9)),
  paste0("    ", svg_circle(688, 675, 18, cream, charcoal, 9)),
  '  </g>',
  '',
  '  <!-- Coordinate crosshair on the highlighted cell. -->',
  paste0(
    '  <g stroke="', charcoal, '" stroke-width="10" ',
    'stroke-linecap="round">'
  ),
  '    <path d="M464 664 L506 688"/>',
  '    <path d="M485 651 L485 701"/>',
  '  </g>',
  paste0('  <circle cx="485" cy="677" r="10" fill="', charcoal, '"/>'),
  '  </g>',
  '',
  '  <!-- Point, line, and polygon inputs feeding a common grid workflow. -->',
  paste0(
    '  <g transform="translate(235 890)" fill="none" ',
    'stroke="', charcoal, '" stroke-width="9" ',
    'stroke-linecap="round" stroke-linejoin="round">'
  ),
  paste0('    <circle cx="0" cy="0" r="15" fill="', mustard, '"/>'),
  paste0('    <path d="M75 16 C98 -18 126 -18 150 16" stroke="', rust, '"/>'),
  paste0(
    '    <polygon points="225,20 255,-26 292,17 254,37" ',
    'fill="', teal_lit, '"/>'
  ),
  '    <path d="M330 4 L395 4"/>',
  '    <path d="M377 -14 L397 4 L377 22"/>',
  paste0(
    '    <polygon points="449,4 477,-12 505,4 477,20" ',
    'fill="', mustard, '"/>'
  ),
  '  </g>',
  '',
  paste0(
    '  <text x="500" y="1060" text-anchor="start" ',
    'font-family="DejaVu Sans, Arial, sans-serif" ',
    'font-size="25" fill="', charcoal, '" ',
    'transform="rotate(-30 500 1060)">',
    'christianoswald.github.io/priogridR</text>'
  ),
  '</svg>'
)

writeLines(text = svg, con = svg_output, useBytes = TRUE)

# -------------------------------------------------------------------------
# Render the PNG used by pkgdown and the README
# -------------------------------------------------------------------------

if (!requireNamespace("rsvg", quietly = TRUE)) {
  stop(
    paste0(
      "The SVG was written to ", svg_output, ", but the development-only ",
      "package 'rsvg' is required to render logo.png. Install it with ",
      "install.packages(\"rsvg\")."
    ),
    call. = FALSE
  )
}

rsvg::rsvg_png(
  svg = svg_output,
  file = png_output,
  width = 1000,
  height = 1160
)

message("Wrote ", svg_output)
message("Wrote ", png_output)
