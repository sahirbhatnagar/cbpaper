# cbpaper
Source code for Casebase paper

for template, use 

```R 
devtools::install_github("rstudio/rticles")
```

# Outline

1. Introduction
2. Theory
3. Implementation Details (Population time plots, Data analysis)
4. Case study 1 ERPSC (Single Event)
5. Case study 2 Bone Marrow Transplant (Competing risk)
6. Variable Selection (see https://cran.r-project.org/web/packages/TCGA2STAT/vignettes/TCGA2STAT.html for HD survival Data) 
7. Discussion


# To-DO (July 15)

1) Max: implement multinomial glmnet
2) Jesse: tests single and competing risk variable selection on TCGA. Look at variable selection litterature for competing risks. Find data
3) Sahir: Implementation details (population time plots)
4) Sahir: Review existing literature. What exists in terms of package. Look at Hanley and Miettinen. CRAN task view. 


| Package | on CRAN     |  documentation |  Published | Description | Function call |
| :---    |  :---:      |    :---:        |    :---:   |  :---     |  :---:        |
| [flexsurv](https://cran.r-project.org/package=flexsurv)   | :heavy_check_mark:    | [Vignette](https://cran.r-project.org/web/packages/flexsurv/vignettes/flexsurv.pdf)    | [Jackson, C. JSS 2016](https://www.jstatsoft.org/article/view/v070i08) | Fully-parametric.  Any parametric time-to-event distribution may be fitted if the user supplies a probability density or hazard function, and ideally also their cumulative versions. Standard survival distributions are built in, including the three and four-parameter generalized gamma and Fdistributions. Any parameter of any distribution can be modelled as a linear or log-linear function of covariates. The package also includes the spline model of Royston and Parmar (2002), in which both baseline survival and covariate effects can be arbitrarily flexible parametric functions of time. See Table 1 for full list of distributions.  |  `flexsurvreg(Surv(recyrs, censrec) ~ group, data = bc, dist = "gengamma")`   `flexsurvspline(Surv(recyrs, censrec) ~ group, data = bc, k = 1, scale = "odds")`  |
| git diff     | git diff       | git diff      | dd | 44 | dd |
