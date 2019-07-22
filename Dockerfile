# get the base image, the rocker/verse has R, RStudio and pandoc
FROM rocker/verse:3.6.0

# required
MAINTAINER Your Name <sahir.bhatnagar@gmail.com>

COPY . /cbpaper

# go into the repo directory
RUN . /etc/environment \

  # Install linux depedendencies here
  # e.g. need this for ggforce::geom_sina
  # && sudo apt-get update \
  # && sudo apt-get install libudunits2-dev -y \
  && R -e "options(error = function() traceback()) ; system("echo $NAMES") ; devtools::install_github(paste0(Sys.getenv(c("NAMES")), '/casebase'))" \

  # build this compendium package
  && R -e "devtools::install('/cbpaper', dep=TRUE)" \

 # render the manuscript into a docx, you'll need to edit this if you've
 # customised the location and name of your main Rmd file
  && R -e "rmarkdown::render('/cbpaper/analysis/paper/paper.Rmd')"
