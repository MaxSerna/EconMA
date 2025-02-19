library(MASS)
library(matlib)
library(mvtnorm)
rm(list = ls())

Z <- matrix(nrow = 4, ncol = 10)
Z[,1] <- c(0.2, 2.4, -1.61, 5.7)
Z[,2] <- c(0, 3.2, -3.04, 6.4)
Z[,3] <- c(0.8, -0.8, -3.71, 7.5)
Z[,4] <- c(-1.3, 1.2, 1.64, 4)
Z[,5] <- c(-0.4, 0.6, 4.2, 2.6)
Z[,6] <- c(2.1, -2.2, 0.28, 5.4)
Z[,7] <- c(-0.8, -1.4, 1.06, 4.8)
Z[,8] <- c(1.6, 0.8, 2.1, 3.8)
Z[,9] <- c(2.2, 1, 1.36, 4.2)
Z[,10] <- c(0.6, -1.8, -1.2, 6.2)
Z <- data.frame(t(Z))
names(Z) <- c("Y", "X1", "X2", "X3")

X_transpose <- rbind(rep(1,10), t(Z[,2:4]))
X_transpose
X <- t(X_transpose)
X
matrix_XX <- X_transpose%*%X
matrix_XX
format(det(matrix_XX), scientific = F)

A <- as.matrix(X[,-1])
b <- as.matrix(X[,1])
Ag <- ginv(A)
alphas_1s <- Ag %*% b
round(b - A%*%alphas_1s, 3)

A <- as.matrix(X[,-2])
b <- as.matrix(X[,2])
Ag <- ginv(A)
alphas_X1 <- Ag %*% b
round(b - A%*%alphas_X1, 3)

A <- as.matrix(X[,-3])
b <- as.matrix(X[,3])
Ag <- ginv(A)
alphas_X2 <- Ag %*% b
round(b - A%*%alphas_X2, 3)

A <- as.matrix(X[,-4])
b <- as.matrix(X[,4])
Ag <- ginv(A)
alphas_X3 <- Ag %*% b
round(b - A%*%alphas_X3, 3)

# AtA <- t(A)%*%A
# AtaInv <- inv(AtA)
# coefs <- AtaInv%*%t(A)%*%b
# b - A%*%coefs

library(mvtnorm)
n <- 400
mu <- c(1,0,2)
Sigma <- matrix(c(0.8, 0.4, -0.2,
                  0.4, 1, -0.8,
                  -0.2, -0.8, 2),
                nrow = 3,
                byrow = T)
Z <- data.frame(rmvnorm(n, mean = mu, sigma = Sigma))
names(Z) <- c("Y", "X1", "X2")
colMeans(Z)
var(Z)


#### iii) ####

rm(list = ls())

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

bhat_c[1] <- mean(Y) - matrix(var(Y,X)[-1], nrow = 1)%*%inv(var(X)[-1,-1])%*%colMeans(X)[-1]

# calculemos var(X)^-1 * cov(y,x)
bhat_c[-1] <- inv(var(Z)[-1,-1])%*%as.matrix(var(Z)[1,-1])

bhat_a
bhat_b
bhat_c

beta <- data.frame(bhat_a, bhat_b, bhat_c)
rownames(beta) <- c("Bo", "B1", "B2")
beta

#### v) ####


## a)

sigma_u_hat_a <- 0
for (i in 1:n) {
  sigma_u_hat_a <- sigma_u_hat_a + 1/n*(Y[i] - t(bhat_a)%*%matrix(X[i,]))^2
}

## b)

# para errores de cálculo, generemos manualmente var(Y) y cov(Y,X)
sigma_Y <- 0
for (i in 1:n) {
  sigma_Y <- sigma_Y + 1/n*(Y[i] - mean(Y))^2
}

sigma_YX <- matrix(rep(0, 2), nrow = 1)
for (i in 1:n) {
  sigma_YX <- sigma_YX + 1/n*(Y[i] - mean(Y))*t(matrix(X[i,-1]) - matrix(colMeans(X[,-1])))
}

sigma_u_hat_b <- sigma_Y - sigma_YX%*%solve(var(X)[-1,-1])%*%t(matrix(var(Y,X)[-1], nrow = 1))

sigma_u_hat_a
sigma_u_hat_b
