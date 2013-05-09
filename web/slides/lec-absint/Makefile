all:
	pdflatex lec-absint-table.tex
	pdfcrop lec-absint-table.pdf
	inkscape lec-absint-table-crop.pdf --export-plain-svg=lec-absint-table.svg
	pandoc --columns=80  -s --css text.css --highlight-style tango -w html5 --mathjax --slide-level=2 -o lec-absint.html lec-absint.markdown

clean:
	rm -f *.pdf *.html *.class *.png *.aux *.log *.svg

