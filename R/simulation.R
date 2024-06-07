#' Generate data and run simulation
#'
#' @param parameters get from get_parameters function, or we can also input anything we want
#' @param n number of instruments, p_z
#'
#' @return A list of calculated A_hat, B_hat, AB_hat, A_d_hat, B_d_hat, AB_d_hat
#' @export
simulation = function(parameters, n) {
  # library(devtools)
  # install_github("tye27/mr.divw")
  library(mr.divw)
  library(matrixStats)
  library(MASS)
  library(ggplot2)
  library(tidyverse)
  library(patchwork)

  data("bmi.cad")
  load('data/multivariate_data_medium.rda')

  # n: number of samples (pz)
  # get parameters
  py = parameters$py
  px = parameters$px
  var_Z = parameters$var_Z
  VX_tilde = parameters$VX_tilde
  Sigma_X = parameters$Sigma_X
  Sigma_Y = parameters$Sigma_Y
  weight.matrix = parameters$weight.matrix
  SigmaXX = parameters$SigmaXX
  SigmaYX = parameters$SigmaYX
  SigmaXY = parameters$SigmaXY
  AB = parameters$AB
  VY_tilde = parameters$VY_tilde

  # sample true effect gamma_j_star and Gamma_j_star
  gamma_j_star = mvrnorm(n = n, mu = rep(0, px), Sigma = VX_tilde)
  Gamma_j_star = gamma_j_star %*% t(AB)

  # sample x_j, y_j
  x_j = matrix(0, n, px)
  y_j = matrix(0, n, py)
  for (j in 1:n) {
    x_j[j,] = mvrnorm(n = 1, mu = gamma_j_star[j,], Sigma = Sigma_X)
    y_j[j,] = mvrnorm(n = 1, mu = Gamma_j_star[j,], Sigma = Sigma_Y)
  }

  # compute A_hat, B_hat
  result <- RRR(y_j, x_j, r=3, weight.matrix)
  A_hat = result$A
  B_hat = result$B
  AB_hat = result$AB

  # need to subtract the Sigma_xx by Sigma_x. Sigma_x can be estimated by the regression of exp ~ z (have been approximate in the get parameter function)
  # TODO: now we are using true Sigma_X to debias. should we use Sigma_X_hat?
  result_d <- debiased_RRR(y_j, x_j, r=3, sqrt_Gamma = weight.matrix, Sigma_X = Sigma_X)
  A_d_hat = result_d$A
  B_d_hat = result_d$B
  AB_d_hat = result_d$AB

  return(list(A_hat, B_hat, AB_hat, A_d_hat, B_d_hat, AB_d_hat))
}
