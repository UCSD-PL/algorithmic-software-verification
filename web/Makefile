all:
	ghc --make hakyll
	./hakyll rebuild

clean:
	rm -rf *.hi *.o .*.swp .*.swo hakyll _site/ _cache/

update:
	cp css/syntax-rj.css _site/css/syntax.css
	cp -r slides _site/
	# cp -f lectures/*.lhs _site/lectures/
	# cp homeworks/*.lhs _site/homeworks/
	ssh rjhala@goto.ucsd.edu "chgrp -R cse230 /home/rjhala/public_html/classes/sp13/cse291/"
	scp -r _site/* rjhala@goto.ucsd.edu:/home/rjhala/public_html/classes/sp13/cse291/
	ssh rjhala@goto.ucsd.edu "chmod -R g+w /home/rjhala/public_html/classes/sp13/cse291/ && chmod -R ugo+r /home/rjhala/public_html/classes/sp13/cse291/"

