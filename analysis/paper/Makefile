# from the cbpaper/analysis/paper/ directory
# usage: make


all: totex rjournal

#.PHONY: html pdf clean

#clean:
#	rm *.aux *.blg *.out *.bbl *.log

totex:
	rm -rf bhatnagar-turgeon-islam-hanley-saarela_cache
	Rscript -e "rmarkdown::render(input = 'bhatnagar-turgeon-islam-hanley-saarela.Rmd', clean = TRUE)"

rjournal:
	bibexport -o bhatnagar-turgeon-islam-hanley-saarela.bib RJwrapper.aux
	zip bhatnagar-turgeon-islam-hanley-saarela.zip \
	bhatnagar-turgeon-islam-hanley-saarela.bib \
	bhatnagar-turgeon-islam-hanley-saarela.Rmd \
	bhatnagar-turgeon-islam-hanley-saarela.R \
	RJwrapper.tex \
	RJwrapper.pdf \
	bhatnagar-turgeon-islam-hanley-saarela.tex \
	#cover-letter.pdf \
	casebase_response_to_reviewers.pdf \
	bmtcrr-risk-1.pdf \
	coefplots-1.pdf \
	compPop-1.pdf \
	cs1hazard-1.pdf \
	erspc-cif-conf-1.pdf \
	interaction-ERSPC-1.pdf \
	plot-erspc-data-1.pdf \
	riskregressionBrier-1.pdf

