.PHONY: all clean

all: presentation.html

presentation.html: presentation.md
	pandoc -t revealjs -s -o presentation.html presentation.md -V revealjs-url=https://lab.hakim.se/reveal-js -V theme=solarized

clean:
	rm -rf presentation.html
