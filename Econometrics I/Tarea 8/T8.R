library(ggplot2)

##### EJ 2 ####

## Regresión

g <- function(x, lambda) {
  (1+lambda+lambda*x)/(1+lambda*x)^2
}

X <- seq(0,8, 0.01)

ggplot() +
  geom_line(aes(x = X, y = g(X, lambda = 0.01)),
            col = "red") +
  geom_line(aes(x = X, y = g(X, lambda = 0.5)),
            col = "green") +
  geom_line(aes(x = X, y = g(X, lambda = 1)),
            ) +
  labs(y= "g(X)", x = "x") +
  theme_classic()
  

## Cedasticidad

h <- function(x, lambda) {
  ((1+lambda+lambda*x)^2-2*lambda^2)/(1+lambda*x)^4
}

ggplot() +
  geom_line(aes(x = X, y = h(X, lambda = 0.01)),
            col = "red") +
  geom_line(aes(x = X, y = h(X, lambda = 0.5)),
            col = "green") +
  geom_line(aes(x = X, y = h(X, lambda = 1)),
  ) +
  labs(y= "h(X)", x = "x") +
  theme_classic()


## muestreo

rGBVE <- function(n, alpha1, alpha2, lambda) {
  x1 <- rexp(n, alpha1)
  alpha12 <- alpha1*alpha2
  pprod <- alpha12*lambda
  C <- exp(alpha1*x1)
  A <- (alpha12 - pprod + pprod*alpha1*x1)/C
  B <- (pprod*alpha2 + pprod^2*x1)/C
  D <- alpha2 + pprod*x1
  wExp <- A/D
  wGamma <- B/D^2
  data.frame(x1, x2 = rgamma(n, (runif(n) > wExp/(wExp + wGamma)) + 1, D))
}

n <- 120
lmda <- 0.5
Z <- rGBVE(n = n, alpha1 = 1, alpha2 = 1, lambda = lmda)
names(Z) <- c("X", "Y")

## gráfica

datos <- data.frame(Z, g(Z$X, lambda = lmda))
names(datos) <- c("X", "Y", "g")
ggplot(data = datos) +
  geom_point(aes(x = X, y = Y),
             size = 0.6) +
  geom_line(aes(x = X, y = g),
            col = "red") +
  theme_light()


summary(Z)
var(Z)

##### EJ 3 ####

n <- 30
medias <- c(1,2,0)
Sigma <- matrix(c(0.04, -0.03, 0, -0.03, 0.09, 0.01, 0, 0.01, 0.01), ncol = 3)
Z <- rmvnorm(n, mean = medias, sigma = Sigma)
Z <- data.frame(Z)
names(Z) <- c("X1", "X2", "V")

Y <- exp(Z$X1) - sin(Z$X2) + Z$V

g <- 10 + pi*Z$X1 + exp(1)*Z$X2
U <- Y - g
Ymodel <- g+U

cov(U, Z)
