all:
	pdflatex lec-absint-table-conc.tex
	pdflatex lec-absint-table-abs.tex
	convert -verbose -density 130 lec-absint-table-conc.pdf -trim -quality 100 lec-absint-table-conc.png
	convert -verbose -density 180 lec-absint-table-abs.pdf -trim -quality 100 lec-absint-table-abs.png
	pandoc --columns=80  -s --css github.css --highlight-style tango -w html5 --mathjax --slide-level=2 -o lec-absint.html lec-absint.markdown

clean:
	rm -f *.pdf *.html *.class *.png *.aux *.log *.svg

