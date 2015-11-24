alles:
	echo $(VERSION).$(COMMITS)
all: figure.pdf figure.ps
VERSION := $(shell git describe --tags)
COMMITS := $(shell git rev-list --count $(VERSION)..HEAD)
DIR     := $(shell basename $$PWD)

authordep = rog.cls sample_article.bib sample_article.tex
editordep = rog.cls sample_article.bib sample_article.tex master.tex

rog-latex-guide-for-author-$(VERSION).tar.gz: $(authordep)
	echo $(VERSION) $(DIR)
	tar czvf $@ \
    -C ../   \
    $(addprefix $(DIR)/,$(authordep))

clean:
	rm *.aux

figure.pdf: figure.tex
	pdflatex $<
figure.ps: figure.tex
	latex $<
	dvips $(<:.tex=.dvi)
