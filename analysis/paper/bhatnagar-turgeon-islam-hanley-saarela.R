## ----setup, echo=FALSE, message=FALSE, warning=FALSE--------------------------
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


## ----erspc-data, eval = eval_cs1, echo = c(-1:-3)-----------------------------
data("ERSPC")
ERSPC$ScrArm <- factor(ERSPC$ScrArm, 
                       levels = c(0,1), 
                       labels = c("Control group", "Screening group"))

pt_object <- casebase::popTime(ERSPC, time = "Follow.Up.Time",
                               event = "DeadOfPrCa", exposure = "ScrArm")
inherits(pt_object, "popTime")
attr(pt_object, "exposure")


## ----plot-stratified-erspc-data-code, eval = FALSE, echo = TRUE---------------
#> plot(pt_object, add.base.series = TRUE)


## ----plot-stratified-erspc-data, eval = eval_cs1, echo = FALSE, fig.width=7, fig.height=5, fig.asp=0.75, fig.cap="Population time plots for both treatment arms in the ERSPC dataset. The gray area can be thought of as N=88,232 (control group) and N=71,661 (screening group) rows of infinitely thin rectangles (person-moments). More events are observed at later follow-up times, motivating the use of non-constant hazard models."----
label_number_si <- function (accuracy = 1, unit = NULL, sep = NULL, ...) {
    sep <- if (is.null(unit)) 
        ""
    else " "
    scales:::force_all(accuracy, ...)
    function(x) {
        breaks <- c(0, 10^c(K = 3, M = 6, B = 9, T = 12))
        n_suffix <- cut(abs(x), breaks = c(unname(breaks), Inf), 
            labels = c(names(breaks)), right = FALSE)
        n_suffix[is.na(n_suffix)] <- ""
        suffix <- paste0(sep, n_suffix, unit)
        scale <- 1/breaks[n_suffix]
        scale[which(scale %in% c(Inf, NA))] <- 1
        number(x, accuracy = accuracy, scale = unname(scale), 
            suffix = suffix, ...)
    }
}
plot(pt_object, 
     add.base.series = TRUE,
     ratio = 0.7,
     facet.params = list(ncol = 2),
     ribbon.params = list(fill = "gray50"),
     case.params = list(size = 0.8),
     base.params = list(size = 0.8)) + 
  paper_gg_theme +  
  scale_y_continuous(labels = label_number_si()) + 
  ylab("Population Size")


## ---- eval = eval_cs1, echo = -1----------------------------------------------
set.seed(12)
fmla <- list(exponential = formula(DeadOfPrCa ~ ScrArm),
             gompertz = formula(DeadOfPrCa ~ Follow.Up.Time + ScrArm),
             weibull = formula(DeadOfPrCa ~ log(Follow.Up.Time) + ScrArm),
             splines = formula(DeadOfPrCa ~ bs(Follow.Up.Time) + ScrArm))

fits <- lapply(fmla, function(form) {
  fitSmoothHazard(form, data = ERSPC, ratio = 100)
})


## ---- eval = TRUE, echo=eval_cs1----------------------------------------------
summary(fits[["splines"]]) 


## ---- eval=FALSE, echo=echo_plot_code-----------------------------------------
#> new_data <- data.frame(ScrArm = c("Control group", "Screening group"))
#> new_time <- seq(0, 14, by = 0.1)
#> 
#> risks <- lapply(fits, function(fit) {
#>   absoluteRisk(fit, time = new_time, newdata = new_data)
#> })


## ----erscp-compare, eval = eval_cs1, echo = FALSE-----------------------------
anova(fits$exponential, fits$splines, test = "LRT")


## ----erscp-aic, eval = eval_cs1, echo=FALSE-----------------------------------
c("Exp." = AIC(fits$exponential),
  "Gompertz" = AIC(fits$gompertz),
  "Weibull" = AIC(fits$weibull),
  "Splines" = AIC(fits$splines))


## ----erspc-cox, eval = eval_cs1, echo=FALSE-----------------------------------
surv_obj <- with(ERSPC, Surv(Follow.Up.Time, DeadOfPrCa))
cox_model <- survival::coxph(surv_obj ~ ScrArm, data = ERSPC)


## ----erspc-cox-cif, eval = eval_cs1, fig.align='h', echo = FALSE, fig.width=8, fig.height=6, fig.cap="CIFs for control and screening groups in the ERSPC data. In each of the panels, we plot the CIF from the Cox model using \\code{survival::survfit} (solid line) and the CIF from the case-base sampling scheme (dashed line) with different functional forms of time. (1) The time variable is excluded (exponential). (2) Linear function of time (Gompertz). (3) The natural logarithm (Weibull). (4) Cubic B-spline expansion of time."----
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
myCols <- cbPalette[c(4,7)]

new_data <- data.frame(ScrArm = c("Control group", "Screening group"))
new_time <- seq(0,14.5,0.1)

risks <- lapply(fits, function(i) {
  casebase::absoluteRisk(object = i, time = new_time, newdata = new_data, method = "mont")
})

layout(matrix(1:4, ncol = 2, byrow = FALSE), respect = FALSE)
par(mar = c(0, 4.1, 4.1, 0))
plot(survfit(cox_model, newdata = new_data),
     ylab = "",
     xlab = "",
     fun = "event",
     xmax = max(new_time),
     conf.int = FALSE, col = myCols, 
     lwd = 2,
     yscale = 100,
     xaxt = 'n')
legend("topleft", 
       legend = c("Control (Cox)","Control (Case-base)",
                  "Screening (Cox)", "Screening (Case-base)"), 
       col = rep(myCols, each = 2),
       lty = c(1, 2, 1, 2), 
       lwd = 2,
       cex = 1.1,
       bg = "gray90")
lines(risks$exponential[,1], risks$exponential[,2], col = myCols[1], lty = 2, lwd = 2)
lines(risks$exponential[,1], risks$exponential[,3], col = myCols[2], lty = 2, lwd = 2)
text(x = max(new_time)*0.97, y = 0.05/100, labels = "(1)", cex = 1.5)

par(mar = c(4.1, 4.1, 0, 0))
plot(survfit(cox_model, newdata = new_data),
     ylab = "", xlab = "",
     fun = "event",
     xmax = max(new_time),
     conf.int = FALSE, col = myCols, 
     lwd = 2,
     yscale = 100)
lines(risks$weibull[,1], risks$weibull[,2], col = myCols[1], lty = 2, lwd = 2)
lines(risks$weibull[,1], risks$weibull[,3], col = myCols[2], lty = 2, lwd = 2)  
text(x = max(new_time)*0.97, y = 0.05/100, labels = "(3)", cex = 1.5)
mtext("Cumulative incidence (%)", side = 2, line = -1.5, outer = TRUE)

par(mar = c(0, 0, 4.1, 3.9))
plot(survfit(cox_model, newdata = new_data),
     ylab = "",xlab = "",
     fun = "event",
      xaxt = 'n', yaxt = 'n',
     xmax = max(new_time),
     conf.int = FALSE, col = myCols, 
     lwd = 2,
     yscale = 100)
lines(risks$gompertz[,1], risks$gompertz[,2], col = myCols[1], lty = 2, lwd = 2)
lines(risks$gompertz[,1], risks$gompertz[,3], col = myCols[2], lty = 2, lwd = 2)
text(x = max(new_time)*0.97, y = 0.05/100, labels = "(2)", cex = 1.5)



par(mar = c(4.1, 0, 0, 3.9))
plot(survfit(cox_model, newdata = new_data),
     ylab = "",xlab = "",
     fun = "event",
     yaxt = 'n',
     xmax = max(new_time),
     conf.int = FALSE, col = myCols, 
     lwd = 2,
     yscale = 100)
lines(risks$splines[,1], risks$splines[,2], col = myCols[1], lty = 2, lwd = 2)
lines(risks$splines[,1], risks$splines[,3], col = myCols[2], lty = 2, lwd = 2)
text(x = max(new_time)*0.97, y = 0.05/100, labels = "(4)", cex = 1.5)
mtext("Years since randomization", side = 1, line = -1.5, outer = TRUE)


## ----erspc-95ci22, echo = FALSE, eval = eval_cs1------------------------------
CI_cox <- c(exp(coef(cox_model)), exp(confint(cox_model)))

aft_fits <- lapply(list("exp","gompertz","weibull"), function(i)
  flexsurv::flexsurvreg(Surv(Follow.Up.Time, DeadOfPrCa) ~ ScrArm,
                           data = ERSPC, dist = i)
  )

names(aft_fits) <- list("exponential","gompertz","weibull")


# function to exponentiate HR and CI and return a HR (lower, Upper) character
exp_est_ci <- function(model = c("exponential","gompertz","weibull","splines"),
                       fit, 
                       covariate = "ScrArmScreening group", 
                       type = c("casebase", "survreg")) {
  
  type <- match.arg(type)
  covariate <- match.arg(covariate)
  
  if (type == "casebase"){
    
    cis <- confint(fit[[model]])
    
    sprintf("%0.2f (%0.2f, %0.2f)",
            exp(coef(fit[[model]]))[[covariate]],
            exp(cis)[covariate,1],
            exp(cis)[covariate,2])
  } else {
    
    if (model == "weibull") {

      # The maximized log-likelihoods are the same between survreg and flexsurvreg, 
      # however the parameterisation is different: the first coefficient (Intercept) 
      # reported by survreg is log(mu), and survreg's "scale" is
      # dweibull's (thus flexsurvreg)'s 1 / shape
      res <- -fit[[model]]$res[covariate,] / (1 / fit[[model]]$res["shape",])
      
      sprintf("%0.2f (%0.2f, %0.2f)",
              exp(res[["est"]]),
              exp(res[["U95%"]]),
              exp(res[["L95%"]]))
      
    } else if (model == "splines") {
      
      c("--")
      
    } else {
      
      res <- fit[[model]]$res[covariate,]
      
      sprintf("%0.2f (%0.2f, %0.2f)",
              exp(res[["est"]]),
              exp(res[["L95%"]]),
              exp(res[["U95%"]]))
    }
  }
}

casebase_HR_CI <- lapply(list("exponential","gompertz","weibull","splines"), 
                         exp_est_ci, 
                         fit = fits,
                         covariate = "ScrArmScreening group", 
                         type = "casebase")

survreg_HR_CI <- lapply(list("exponential","gompertz","weibull","splines"), 
                         exp_est_ci, 
                         fit = aft_fits,
                         covariate = "ScrArmScreening group", 
                         type = "survreg")

ptable <- cbind(list("Exponential","Gompertz","Weibull","Splines"),
            do.call(rbind, casebase_HR_CI), do.call(rbind, survreg_HR_CI))


## ----print-erspc-estimates, eval = eval_cs1-----------------------------------
kable(ptable, "latex", booktabs = TRUE, align = c("l","c","c"),
      caption = c("Comparison of estimated hazard ratios and 95\\% confidence intervals for ERSPC data."),
      col.names = c("Model","casebase::fitSmoothHazard","survival::survreg")) %>%
  kable_styling() %>%
  column_spec(1, bold = TRUE) %>%
  collapse_rows(columns = 1, latex_hline = "major", valign = "middle") %>%
  footnote(general = sprintf("Cox model estimate: HR (95%% CI) = %0.2f (%0.2f, %0.2f)", CI_cox[1], CI_cox[2], CI_cox[3]),
           general_title = "") 


## ---- echo=-1, eval = eval_cs1------------------------------------------------
set.seed(12)
fit_inter <- fitSmoothHazard(DeadOfPrCa ~ bs(Follow.Up.Time) * ScrArm, 
                             data = ERSPC)


## ---- echo = TRUE, eval = FALSE-----------------------------------------------
#> plot(fit_inter, type = "hr", newdata = new_data,
#>      var = "ScrArm", xvar = "Follow.Up.Time", ci = TRUE)


## ----interaction-ERSPC, eval = eval_cs1, fig.width=8, fig.height=6, fig.cap='Estimated hazard ratio and 95\\% confidence interval for screening vs. control group as a function of time in the ERSPC dataset. Hazard ratios are estimated from fitting a parametric hazard model as a function of the interaction between a cubic B-spline basis of follow-up time and treatment arm. 95\\% confidence intervals are calculated using the delta method. The plot shows that the effect of screening only begins to become statistically apparent by year 7. The 25-60\\% reductions seen in years 8-12 of the study suggests a much higher reduction in prostate cancer due to screening than the single overall 20\\% reported in the original article.'----
new_time <- seq(1, 12, by  = 0.1)
new_data <- data.frame(ScrArm = factor("Control group",
                                         levels = c("Control group","Screening group")),
                      Follow.Up.Time = new_time)

par(oma = c(0,1,0,8))
tt <- plot(fit_inter,
     type = "hr",
     newdata = new_data,
     var = "ScrArm",
     increment = 1,
     xvar = "Follow.Up.Time",
     ci = T,
     xlab = "Follow-up time (years)",
     ylab = "Death from prostate cancer hazard ratio",
     ylim = c(0,1.50),
     yaxt = 'n',
     xaxt = "n",
     rug = TRUE)

axis(2, at = seq(0,1.50, by=0.25), las = 2)
axis(1, at = seq(min(new_time),max(new_time), by=1))
for( i in seq(0,1.50, by=0.25)) {
  abline(h = i, lty = 1, col = "lightgrey")
}
for( i in seq(min(new_time),max(new_time), by=1)) {
  abline(v = i, lty = 1, col = "lightgrey")
}
for(i in seq_along(seq(0, 0.75, by = 0.25))) {
  mtext(paste0(seq(0, 0.75, by = 0.25)[i]*100,"%"), side = 4, las = 2, adj = 1, outer = TRUE, line = 2, at = c(0.63-0.11*(i-1)))
}
lines(tt$Follow.Up.Time, tt$hazard_ratio, lwd = 2, lty = 1)
mtext("% reduction in\nprostate cancer\nmortality rate", side = 4, las = 2, outer = TRUE, line = -1, at = 0.7)


## ----bmtcrr-data, eval = eval_cs2, message = FALSE----------------------------
data(bmtcrr)


## ----compPop, fig.cap="Population-time plot for the stem-cell transplant study with both relapse and competing events.", echo=FALSE, eval = eval_cs2----
popTimeData <- popTime(data = bmtcrr, time = "ftime")

plot(popTimeData, 
     add.competing.event = TRUE,
     comprisk = TRUE,
     ribbon.params = list(fill = "gray50"),
     case.params = list(size = 0.8),
     competing.params = list(size = 0.8)) + 
  paper_gg_theme +  
  scale_y_continuous(labels = label_number_si())


## ----bmtcrr-casebase-weibull, warning = FALSE, eval = eval_cs2, echo = TRUE----
model_cb <- fitSmoothHazard(
  Status ~ ftime + Sex + D + Phase + Source + Age,
  data = bmtcrr,
  ratio = 100,
  time = "ftime"
)


## ----bmtcrr-cox, echo = TRUE, eval = eval_cs2---------------------------------
library(survival)
# Treat competing event as censoring
model_cox <- coxph(Surv(ftime, Status == 1) ~ Sex + D + Phase + Source + Age,
                   data = bmtcrr)


## ----bmtcrr-cis, echo=FALSE, eval = eval_cs2----------------------------------
# Table of coefficients
library(glue)
z_value <- qnorm(0.975)
foo <- summary(model_cb)@coef3
table_cb <- foo[
  !grepl("Intercept", rownames(foo)) &
    !grepl("ftime", rownames(foo)) &
    grepl(":1", rownames(foo)),
  1:2
]
table_cb <- cbind(
  table_cb[, 1],
  table_cb[, 1] - z_value * table_cb[, 2],
  table_cb[, 1] + z_value * table_cb[, 2]
)
table_cb <- round(exp(table_cb), 2)

table_cox <- round(summary(model_cox)$conf.int[, -2], 2)
rownames(table_cb) <- rownames(table_cox)
colnames(table_cb) <- colnames(table_cox)

table_cb <- as.data.frame(table_cb) %>%
  tibble::rownames_to_column("Covariates") %>%
  mutate(CI = glue::glue_data(., "({`lower .95`}, {`upper .95`})")) %>%
  rename(HR = `exp(coef)`) %>%
  select(Covariates, HR, CI)

table_cox <- as.data.frame(table_cox) %>%
  tibble::rownames_to_column("Covariates") %>%
  dplyr::mutate(CI_Cox = glue::glue_data(., "({`lower .95`}, {`upper .95`})")) %>%
  dplyr::rename(HR_Cox = `exp(coef)`) %>%
  dplyr::select(Covariates, HR_Cox, CI_Cox)

table_cb %>%
  dplyr::inner_join(table_cox, by = "Covariates") %>%
  dplyr::mutate(Covariates = dplyr::case_when(
    Covariates == "SexM" ~ "Sex",
    Covariates == "DAML" ~ "Disease",
    Covariates == "PhaseCR2" ~ "Phase (CR2 vs. CR1)",
    Covariates == "PhaseCR3" ~ "Phase (CR3 vs. CR1)",
    Covariates == "PhaseRelapse" ~ "Phase (Relapse vs. CR1)",
    Covariates == "SourcePB" ~ "Source",
    TRUE ~ Covariates
  )) %>%
  knitr::kable(
    format = "latex", booktabs = TRUE,
    col.names = c("Covariates", "HR", "95% CI", "HR", "95% CI"),
    caption = "Estimates and confidence intervals for the hazard ratios for each coefficient. Both estimates from case-base sampling and Cox regression are presented."
  ) %>%
  kable_styling() %>%
  add_header_above(c(" " = 1, "Case-Base" = 2, "Cox" = 2))


## ----cb_risk, warning = FALSE, cache = FALSE, eval = eval_cs2-----------------
# Pick 100 equidistant points between 0 and 60 months
time_points <- seq(0, 60, length.out = 50)

# Data.frame containing risk profile
newdata <- data.frame(
  "Sex" = factor(c("F", "F"),
    levels = levels(bmtcrr[, "Sex"])
  ),
  "D" = c("ALL", "AML"), # Both diseases
  "Phase" = factor(c("Relapse", "Relapse"),
    levels = levels(bmtcrr[, "Phase"])
  ),
  "Age" = c(35, 35),
  "Source" = factor(c("PB", "PB"),
    levels = levels(bmtcrr[, "Source"])
  )
)

# Estimate absolute risk curve
risk_cb <- absoluteRisk(
  object = model_cb, time = time_points,
  method = "numerical", newdata = newdata
)


## ----fg_risk, eval = eval_cs2, echo = TRUE------------------------------------
library(timereg)
model_fg <- comp.risk(Event(ftime, Status) ~ const(Sex) + const(D) +
                        const(Phase) + const(Source) + const(Age),
                      data = bmtcrr, cause = 1, model = "fg")

# Estimate absolute risk curve
risk_fg <- predict(model_fg, newdata, times = time_points)


## ----bmtcrr-risk, echo = FALSE, fig.cap="\\label{fig:compAbsrisk} Absolute risk curve for a fixed covariate profile and the two disease groups. The estimate obtained from case-base sampling is compared to the Kaplan-Meier estimate.", eval = eval_cs2----
risk_all <- dplyr::bind_rows(
  data.frame(
    Time = time_points,
    Method = "Case-base",
    Risk = risk_cb[, 2],
    Disease = "ALL",
    stringsAsFactors = FALSE
  ),
  data.frame(
    Time = time_points,
    Method = "Case-base",
    Risk = risk_cb[, 3],
    Disease = "AML",
    stringsAsFactors = FALSE
  ),
  data.frame(
    Time = time_points,
    Method = "Fine-Gray",
    Risk = risk_fg$P1[1, ],
    Disease = "ALL",
    stringsAsFactors = FALSE
  ),
  data.frame(
    Time = time_points,
    Method = "Fine-Gray",
    Risk = risk_fg$P1[2, ],
    Disease = "AML",
    stringsAsFactors = FALSE
  )
)

ggplot(risk_all, aes(x = Time, y = Risk, colour = Method)) +
  # geom_line for smooth curve
  geom_line(data = dplyr::filter(risk_all, Method == "Case-base")) +
  # geom_step for step function
  geom_step(data = dplyr::filter(risk_all, Method != "Case-base")) +
  facet_grid(Disease ~ .) +
  ylim(c(0, 1)) +
  paper_gg_theme +  
  xlab("Time (in Months)") +
  ylab("Relapse risk")


## ----supportData, eval = eval_cs3---------------------------------------------
scaleFUNy <- function(x) sprintf("%.2f", x)
scaleFUNx <- function(x) sprintf("%.0f", x)
data(support)
# Change time to years
support$d.time <- support$d.time/365.25

# Split into test and train
train_index <- sample(nrow(support), 0.95*nrow(support))
test_index <- setdiff(1:nrow(support), train_index)

train <- support[train_index,]
test <- support[test_index,]


## ----supportCox_fit, eval=eval_cs3, echo=FALSE, cache=FALSE-------------------
# Cox with everything but sps and aps
cox <- survival::coxph(Surv(time = d.time, event = death) ~ . - aps - sps,
                           data = train, x = TRUE)


## ----supportCB_fit, eval=eval_cs3, echo=TRUE, cache=FALSE---------------------
# Create matrices for inputs
x <- model.matrix(death ~ . - d.time - aps - sps, 
                  data = train)[, -c(1)] # Remove intercept
y <- data.matrix(subset(train, select = c(d.time, death)))

# Regularized logistic regression to estimate hazard
pen_cb <- casebase::fitSmoothHazard.fit(x, y,
  family = "glmnet",
  time = "d.time", event = "death",
  formula_time = ~ log(d.time), alpha = 1,
  ratio = 10, standardize = TRUE,
  penalty.factor = c(0, rep(1, ncol(x)))
)


## ----coxHazAbsolute, echo = FALSE, eval = eval_cs3----------------------------
# Create survival object for fitting Coxnet
u <- with(train, survival::Surv(time = d.time, event = death))
coxNet <- glmnet::cv.glmnet(x = x, y = u, family = "cox", alpha = 1, standardize = TRUE)

# Taking the coefficient estimates for later use
nonzero_covariate_cox <- predict(coxNet, type = "nonzero", s = "lambda.1se")
nonzero_coef_cox <- coef(coxNet, s = "lambda.1se")
# Creating a new dataset that only contains the covariates chosen through glmnet
cleanCoxData <- as.data.frame(cbind(y, x[, nonzero_covariate_cox$X1]))

# Fitting a cox model using regular estimation, however we will not keep it.
# this is used more as an object place holder.
coxNet <- survival::coxph(Surv(time = d.time, event = death) ~ ., 
                          data = cleanCoxData, x = TRUE)

# The coefficients of this object will be replaced with the estimates from the
# original coxNet. Doing so makes it so that everything is invalid aside from
# the coefficients. In this case, all we need to estimate the absolute risk is
# the coefficients. Std. error would be incorrect here, if we were to draw error
# bars.
coxNet_coefnames <- names(coxNet$coefficients)
coxNet$coefficients <- nonzero_coef_cox@x
names(coxNet$coefficients) <- coxNet_coefnames


## ----coefplots, echo=FALSE, eval=eval_cs3, fig.cap="\\label{fig:cs3lolliPlot} Coefficient estimates from the Cox model (Cox), penalized Cox model using the \\CRANpkg{glmnet} package (Pen. Cox), and our approach using penalized case-base sampling (Pen. CB). Only the covariates that were selected by both penalized approaches are shown. The shrinkage of the coefficient estimates for Pen. Cox and Pen. CB occurs due to the $\\ell_1$ penalty."----
library(dotwhisker)
library(broom)
library(dplyr)

# extract coefficients for lollipop plot
estimatescoxNet <- data.table::setDT(as.data.frame(coef(coxNet)), 
                                     keep.rownames = TRUE)

estimatescoxNet$Model <- "Pen. Cox"
colnames(estimatescoxNet) <- c("term", "estimate", "model")

estimatescb <- data.table::setDT(as.data.frame(coef(pen_cb)[-c(1, 2), 1]),
                                 keep.rownames = TRUE)
estimatescb$Model <- "Pen. CB"
colnames(estimatescb) <- c("term", "estimate", "model")

estimatescox <- data.table::setDT(as.data.frame(coef(cox)), 
                                  keep.rownames = TRUE)
cox$coefficients[which(is.na(cox$coefficients))] <- 0
estimatescox$Model <- "Cox"
colnames(estimatescox) <- c("term", "estimate", "model")

# Clean up the data and the variable names
lolliplotDots <- rbind(estimatescox, estimatescoxNet, estimatescb)
lolliplotDots$conf.low <- lolliplotDots$estimate
lolliplotDots$conf.high <- lolliplotDots$estimate
lolliplotDots$conf.high[lolliplotDots$estimate < 0] <- 0
lolliplotDots$conf.low[lolliplotDots$estimate > 0] <- 0
lolliplotDots$term <- gsub("\`", "", as.character(lolliplotDots$term))

lolliplotDots[which(lolliplotDots$estimate == 0), c(2, 4, 5)] <- NA
unChosen <- unique(lolliplotDots[which(is.na(lolliplotDots$estimate)), 1])

lolliplotDots[which(lolliplotDots$term %in% unChosen$term), c(2, 4, 5)] <- NA

lolliplotDots <- lolliplotDots[-which(is.na(lolliplotDots$estimate)), ]
dwplot(lolliplotDots) +
  theme(
    axis.text.y = element_text(size = 11, angle = 0, hjust = 1, vjust = 0),
    strip.text.x = element_blank(),
    strip.background = element_rect(colour = "white", fill = "white"),
    legend.position = c(.855, 0.15), legend.text = element_text(size = 11)
  ) +
  paper_gg_theme +  
  labs(color = "Models") +
  scale_color_manual(values = q4)


## ----support_abs, eval=eval_cs3, echo=FALSE-----------------------------------
# Absolute Risks
newx <- model.matrix(death ~ . - d.time - aps - sps,
                     data = test)[, -c(1)]
times <- sort(unique(test$d.time))
# 1. Unpenalized Cox
abcox <- survival::survfit(cox, newdata = test)

# 2. Penalized Cox
abcoxNet <- survival::survfit(coxNet, type = "breslow", 
                              newdata = as.data.frame(newx[, nonzero_covariate_cox$X1]))

# 3. Penalized Case-base
abpen_cb <- casebase::absoluteRisk(pen_cb,
  time = times,
  newdata = newx,
  s = "lambda.1se",
  method = "numerical"
)

# 4. Kaplan-Meier
KM <- survival::coxph(Surv(time = d.time, event = death) ~ 1, data = test,
                      x = TRUE)
abKM <- survival::survfit(KM)

# Combine absolute risk estimates
data_absRisk <- bind_rows(
  data.frame(Time = abcox$time, Prob = 1 - rowMeans(abcox$surv),
             Model = "Cox"),
  data.frame(Time = abcoxNet$time, Prob = 1 - rowMeans(abcoxNet$surv),
             Model = "Pen. Cox"),
  data.frame(Time = abpen_cb[, 1], Prob = rowMeans(abpen_cb[, -c(1)]),
             Model = "Pen. CB"),
  data.frame(Time = abKM$time, Prob = 1 - abKM$surv,
             Model = "K-M")
) %>% 
  mutate(Model = factor(Model, levels = names(q4)))


## ----absRiskPlot, echo=FALSE, eval=eval_cs3-----------------------------------
reg_ci <- ggplot(data_absRisk, aes(Time, Prob)) +
  geom_line(aes(colour = Model)) +
  labs(y = "Probability of death", x = "Follow-up time (years)", color = "Models") +
  scale_color_manual(values = q4) + 
  expand_limits(y = 1) +
  paper_gg_theme + 
  scale_x_continuous(labels = scaleFUNx, breaks = round(seq(0, 5, by = 1))) + 
  scale_y_continuous(labels = scaleFUNy, n.breaks = 9)


## ----eval = eval_cs3, echo = FALSE, warning = FALSE---------------------------
# We need this chunk until this method reaches the CRAN version of riskRegression
predictRisk.singleEventCB <- function(object, newdata, times, cause, ...) {
  if (!is.null(object$matrix.fit)) {
    #get all covariates excluding intercept and time
    coVars=colnames(object$originalData$x)
    #coVars is used in lines 44 and 50
    newdata=data.matrix(drop(subset(newdata, select=coVars)))
  }
  
  # if (missing(cause)) stop("Argument cause should be the event type for which we predict the absolute risk.")
  # the output of absoluteRisk is an array with dimension depending on the length of the requested times:
  # case 1: the number of time points is 1
  #         dim(array) =  (length(time), NROW(newdata), number of causes in the data)
  if (length(times) == 1) {
    a <- casebase::absoluteRisk(object, newdata = newdata, time = times)
    p <- matrix(a, ncol = 1)
  } else {
    # case 2 a) zero is included in the number of time points
    if (0 %in% times) {
      # dim(array) =  (length(time)+1, NROW(newdata)+1, number of causes in the data)
      a <- casebase::absoluteRisk(object, newdata = newdata, time = times)
      p <- t(a)
    } else {
      # case 2 b) zero is not included in the number of time points (but the absoluteRisk function adds it)
      a <- casebase::absoluteRisk(object, newdata = newdata, time = times)
      ### we need to invert the plot because, by default, we get cumulative incidence
      #a[, -c(1)] <- 1 - a[, -c(1)]
      ### we remove time 0 for everyone, and remove the time column
      a <- a[-c(1), -c(1)] ### a[-c(1), ] to keep times column, but remove time 0 probabilities
      # now we transpose the matrix because in riskRegression we work with number of
      # observations in rows and time points in columns
      p <- t(a)
    }
  }
  if (NROW(p) != NROW(newdata) || NCOL(p) != length(times)) {
    stop(paste("\nPrediction matrix has wrong dimensions:\nRequested newdata x times: ", 
               NROW(newdata), " x ", length(times), "\nProvided prediction matrix: ", 
               NROW(p), " x ", NCOL(p), "\n\n", sep = ""))
  }
  p
}


## ----support_Brier, eval=eval_cs3, echo=FALSE---------------------------------
# Brier score
# 1. Unpenalized models
# First fix NA coefficients, then compute Brier score
brierCoxKM <- Score(list("Cox" = cox,
                         "K-M" = KM), data = test,
                   formula = Hist(d.time, death != 0) ~ 1, summary = NULL,
                   se.fit = FALSE, metrics = "brier", contrasts = FALSE, 
                   times = times)

# 2. Penalized models
brierPenalized <- Score(list("Pen. Cox" = coxNet, 
                             "Pen. CB" = pen_cb),
                        data = cbind(subset(test, select = c(d.time, death)),
                                     as.data.frame(newx)),
                        formula = Hist(d.time, death != 0) ~ 1, summary = NULL, 
                        se.fit = FALSE, metrics = "brier", contrasts = FALSE, 
                        times = times)


## ----riskregressionBrier, echo = FALSE, eval = eval_cs3, fig.cap="\\label{fig:cs3FinalBrier} Comparison of Cox regression (Cox), penalized Cox regression (Pen. Cox), penalized case-base sampling estimation (Pen. CB), and Kaplan-Meier (K-M). (A)  Probability of death as a function of follow-up time. (B) Brier score as a function of follow-up time, where a lower score corresponds to better performace.", warning = FALSE----
# Combine scores
data_brier <- bind_rows(
  brierCoxKM$Brier$score %>% 
    mutate(model = as.character(model)) %>% 
    filter(model != "Null model"),
  brierPenalized$Brier$score %>% 
    mutate(model = as.character(model)) %>% 
    filter(model != "Null model")
  ) %>% 
  mutate(model = factor(model, levels = c("Cox", "Pen. Cox", "Pen. CB", "K-M")))

reg_brier <- ggplot(data = data_brier, aes(x = times, y = Brier, col = model)) +
  geom_line() +
  xlab("Follow-up time (years)") +
  ylab("Brier score") +
  labs(color = "Models") +
  paper_gg_theme +  
  scale_color_manual(values = q4) + 
  scale_x_continuous(labels = scaleFUNx, 
                     breaks = round(seq(0, 5, by = 1))) + 
  scale_y_continuous(labels = scaleFUNy, n.breaks = 8)

# Combine both plots using cowplot
plot_row_reg <- cowplot::plot_grid(reg_ci + theme(legend.position = 'none'),
                                   reg_brier + theme(legend.position = 'none'),
                                   labels = c("A", "B"))
legend_reg <- cowplot::get_legend(
  # create some space to the left of the legend
  reg_ci + theme(legend.box.margin = margin(0, 0, 0, 12))
)

cowplot::plot_grid(plot_row_reg, legend_reg, rel_heights = c(3, .4), nrow = 2)


## ----colophon, eval = eval_colophon, cache = FALSE----------------------------
#> # which R packages and versions?
#> # devtools::session_info()
#> sessionInfo()


## ---- eval = eval_colophon----------------------------------------------------
#> # what commit is this file at?
#> git2r::repository(here::here())

