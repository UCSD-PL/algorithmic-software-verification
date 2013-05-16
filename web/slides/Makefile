#PANDOC=~/.cabal/bin/pandoc --columns=80  -s --mathjax --slide-level=2
PANDOC=pandoc --columns=80  -s --mathjax --slide-level=2
SLIDY=$(PANDOC) -t slidy
DZSLIDES=$(PANDOC) --highlight-style tango --css=slides.css -w dzslides
HANDOUT=$(PANDOC) --highlight-style tango --css=text.css -w html5

WEBTEX=$(PANDOC) -s --webtex -i -t slidy
BEAMER=pandoc -t beamer

####################################################################

SRCS	= lec1-scala-intro.markdown
OBJS	= ${SRCS:.markdown=.html}

# clear out all suffixes
.SUFFIXES:
# list only those we use
.SUFFIXES: .html .markdown

slides:
	for file in *.markdown; do $(BEAMER) $$file -o $$file.pdf; done
#	for file in *.markdown; do $(WEBTEX) $$file -o $$file.html; done
#	for file in *.markdown; do $(DZSLIDES) $$file -o $$file.slides.html; done
#   for file in *.markdown; do $(HANDOUT) $$file -o $$file.handout.html; done
#	for file in *.markdown; do $(PANDOC) $$file -o $$file.pdf; done

upload: slides
	scp -r *.markdown.pdf rjhala@goto.ucsd.edu:/home/rjhala/public_html/classes/sp13/cse291/slides/

.markdown.html:
	$(DZSLIDES) $< -o $@

clean:
	rm -f *.pdf *.html *.class
