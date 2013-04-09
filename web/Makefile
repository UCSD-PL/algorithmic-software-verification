all:
	ghc --make hakyll
	./hakyll rebuild

clean:
	rm -rf *.hi *.o .*.swp .*.swo hakyll _site/ _cache/

update:
	cp css/syntax-rj.css _site/css/syntax.css
	cp lectures/*.lhs _site/lectures/
	cp homeworks/*.lhs _site/homeworks/
	ssh rjhala@csefast.ucsd.edu "chgrp -R cse230 /net/cs/htdocs/classes/wi11/cse230/"
	scp -r _site/* rjhala@csefast.ucsd.edu:/net/cs/htdocs/classes/wi11/cse230/
	ssh rjhala@csefast.ucsd.edu "chmod -R g+w /net/cs/htdocs/classes/wi11/cse230/ && chmod -R ugo+r /net/cs/htdocs/classes/wi11/cse230/"

pmr-update: 
	cp css/syntax-rj.css _site/css/syntax.css
	cp lectures/*.lhs _site/lectures/
	cp homeworks/*.lhs _site/homeworks/
	scp -r _site/* prondon@csegrad.ucsd.edu:/cse/htdocs/classes/wi11/cse230/
	ssh prondon@csegrad.ucsd.edu "chmod -R ugo+r /cse/htdocs/classes/wi11/cse230/"
	ssh prondon@csegrad.ucsd.edu "chgrp -R cse230 /cse/htdocs/classes/wi11/cse230/"
