rm(list = ls())


url <- "http://www.stern.nyu.edu/~wgreene/Text/Edition7/TableF2-2.csv"

gasoline <- read.csv(url)

fm <- log((GASEXP/GASP)/POP) ~ log(GASP) + log(INCOME) + 
  log(PNC) + log(PUC) + log(lag((GASEXP/GASP)/POP))
m <- lm(fm, data = gasoline)

xtable::xtable(summary(m), caption = NULL, digits = 6)

coeficientes <- coefficients(m)
gamma <- coeficientes[6]

g2diff <- c(0, 1/(1-gamma), 0, 0, 0, coeficientes[2]/(1-gamma)^2)
g3diff <- c(0, 0, 1/(1-gamma), 0, 0, coeficientes[3]/(1-gamma)^2)
gdiff <- as.matrix(rbind(g2diff, g3diff))


sigma_u <- summary(m)$sigma
X <- as.matrix(cbind(1, m$model[,-1]))
n <- nrow(X)

V_gn <- sigma_u^2*gdiff%*%solve(t(X)%*%X)%*%t(gdiff)
delta_std_errors <- sqrt(V_gn)

