#!/bin/bash
# -*- ENCODING: UTF-8 -*-

echo "Se est[a creado el pdf"
pdflatex -output-directory='./pdf_created_files/' ./LaTex-created_files/Test_data/archivo_100_out.tex

 echo "Se est[a creado la imagen"
gs -dQuiet -dSAFER -dNOPROMT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=jpeg -r300x300 -dNOPAUSE -dBATCH -sDEVICE=jpeg -dDEVICEHEIGHT=500 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=./images/test%03d.jpg ./pdf_created_files/archivo_100_out.pdf -c quit
