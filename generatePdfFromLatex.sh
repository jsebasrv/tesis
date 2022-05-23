#!/bin/bash
# -*- ENCODING: UTF-8 -*-

pdflatex -pdf prueba.tex


gs -dQuiet -dSAFER -dNOPROMT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=jpeg -r300x300 -dNOPAUSE -dBATCH -sDEVICE=jpeg -dDEVICEHEIGHT=500 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=test%03d.jpg prueba.pdf -c quit
