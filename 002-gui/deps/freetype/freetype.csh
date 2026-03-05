#!/bin/csh
# Configure Freetype properties. Here this is used to set the default mode
# for font hinting. Other controllable properties are listed in the section
# 'Controlling FreeType Modules' in the reference's table of contents.
#
# Two hinting settings are available:

# This is the classic hinting mode used in Freetype 2.6.x:
#setenv FREETYPE_PROPERTIES "truetype:interpreter-version=35"

# This is the new default subpixel hinting mode used in Freetype 2.7.x. It is
# derived from the Infinality code base stripped to the bare minimum with all
# configurability removed in the name of speed and simplicity:
#setenv FREETYPE_PROPERTIES "truetype:interpreter-version=40"

