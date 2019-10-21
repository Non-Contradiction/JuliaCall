pkgname <- "buildmer"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
library('buildmer')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("add.terms")
### * add.terms

flush(stderr()); flush(stdout())

### Name: add.terms
### Title: Add terms to a formula
### Aliases: add.terms

### ** Examples

library(buildmer)
form <- Reaction ~ Days + (1|Subject)
add.terms(form,'Days|Subject')
add.terms(form,'(0+Days|Subject)')
add.terms(form,c('many','more|terms','to|terms','(be|added)','to|test'))



cleanEx()
nameEx("build.formula")
### * build.formula

flush(stderr()); flush(stdout())

### Name: build.formula
### Title: Convert a buildmer term list into a proper model formula
### Aliases: build.formula

### ** Examples

library(buildmer)
form1 <- Reaction ~ Days + (Days|Subject)
terms <- tabulate.formula(form1)
form2 <- build.formula(dep='Reaction',terms)

# check that the two formulas give the same results
library(lme4)
check <- function (f) resid(lmer(f,sleepstudy))
all.equal(check(form1),check(form2))



cleanEx()
nameEx("buildGLMMadaptive")
### * buildGLMMadaptive

flush(stderr()); flush(stdout())

### Name: buildGLMMadaptive
### Title: Use 'buildmer' to fit generalized linear mixed models using
###   'mixed_model' from package 'GLMMadaptive'
### Aliases: buildGLMMadaptive

### ** Examples




cleanEx()
nameEx("buildbam")
### * buildbam

flush(stderr()); flush(stdout())

### Name: buildbam
### Title: Use 'buildmer' to fit big generalized additive models using
###   'bam' from package 'mgcv'
### Aliases: buildbam

### ** Examples

## Don't show: 
library(buildmer)
m <- buildbam(f1 ~ s(timepoint,bs='cr'),data=vowels)
## End(Don't show)



cleanEx()
nameEx("buildcustom")
### * buildcustom

flush(stderr()); flush(stdout())

### Name: buildcustom
### Title: Use 'buildmer' to perform stepwise elimination using a custom
###   fitting function
### Aliases: buildcustom

### ** Examples

## Use \code{buildmer} to do stepwise linear discriminant analysis
library(buildmer)
migrant[,-1] <- scale(migrant[,-1])
flipfit <- function (p,formula) {
    # The predictors must be entered as dependent variables in a MANOVA
    # (i.e. the predictors must be flipped with the dependent variable)
    Y <- model.matrix(formula,migrant)
    m <- lm(Y ~ 0+migrant$changed)
    # the model may error out when asking for the MANOVA
    test <- try(anova(m))
    if (inherits(test,'try-error')) test else m
}
crit.F <- function (ma,mb) { # use whole-model F
    pvals <- anova(mb)$'Pr(>F)' # not valid for backward!
    pvals[length(pvals)-1]
}
crit.Wilks <- function (ma,mb) {
    if (is.null(ma)) return(crit.F(ma,mb)) #not completely correct, but close as F approximates X2
    Lambda <- anova(mb,test='Wilks')$Wilks[1]
    p <- length(coef(mb))
    n <- 1
    m <- nrow(migrant)
    Bartlett <- ((p-n+1)/2-m)*log(Lambda)
    pchisq(Bartlett,n*p,lower.tail=FALSE)
}

# First, order the terms based on Wilks' Lambda
m <- buildcustom(changed ~ friends.nl+friends.be+multilingual+standard+hearing+reading+attention+
sleep+gender+handedness+diglossic+age+years,direction='order',fit=flipfit,crit=crit.Wilks)
# Now, use the six most important terms (arbitrary choice) in the LDA
library(MASS)
m <- lda(changed ~ diglossic + age + reading + friends.be + years + multilingual,data=migrant)



cleanEx()
nameEx("buildgam")
### * buildgam

flush(stderr()); flush(stdout())

### Name: buildgam
### Title: Use 'buildmer' to fit generalized additive models using 'gam'
###   from package 'mgcv'
### Aliases: buildgam

### ** Examples

## Don't show: 
library(buildmer)
m <- buildgam(f1 ~ s(timepoint,bs='cr'),data=vowels)
## End(Don't show)



cleanEx()
nameEx("buildgamm4")
### * buildgamm4

flush(stderr()); flush(stdout())

### Name: buildgamm4
### Title: Use 'buildmer' to fit generalized additive models using package
###   'gamm4'
### Aliases: buildgamm4

### ** Examples

## Don't show: 
library(buildmer)
m <- buildgamm4(Reaction ~ Days + (Days|Subject),data=lme4::sleepstudy)
## End(Don't show)



cleanEx()
nameEx("buildglmmTMB")
### * buildglmmTMB

flush(stderr()); flush(stdout())

### Name: buildglmmTMB
### Title: Use 'buildmer' to perform stepwise elimination on 'glmmTMB'
###   models
### Aliases: buildglmmTMB

### ** Examples

library(buildmer)
m <- buildglmmTMB(Reaction ~ Days + (Days|Subject),data=lme4::sleepstudy)
## Don't show: ## No test: 
##D # What's the point of both \dontshow and \donttest, you ask? I want this to be tested when checking my package with --run-donttest, but the model is statistically nonsensical, so no good in showing it to the user!
##D vowels$event <- with(vowels,interaction(participant,word))
##D m <- buildglmmTMB(f1 ~ timepoint,include=~ar1(0+participant|event),data=vowels)
## End(No test)## End(Don't show)



cleanEx()
nameEx("buildgls")
### * buildgls

flush(stderr()); flush(stdout())

### Name: buildgls
### Title: Use 'buildmer' to fit generalized-least-squares models using
###   'gls' from 'nlme'
### Aliases: buildgls

### ** Examples

library(buildmer)
library(nlme)
vowels$event <- with(vowels,interaction(participant,word))
m <- buildgls(f1 ~ timepoint*following,correlation=corAR1(form=~1|event),data=vowels)



cleanEx()
nameEx("buildjulia")
### * buildjulia

flush(stderr()); flush(stdout())

### Name: buildjulia
### Title: Use 'buildmer' to perform stepwise elimination on models fit
###   with Julia package 'MixedModels' via 'JuliaCall'
### Aliases: buildjulia

### ** Examples




cleanEx()
nameEx("buildlme")
### * buildlme

flush(stderr()); flush(stdout())

### Name: buildlme
### Title: Use 'buildmer' to perform stepwise elimination of mixed-effects
###   models fit via 'lme' from 'nlme'
### Aliases: buildlme

### ** Examples

library(buildmer)
m <- buildlme(Reaction ~ Days + (Days|Subject),data=lme4::sleepstudy)



cleanEx()
nameEx("buildmer-class")
### * buildmer-class

flush(stderr()); flush(stdout())

### Name: buildmer-class
### Title: The buildmer class
### Aliases: buildmer-class mkBuildmer

### ** Examples

# Manually create a bare-bones buildmer object:
model <- lm(Sepal.Length ~ Petal.Length,iris)
p <- list(in.buildmer=FALSE)
library(buildmer)
bm <- mkBuildmer(model=model,p=p,anova=NULL,summary=NULL)
summary(bm)



cleanEx()
nameEx("buildmer-package")
### * buildmer-package

flush(stderr()); flush(stdout())

### Name: buildmer-package
### Title: Construct and fit as complete a model as possible and perform
###   stepwise elimination
### Aliases: buildmer-package

### ** Examples




cleanEx()
nameEx("buildmer")
### * buildmer

flush(stderr()); flush(stdout())

### Name: buildmer
### Title: Use 'buildmer' to fit mixed-effects models using 'lmer'/'glmer'
###   from 'lme4'
### Aliases: buildmer

### ** Examples

library(buildmer)
m <- buildmer(Reaction ~ Days + (Days|Subject),lme4::sleepstudy)

#tests from github issue #2:
bm.test <- buildmer(cbind(incidence,size - incidence) ~ period + (1 | herd),
           family=binomial,data=lme4::cbpp)
bm.test <- buildmer(cbind(incidence,size - incidence) ~ period + (1 | herd),
           family=binomial,data=lme4::cbpp,direction='forward')
bm.test <- buildmer(cbind(incidence,size - incidence) ~ period + (1 | herd),
           family=binomial,data=lme4::cbpp,crit='AIC')
bm.test <- buildmer(cbind(incidence,size - incidence) ~ period + (1 | herd),
           family=binomial,data=lme4::cbpp,direction='forward',crit='AIC')



cleanEx()
nameEx("buildmertree")
### * buildmertree

flush(stderr()); flush(stdout())

### Name: buildmertree
### Title: Use 'buildmer' to perform stepwise elimination for _the
###   random-effects part_ of 'lmertree()' and 'glmertree()' models from
###   package 'glmertree'
### Aliases: buildmertree

### ** Examples

library(buildmer)
m <- buildmertree(Reaction ~ 1 | (Days|Subject) | Days,crit='LL',direction='order',
                  data=lme4::sleepstudy,joint=FALSE)
m <- buildmertree(Reaction ~ 1 | (Days|Subject) | Days,crit='LL',direction='order',
                  data=lme4::sleepstudy,family=Gamma(link=identity),joint=FALSE)



cleanEx()
nameEx("buildmultinom")
### * buildmultinom

flush(stderr()); flush(stdout())

### Name: buildmultinom
### Title: Use 'buildmer' to perform stepwise elimination for 'multinom'
###   models from package 'nnet'
### Aliases: buildmultinom

### ** Examples

library(buildmer)
options(contrasts = c("contr.treatment", "contr.poly"))
library(MASS)
example(birthwt)
bwt.mu <- buildmultinom(low ~ age*lwt*race*smoke,bwt)



base::options(contrasts = c(unordered = "contr.treatment",ordered = "contr.poly"))
cleanEx()
nameEx("conv")
### * conv

flush(stderr()); flush(stdout())

### Name: conv
### Title: Test a model for convergence
### Aliases: conv

### ** Examples

library(buildmer)
library(lme4)
good1 <- lm(Reaction ~ Days,sleepstudy)
good2 <- lmer(Reaction ~ Days + (Days|Subject),sleepstudy)
bad <- lmer(Reaction ~ Days + (Days|Subject),sleepstudy,control=lmerControl(
            optimizer='bobyqa',optCtrl=list(maxfun=1)))
sapply(c(good1,good2,bad),conv)



cleanEx()
nameEx("diag-formula-method")
### * diag-formula-method

flush(stderr()); flush(stdout())

### Name: diag,formula-method
### Title: Diagonalize the random-effect covariance structure, possibly
###   assisting convergence
### Aliases: diag,formula-method

### ** Examples

# 1. Create explicit columns for factor variables
library(buildmer)
vowels <- cbind(vowels,model.matrix(~vowel,vowels))
# 2. Create formula with diagonal covariance structure
form <- diag(f1 ~ (vowel1+vowel2+vowel3+vowel4)*timepoint*following + 
	     ((vowel1+vowel2+vowel3+vowel4)*timepoint*following | participant) +
	     (timepoint | word))
# 3. Convert formula to buildmer terms list, grouping terms starting with 'vowel'
terms <- tabulate.formula(form,group='vowel[^:]')
# 4. Directly pass the terms object to buildmer(), using the hidden 'dep' argument to specify
# the dependent variable



cleanEx()
nameEx("remove.terms")
### * remove.terms

flush(stderr()); flush(stdout())

### Name: remove.terms
### Title: Remove terms from an lme4 formula
### Aliases: remove.terms

### ** Examples

library(buildmer)
remove.terms(Reaction ~ Days + (Days|Subject),'(Days|Subject)')
# illustration of the marginality checking mechanism:
remove.terms(Reaction ~ Days + (Days|Subject),'(1|Subject)') #refuses to remove the term
remove.terms(Reaction ~ Days + (Days|Subject),c('(Days|Subject)','(1|Subject)')) #also
           #refuses to remove the term, because marginality is checked before removal!
step1 <- remove.terms(Reaction ~ Days + (Days|Subject),'(Days|Subject)')
step2 <- remove.terms(step1,'(1|Subject)') #works



cleanEx()
nameEx("tabulate.formula")
### * tabulate.formula

flush(stderr()); flush(stdout())

### Name: tabulate.formula
### Title: Parse a formula into a buildmer terms list
### Aliases: tabulate.formula

### ** Examples

form <- diag(f1 ~ (vowel1+vowel2+vowel3+vowel4)*timepoint*following +
             ((vowel1+vowel2+vowel3+vowel4)*timepoint*following|participant) + (timepoint|word))
tabulate.formula(form)
tabulate.formula(form,group='vowel[1-4]')



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
