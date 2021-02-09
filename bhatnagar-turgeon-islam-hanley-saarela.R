## ----setup, echo=FALSE, message=FALSE, warning=FALSE-----------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = FALSE,
  cache = TRUE, 
  fig.pos = 'ht',
  comment = "#>",
  fig.path = "../figures/",
  out.width = "\\textwidth",
   out.extra = "keepaspectratio=true"
)

options(kableExtra.latex.load_packages = FALSE)
library(casebase)
library(colorspace)
library(cowplot)
library(data.table)
library(glmnet)
library(kableExtra)
library(magrittr)
library(pracma)
library(flexsurv) 
library(prodlim)
library(riskRegression)
library(splines)
library(survival)
library(tibble)
library(visreg)
library(lubridate)
library(tidyverse)
library(scales)
options(digits = 2)
# set the seed for reproducible output
set.seed(1234)

# Turn on/off sections for faster compilation
eval_introduction <- TRUE
eval_theory <- TRUE
eval_implementation <- TRUE
eval_cs1 <- TRUE
eval_cs2 <- TRUE
eval_cs3 <- TRUE
eval_cs4 <- FALSE
eval_colophon <- FALSE # Only for draft
echo_plot_code <- TRUE
# Define theme for plots
paper_gg_theme <- theme_bw(base_size = 10) + theme(legend.position = "bottom")
# Define colour palette for CS 3
q4 <- qualitative_hcl(4, palette = "Dark 3")
names(q4) <- c("Cox", "Pen. Cox", "Pen. CB", "K-M")




## ----plot-stratified-erspc-data-code, eval = FALSE, echo = TRUE------------------------------
## plot(pt_object, add.base.series = TRUE)






## ---- eval = TRUE, echo=eval_cs1-------------------------------------------------------------
summary(fits[["splines"]]) 


## ---- eval = FALSE, echo=FALSE---------------------------------------------------------------
## print.summary.glm <- function(x,digits=max(3,getOption("digits")-3),symbolic.cor=x$symbolic.cor,
##                               signif.stars = getOption("show.signif.stars"),show.call=FALSE,show.resids=FALSE,...) {
##   if (show.call) cat("Call:\n", paste(deparse(x$call), sep = "\n", collapse = "\n"), "\n", sep = "")
##   if (show.resids) {
##     cat("Deviance Residuals: \n")
##     if (x$df.residual > 5) {
##       x$deviance.resid <- stats::quantile(x$deviance.resid, na.rm = TRUE)
##       names(x$deviance.resid) <- c("Min", "1Q", "Median", "3Q", "Max")
##     }
##     xx <- zapsmall(x$deviance.resid, digits + 1)
##     print.default(xx, digits = digits, na.print = "", print.gap = 2)
##     cat("\n")
##   }
##   if (length(x$aliased) == 0L) cat("No Coefficients\n")
##   else {
##     df <- if ("df" %in% names(x)) x[["df"]]
##     else NULL
##     if (!is.null(df) && (nsingular <- df[3L] - df[1L]))
##       cat("Coefficients: (", nsingular, " not defined because of singularities)\n", sep = "")
##     else cat("\nCoefficients:\n")
##     coefs <- x$coefficients
##     if (!is.null(aliased <- x$aliased) && any(aliased)) {
##       cn <- names(aliased)
##       coefs <- matrix(NA, length(aliased), 4L, dimnames = list(cn,colnames(coefs)))
##       coefs[!aliased, ] <- x$coefficients
##     }
##     stats::printCoefmat(coefs, digits = digits, signif.stars = signif.stars,na.print = "NA", ...)
##   }
##   cat("\n(Dispersion parameter for ", x$family$family, " family taken to be ",
##       format(x$dispersion), ")\n\n", apply(cbind(paste(format(c("Null","Residual"),
##                                                               justify = "right"), "deviance:"),
##                                                  format(unlist(x[c("null.deviance","deviance")]), digits = max(5, digits + 1)), " on",
##                                                  format(unlist(x[c("df.null", "df.residual")])), " degrees of freedom\n"),1L,
##                                            paste, collapse = " "), sep = "")
##   if (nzchar(mess <- stats::naprint(x$na.action))) cat("  (", mess, ")\n",sep="")
##   cat("AIC: ",format(x$aic,digits=max(4,digits+1)),"\n\n",
##       "Number of Fisher Scoring iterations: ",x$iter,"\n",sep="")
##   correl <- x$correlation
##   if (!is.null(correl)) {
##     p <- NCOL(correl)
##     if (p > 1) {
##       cat("\nCorrelation of Coefficients:\n")
##       if (is.logical(symbolic.cor) && symbolic.cor) print(stats::symnum(correl,abbr.colnames=NULL))
##       else {
##         correl <- format(round(correl, 2),nsmall=2,digits=digits)
##         correl[!lower.tri(correl)] <- ""
##         print(correl[-1,-p,drop=FALSE],quote=FALSE)
##       }
##     }
##   }
##   cat("\n")
##   invisible(x)
## }
## 
## print(summary(fits[["splines"]]), signif.stars = F)


## ---- eval=FALSE, echo=echo_plot_code--------------------------------------------------------
## new_data <- data.frame(ScrArm = c("Control group", "Screening group"))
## new_time <- seq(0, 14, by = 0.1)
## 
## risks <- lapply(fits, function(fit) {
##   absoluteRisk(fit, time = new_time, newdata = new_data)
## })
















## ---- echo = TRUE, eval = FALSE--------------------------------------------------------------
## plot(fit_inter, type = "hr", newdata = new_data,
##      var = "ScrArm", xvar = "Follow.Up.Time", ci = TRUE)

