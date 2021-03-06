VERSION := $(shell git describe --tags --abbrev=0)
COMMITS := $(shell git rev-list --count $(VERSION)..HEAD)
DIR     := $(shell basename $$PWD)
ARCHDIR := archive

all: package rgg_editor.pdf changes.txt VERSION.txt
	@tput setaf 2 ; echo rgg.cls $(VERSION).$(COMMITS) ; tput sgr0

authordep :=             \
	rgg.cls                \
	rgg_sample_article.bib \
	rgg_sample_article.tex \
	rgg_sample_article.pdf \
	figure.pdf

package: rgg-latex-guide-for-author-latest.tar.gz

rgg-latex-guide-for-author-latest.tar.gz: $(ARCHDIR)/rgg-latex-guide-for-author-$(VERSION).$(COMMITS).tar.gz
	ln -f $< $@

$(ARCHDIR):
	mkdir -p $@

$(ARCHDIR)/rgg-latex-guide-for-author-$(VERSION).$(COMMITS).tar.gz: $(authordep) VERSION.txt changes.txt $(ARCHDIR)
	[[ -z $$(git status --porcelain) ]] && tar -czf $@  $(authordep) || { tput setaf 1 ; echo working directory not clean, refusing creating archive ; tput sgr0 ; false ; }

clean:
	git clean -fx

figure.pdf: figure.tex
	pdflatex $<
figure.ps: figure.tex
	latex $<
	dvips $(<v:.tex=.dvi)

%.pdf: %.tex figure.pdf rgg.cls
	pdflatex $(<:.tex=) > /dev/null
	bibtex $(<:.tex=) > /dev/null
	pdflatex $(<:.tex=) > /dev/null
	pdflatex $(<:.tex=) > /dev/null

test:
	rm -rf tmp
	mkdir tmp
	cd tmp                                                                       \
		&& wget www.grat.gik.pw.edu.pl/rgg/rgg-latex-guide-for-author-latest.tar.gz \
		&& tar zxvf rgg-latex-guide-for-author-latest.tar.gz                        \
		&& cd rgg                                                                   \
		&& pdflatex rgg_sample_article                                              \
		&& bibtex rgg_sample_article                                                \
		&& pdflatex rgg_sample_article                                              \
		&& pdflatex rgg_sample_article                                              \
		&& wget www.grat.gik.pw.edu.pl/rgg/rgg_editor.tex                           \
		&& pdflatex rgg_editor                                                      \
		&& bibtex rgg_editor                                                         \
		&& pdflatex rgg_editor                                                      \
		&& pdflatex rgg_editor                                                      \
		&& zathura rgg_sample_article.pdf rgg_editor.pdf

VERSION.txt: $(authordep) Makefile
	echo This is version $$(git describe --tags) [$$(git show -s --format=%ci HEAD)] of LaTeX class for *Reports on Geodesy and Geoinformatics* journal -- rgg.cls > $@

changes.txt: rgg.cls
	git log -p --no-color --no-use-mailmap -- rgg.cls > $@

cleanarchive:
	echo $(VERSION)
	rm $(ARCHDIR)/*v*.*.[1-9]*.tar.gz
	make all
