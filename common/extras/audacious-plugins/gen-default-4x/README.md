Generators for the 4x "Default" skin in ../Default4x/.

Not used at build time; only needed to regenerate the PNGs (e.g. after an
upstream change to the 1x Default skin).

Requirements: python3 with Pillow, numpy, cairosvg; DejaVu Sans Bold.

Usage:
  export SKIN_SRC=/path/to/audacious-plugins/src/skins-data/Skins/Default
  export SKIN_OUT=$(pwd)/out          # optional, defaults to ./Default
  for g in gen_*.py; do python3 "$g"; done
  cp out/*.png ../Default4x/

skin.hints in ../Default4x/ is the upstream file plus `skinPixelRatio=4`
(the hint added by ../hidpi-skin.patch).
