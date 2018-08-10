.PHONY: all clean

all: presentation.html reveal.js

presentation.html: presentation.md
	#pandoc -t revealjs -s -o presentation.html presentation.md -V revealjs-url=https://lab.hakim.se/reveal-js -V theme=solarized
	pandoc -t revealjs -s -o presentation.html presentation.md -V theme=solarized
	sed -i 's/Reveal\.initialize({/Reveal\.initialize({\nkeyboard:{38:"prev",40:"next"},/' presentation.html

reveal.js:
	wget https://github.com/hakimel/reveal.js/archive/master.tar.gz
	tar xf master.tar.gz
	rm master.tar.gz
	mv reveal.js-master reveal.js

clean:
	rm -rf presentation.html
