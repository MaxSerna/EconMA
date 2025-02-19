rm(list = ls())

##### inciso a ####

x0 <- 0.9

phi <- function(x) {
  x - cos(x)
}

phi_prime <- function(x) {
  1 + sin(x)
}

x_n <- c()
x_n[1] <- x0
for (i in 1:100) {
  
  x_i <- x_n[i] - phi(x_n[i])/phi_prime(x_n[i])
  
  if (x_i==x_n[i]) {
    break
  }
  
  x_n[i+1] <- x_i

}

x_n


##### inciso b ####

rm(list = ls())

F_x <- function(x) {
  c(
    x[1]^2 - 2*x[1] + x[2]^2 - x[3] + 1,
    x[1]*x[2]^2 - x[1] - 3*x[2] + x[2]*x[3] + 2,
    x[1]*x[3]^2 - 3*x[3] + x[2]*x[3]^2 + x[1]*x[2]
  )
}

F_x_prime <- function(x) {
  matrix(c(
    c(2*x[1] - 2, 2*x[2], -1),
    c(x[2]^2 - 1, 2*x[1]*x[2] - 3 +x[3], x[2]),
    c(x[3]^2 + x[2], x[3]^2 + x[1], 2*x[1]*x[3] - 3 + 2*x[1]*x[2])
    ),
    nrow = 3,
    byrow = T)
}


### raíces 1

x0 <- c(1.5, 1.5, 1.5)
x_n <- matrix(ncol = 3)
x_n[1,] <- t(x0)

umbral <- 0.0000000005

for (i in 1:100) {
  
  F_x_prime_eval <- F_x_prime(x_n[i,])
  
  x_i <- x_n[i,] - solve(F_x_prime_eval)%*%F_x(x_n[i,])
  
  if (norm(t(x_i) - x_n[i,], type = "2")< umbral) {
    break
  }
  
  x_n <- rbind(x_n,t(x_i))
  
}

r1 <- x_n[nrow(x_n),]

x_n

### raíces 2

x0 <- c(0.5, 0.5, 0.5)
x_n <- matrix(ncol = 3)
x_n[1,] <- t(x0)

for (i in 1:100) {
  
  F_x_prime_eval <- F_x_prime(x_n[i,])
  
  x_i <- x_n[i,] - solve(F_x_prime_eval)%*%F_x(x_n[i,])
  
  if (norm(t(x_i) - x_n[i,], type = "2")< umbral) {
    break
  }
  
  x_n <- rbind(x_n,t(x_i))
  
}

r2 <- x_n[nrow(x_n),]



r1_pracma <- pracma::newtonsys(F_x, x0 = c(1.5,1.5,1.5))
r2_pracma <- pracma::newtonsys(F_x, x0 = c(.5,.5,.5))

r1
r1_pracma$zero

r2
r2_pracma$zero

##### 2 ####
rm(list = ls())
x <- c(2,5,2,1,2,4,7,1,2,5,3,4,5,2,4,2,1,1,3,6,1,3,2,2,1,4,4,2,4,3,4,5,3,4,1,4,3,2,5,4,5,7,3,1,8,1,4,5)
media <- mean(x)

phi <- function(x) {
  x - (1 - exp(-x))*media
}

pracma::newton(phi, x0 = 2)

##### 3 ####
rm(list = ls())
set.seed(1)

n <- 100
theta <- 1

x <- rlogis(n, location = theta, scale = 1)
phi <- function(theta) {
  
  n <- length(x)
  Sigma_xi <- 0
  
  for (i in 1:n) {
    Sigma_xi <- Sigma_xi + exp(theta - x[i]) / (1 + exp(theta - x[i]))
  }
  
  y <- Sigma_xi - n/2
  
  return(y)
  
}

phi_prime <- function(theta) {
  
  n <- length(x)
  Sigma_xi <- 0
  
  for (i in 1:n) {
    Sigma_xi <- Sigma_xi + exp(theta - x[i]) / (1 + exp(theta - x[i]))^2
  }
  
  y <- Sigma_xi
  
  return(y)
  
}

# Newton

theta_0 <- 0
theta_n <- c()
theta_n[1] <- theta_0

umbral <- 0.00000000005

for (i in 1:100) {
  
  theta_i <- theta_n[i] - phi(theta = theta_n[i])/phi_prime(theta = theta_n[i])
  
  if (abs(theta_i - theta_n[i]) < umbral) {
    break
  }
  
  theta_n[i+1] <- theta_i
  
}

iteraciones <- length(theta_n)
iteraciones

theta_MV <- theta_n[iteraciones]
theta_MV


pracma::newton(phi, x0 = 2)