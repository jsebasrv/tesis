use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";

#my $command = "gs -dQuiet -dSAFER -dNOPROMT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=jpeg -r300x300 -dNOPAUSE -dBATCH -sDEVICE=jpeg -dDEVICEHEIGHT=500 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=output%03d.jpg Silabo.pdf -c quit";
#print `$command`;
#print "";

=pod
https://foroayuda.es/como-instalar-completamente-latex-en-fedora/
https://fedoraproject.org/wiki/Features/TeXLive
https://tex.stackexchange.com/questions/15516/how-to-write-japanese-with-latex

sudo dnf install texlive texlive-scheme* texlive-collection*

Ghostscript

gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -dDEVICEHEIGHT=500 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=output%d.jpg Silabo.pdf -c quit

=cut

#1 Generate .tex files from the raw input Japanese text

#2 Generate pdfs
my $command = "pdflatex -pdf test.tex";
   print `$command`;

#3 Generate high quality jpeg images out of .pdfs
$command = "gs -dQuiet -dSAFER -dNOPROMT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=jpeg -r300x300 -dNOPAUSE -dBATCH -sDEVICE=jpeg -dDEVICEHEIGHT=500 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=test%03d.jpg test.pdf -c quit";
print `$command`;

#4 OCR images back into plain Japanese text using ABBY.

#5 Align reference plain Japanese text with OCRed plain Japanese text.

#6 Count the amount and proportion of OCR recognition errors. Adjust the conversion parameters to have maximun of about 5% of character errors. Font sizes and font styles may vary.

