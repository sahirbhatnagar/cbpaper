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
