# Load required libraries
library(ggplot2)
library(RColorBrewer)  # For distinct color palettes
library(dplyr)
library(ggdark)
library(ggthemes)

# Clear environment and close plots
rm(list = ls())
if (!is.null(dev.list())) {
  dev.off()
} else {
  message("No active graphical device to turn off.")
}

estilo <- dark_theme_light()

##### 2 ####

# PMF function
pmf <- function(n) {
  x <- c()
  prob <- c()
  cdf_prob <- c()
  for (j in 0:n) {
    x[j+1] <- (2*j-n)/sqrt(n)
  }
  denominator <- (n + sqrt(n)*x)/2
  prob <- choose(n, denominator)*(1/2)^n
  data.frame(x, prob, n = paste("n = ", n))  # Add 'n' as a factor for grouping
}


# Generate a data frame for the standard normal PDF
x_vals <- seq(-3, 3, length.out = 100)
pdf_vals <- dnorm(x_vals)
pdf_data <- data.frame(x = x_vals, density = pdf_vals)

# Create a combined data frame for PMF points for n = 1 to 6
pmf_data <- do.call(rbind, lapply(1:6, pmf))  # Bind the PMF data for each n

# Create the ggplot with the standard normal PDF
ggplot(pdf_data, aes(x = x, y = density)) +
  geom_line(color = "green", size = 2, aes(linetype = "Normal estándar")) +  # Plot the standard normal PDF
  geom_line(data = pmf_data, aes(x = x, y = prob, color = n), size = 0.6) +  # Add PMF points for different n
  scale_linetype_manual(values = "solid", name = NULL) +  # Remove title for PDF legend
  scale_color_manual(values = brewer.pal(6, "Reds"), name = NULL) +  # Use 'Set1' palette for PMF lines
  ylim(0, 0.55) +  # Set y-axis limits
  labs(x = "x", y = "Densidad", title = NULL) +
  estilo +
  theme(legend.position = "bottom")  # Place legend above the plot

# Generate a data frame for the standard normal CDF
cdf_vals <- pnorm(x_vals)
cdf_data <- data.frame(x = x_vals, cdf = cdf_vals)

# Create the ggplot with the standard normal PDF
ggplot() +
  geom_line(data = cdf_data, aes(x = x, y = cdf, linetype = "Normal estándar"), 
            color = "green", size = 2, ) +
  stat_ecdf(data = pmf_data, aes(x = x, color = n), size = 0.6) +
  labs(x = "x", y = "Probabilidad acumulada", title = NULL) +
  scale_linetype_manual(values = "solid", name = NULL) +
  scale_color_manual(values = brewer.pal(6, "Reds"), name = NULL) +  # Use 'Set1' palette for PMF lines
  estilo +
  theme(legend.position = "bottom")  # Place legend above the plot

##### 3 ####

# Clear environment and close plots
rm(list = ls())

estilo <- dark_theme_light()

# PMF function

range <- 4

pmf <- function(n, lambda) {
  dx <- 0.001
  x <- subset(seq(-range, range, dx), seq(-range, range, dx) > -1/sqrt(n))
  j <- (n + sqrt(n) * x) / lambda
  prob <- (sqrt(n) / lambda) * dgamma(j, shape = n, scale = 1/lambda)
  return(data.frame(x = x, prob = prob, n = paste("n = ", n)))  # Return as a data frame
}

# Set lambda
lambda <- 1

# Compute PMF for different values of n
n_values <- c(1, 2, 3, 10, 30)
pmf_data <- bind_rows(lapply(n_values, function(n) pmf(n, lambda)))

# Generate standard normal distribution
normal_data <- data.frame(
  x = seq(-1, range, 0.1),
  prob = dnorm(seq(-1, range, 0.1)),
  n = "Normal estándar"
)

ggplot(normal_data, aes(x = x, y = prob)) +
  geom_line(color = "Green", size = 2, aes(linetype = "Normal estándar")) +  # Plot the standard normal PDF
  geom_line(data = pmf_data, aes(x = x, y = prob, color = n), size = 0.6) +  # Add PMF points for different n
  scale_linetype_manual(values = "solid", name = NULL) +  # Remove title for PDF legend
  scale_color_manual(values = brewer.pal(5, "Reds"), name = NULL) +  # Use 'Set1' palette for PMF lines
  ylim(0, 1) +  # Set y-axis limits
  labs(x = "x", y = "Densidad", title = NULL) +
  estilo +
  theme(legend.position = "bottom")  # Place legend above the plot
