library(mvtnorm)
library(matlib)

rm(list = ls())

#### iii) ####
n <- 400
mu <- c(1,0,2)
Sigma <- matrix(c(0.8, 0.4, -0.2,
                  0.4, 1, -0.8,
                  -0.2, -0.8, 2),
                byrow = T,
                nrow = 3)
Z <- data.frame(rmvnorm(n, mu, Sigma))
names(Z) <- c("Y", "X1", "X2")

#### iv) ####

X <- data.frame(rep(1, n), Z[,-1])
names(X)[1] <- "1s"
X <- as.matrix(X)

Y <- as.matrix(Z$Y)

## a)
bhat_a <- solve(t(X)%*%X)%*%t(X)%*%Y
bhat_a
## b)

# calculemos 1/n suma x_jx_j^'
x_jx_j <- 0
for (i in 1:n) {
  x_jx_j <- x_jx_j + 1/n * as.matrix(X[i,])%*%t(as.matrix(X[i,]))
}

x_jx_j_inv <- solve(x_jx_j)

# calculamos 1/n x_jY_j
x_jY_j <- 0
for (i in 1:n) {
  x_jY_j <- x_jY_j + 1/n * as.matrix(X[i,])%*%Y[i]
}

bhat_b <- x_jx_j_inv%*%x_jY_j
bhat_a
bhat_b

## c) calculemos mu_y - cov(y,x)*var(x)^1*mu_x

bhat_c <- matrix(rep(0,3))

bhat_c[1] <- mean(Y) - t(as.matrix(var(Z)[1,-1]))%*%inv(var(Z)[-1,-1])%*%colMeans(Z)[-1]

bhat_c[-1] <- inv(var(Z)[-1,-1])%*%as.matrix(var(Z)[1,-1])

bhat_a
bhat_b
bhat_c

