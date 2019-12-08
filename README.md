
<!-- README.md is generated from README.Rmd. Please edit that file -->
cbpaper
=======

[![Binder](http://mybinder.org/badge.svg)](http://beta.mybinder.org/v2/gh/sahirbhatnagar/cbpaper/master?urlpath=rstudio)
[![Travis-CI Build Status](https://travis-ci.org/sahirbhatnagar/cbpaper.svg?branch=master)](https://travis-ci.org/sahirbhatnagar/cbpaper)

Source code for Casebase paper

for template, use

``` r
devtools::install_github("rstudio/rticles")
```

Outline
=======

1.  Introduction
2.  Theory
3.  Implementation Details (Population time plots, Data analysis)
4.  Case study 1 ERPSC (Single Event)
5.  Case study 2 Bone Marrow Transplant (Competing risk)
6.  Variable Selection (see <https://cran.r-project.org/web/packages/TCGA2STAT/vignettes/TCGA2STAT.html> for HD survival Data)
7.  Discussion

To-DO (July 15)
===============

1.  Max: implement multinomial glmnet
2.  Jesse: tests single and competing risk variable selection on TCGA. Look at variable selection litterature for competing risks. Find data
3.  Sahir: Implementation details (population time plots)
4.  Sahir: Review existing literature. What exists in terms of package. Look at Hanley and Miettinen. CRAN task view.

To-DO (July 22)
===============

1.  Max: theory text
2.  Jesse: tests single event variable selection on TCGA. Look at variable selection litterature for single. Plot KM curve with casebase+glmnet, and glmnet+cox
3.  Sahir: Implementation details (population time plots), check issue.
4.  Sahir: Review existing literature. What exists in terms of package. Look at Hanley and Miettinen. CRAN task view.

<table style="width:47%;">
<colgroup>
<col width="6%" />
<col width="8%" />
<col width="8%" />
<col width="8%" />
<col width="6%" />
<col width="8%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Package</th>
<th align="center">on CRAN</th>
<th align="center">documentation</th>
<th align="center">Published</th>
<th align="left">Description</th>
<th align="center">Function call</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><a href="https://cran.r-project.org/package=flexsurv">flexsurv</a></td>
<td align="center">:heavy_check_mark:</td>
<td align="center"><a href="https://cran.r-project.org/web/packages/flexsurv/vignettes/flexsurv.pdf">Vignette</a></td>
<td align="center"><a href="https://www.jstatsoft.org/article/view/v070i08">Jackson, C. JSS 2016</a></td>
<td align="left">Fully-parametric. Any parametric time-to-event distribution may be fitted if the user supplies a probability density or hazard function, and ideally also their cumulative versions. Standard survival distributions are built in, including the three and four-parameter generalized gamma and Fdistributions. Any parameter of any distribution can be modelled as a linear or log-linear function of covariates. The package also includes the spline model of Royston and Parmar (2002), in which both baseline survival and covariate effects can be arbitrarily flexible parametric functions of time. See Table 1 for full list of distributions.</td>
<td align="center"><code>flexsurvreg(Surv(recyrs, censrec) ~ group, data = bc, dist = &quot;gengamma&quot;)</code> <code>flexsurvspline(Surv(recyrs, censrec) ~ group, data = bc, k = 1, scale = &quot;odds&quot;)</code></td>
</tr>
<tr class="even">
<td align="left">git diff</td>
<td align="center">git diff</td>
<td align="center">git diff</td>
<td align="center">dd</td>
<td align="left">44</td>
<td align="center">dd</td>
</tr>
</tbody>
</table>

Casebase paper
==============

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh///master?urlpath=rstudio)

This repository contains the data and code for our paper:

> Authors, (YYYY). *Title of your paper goes here*. Name of journal/book <https://doi.org/xxx/xxx>

Our pre-print is online here:

> Authors, (YYYY). *Title of your paper goes here*. Name of journal/book, Accessed 03 Aug 2019. Online at <https://doi.org/xxx/xxx>

### How to cite

Please cite this compendium as:

> Authors, (2019). *Compendium of R code and data for Title of your paper goes here*. Accessed 03 Aug 2019. Online at <https://doi.org/xxx/xxx>

### How to download or install

You can download the compendium as a zip from from this URL: </archive/master.zip>

Or you can install this compendium as an R package, pap, from GitHub with:

``` r
# install.packages("devtools")
remotes::install_github("/")
```

### Licenses

**Text and figures :** [CC-BY-4.0](http://creativecommons.org/licenses/by/4.0/)

**Code :** See the [DESCRIPTION](DESCRIPTION) file

**Data :** [CC-0](http://creativecommons.org/publicdomain/zero/1.0/) attribution requested in reuse

### Contributions

We welcome contributions from everyone. Before you get started, please see our [contributor guidelines](CONTRIBUTING.md). Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
