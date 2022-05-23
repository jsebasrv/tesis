#!/bin/bash

ngram-count -text corpus.txt -write-vocab corpus.vocab
ngram-count -text corpus.txt -order 3  -write corpus.count
ngram-count -read corpus.count -order 3 -lm corpus.lm -addsmooth 1
