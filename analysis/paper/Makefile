# from the cbpaper/analysis/paper/ directory
# usage: make


all: totex rjournal

#.PHONY: html pdf clean

#clean:
#	rm *.aux *.blg *.out *.bbl *.log
# bibexport -o bhatnagar-turgeon-islam-hanley-saarela.bib RJwrapper.aux

totex:
	rm -rf bhatnagar-turgeon-islam-hanley-saarela_cache
	Rscript -e "rmarkdown::render(input = 'bhatnagar-turgeon-islam-hanley-saarela.Rmd', clean = TRUE)"

rjournal:
	zip bhatnagar-turgeon-islam-hanley-saarela-distill-Nov-2022.zip \
	bhatnagar-turgeon-islam-hanley-saarela.bib \
	bhatnagar-turgeon-islam-hanley-saarela.Rmd \
	bhatnagar-turgeon-islam-hanley-saarela.R \
	bhatnagar-turgeon-islam-hanley-saarela.pdf \
	bhatnagar-turgeon-islam-hanley-saarela.html \
	RJwrapper.tex \
	bhatnagar-turgeon-islam-hanley-saarela.tex \
	cs3FinalBrier-1.pdf \
	cs3lolliPlot-1.pdf \
	compAbsrisk-1.pdf \
	compPop-1.pdf \
	cs1hazard-1.pdf \
	erspc-cif-conf-1.pdf \
	interaction-ERSPC-1.pdf \
	plot-erspc-data-1.pdf \
	plot-erspc-data-1.png \
	cs3FinalBrier-1.png \
	cs3lolliPlot-1.png \
	compAbsrisk-1.png \
	compPop-1.png \
	cs1hazard-1.png \
	erspc-cif-conf-1.png \
	interaction-ERSPC-1.png \
	plot-erspc-data-1.png 
	

