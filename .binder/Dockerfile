FROM rocker/binder:3.6.0
LABEL maintainer='Sahir Bhatnagar'

## Copies your repo files into the Docker Container
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}

## Become normal user again
USER ${NB_USER}


## RUN wget https://github.com/benmarwick/replicationteachingarchaeology/raw/master/DESCRIPTION && R -e "options(repos = list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/2019-06-20/')); devtools::install_deps()"

## Run an install.R script, if it exists.
RUN if [ -f DESCRIPTION ]; then R --quiet -e "devtools::install(dep=TRUE)"; fi
