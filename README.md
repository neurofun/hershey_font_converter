Adapted from Kamal Mostafa's hershey-fonts package.  
<https://github.com/kamalmostafa/hershey-fonts>
#### hershey_font_converter.pde

Processing sketch to convert hershey font files(.jhf) to a coordinate array that describes each character in a way suitable for a C program.
The characters range from space (32) to (127), that is, 96 characters.
For each character the first item is the number of vertices needed to describe the character.
The second item is the horizontal spacing of the character, the distance from the bottom left to the bottom right.
The subsequent items are vertex pairs. A vertex of (-1,-1) indicates a pen up operation.  

#### hershey-fonts_converted

The converted font files.

#### hershey-fonts_png

Preview images of the fonts.

#### hershey-fonts

The Hershey fonts are a collection of vector fonts developed circa 1967
by Dr. A. V. Hershey.  Included are Latin, Greek, Cyrilic, Japanese, and
various symbol glyph sets encoded as .jhf format Hershey font files.
The .jhf font files were converted from Hershey's original NTIS format
files by James Hurt (see hershey-fonts.notes).
<http://en.wikipedia.org/wiki/Hershey_font>  
<http://paulbourke.net/dataformats/hershey/>

 **License**


The Hershey font glyph data is covered by a permissive use and redistribution
license.  This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

![astrology](/hershey-fonts_png/astrology.png)
