# from the cbpaper/analysis/paper/rjournal directory
# usage: make filename="001-introduction" path="001-introduction"


all: totex rjournal

#.PHONY: html pdf clean

#clean:
#	rm *.aux *.blg *.out *.bbl *.log

totex:
	Rscript -e "rmarkdown::render(input = 'bhatnagar-turgeon-islam-hanley-saarela.Rmd', clean = FALSE)"
	#pdfunite $(OUTPUT)_handout.pdf PoissonAndExtraPoissonVariation_handout.pdf $(OUTPUT)_handout_JH.pdf

rjournal:
	bibexport -o bhatnagar-turgeon-islam-hanley-saarela.bib RJwrapper.aux
	mv ../figures/* .
	zip bhatnagar-turgeon-islam-hanley-saarela.zip \
	bhatnagar-turgeon-islam-hanley-saarela.bib \
	bhatnagar-turgeon-islam-hanley-saarela.Rmd \
	bhatnagar-turgeon-islam-hanley-saarela.R \
	RJwrapper.tex \
	RJwrapper.pdf \
	bhatnagar-turgeon-islam-hanley-saarela.tex \
	cover-letter.pdf \
	bmtcrr-risk-1.pdf \
	coefplots-1.pdf \
	compPop-1.pdf \
	erspc-cox-cif-1.pdf \
	interaction-ERSPC-1.pdf \
	plot-stratified-erspc-data-1.pdf \
	riskregressionBrier-1.pdf


	#pdfunite $(OUTPUT)_slides.pdf PoissonAndExtraPoissonVariation.pdf $(OUTPUT)_slides_JH.pdf
