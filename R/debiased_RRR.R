#' This is the function to get debiased reduced rank regression estimator for
#' the causal effect (Under random effect setting in MR)
#'
#' @param Y Y in Y = CX + error
#' @param X X in Y = CX + error
#' @param r the specified reduced rank r
#' @param Sigma_X Covariance of X conditional on true random effect
#' @param sqrt_Gamma Any weight matrix
#' @param sqrt_Gamma_inv Inverse of weight matrix
#'
#' @return A list of the estimated A, B and AB
#' @export
debiased_RRR = function(Y, X, r, Sigma_X, sqrt_Gamma = NULL, sqrt_Gamma_inv = NULL) {

  sigmaxy = crossprod(X, Y) / nrow(Y)
  debiased_Sigma_xx = crossprod(X) / nrow(Y) - Sigma_X
  debiased_Sigma_xx_inv = solve(debiased_Sigma_xx) # use the random effect variance matrix to replace Sigma_xx

  if (is.null(sqrt_Gamma)) {
    sqrt_Gamma = diag(1, ncol(Y), ncol(Y))
    sqrt_Gamma_inv = sqrt_Gamma
  }

  V = sqrt_Gamma %*% t(sigmaxy) %*% debiased_Sigma_xx_inv %*% sigmaxy %*% sqrt_Gamma
  V = eigen(V)$vec[, 1:r, drop = FALSE]

  if (is.null(sqrt_Gamma_inv)) sqrt_Gamma_inv = solve(sqrt_Gamma)

  A = sqrt_Gamma_inv %*% V
  B = crossprod(V, sqrt_Gamma %*% t(sigmaxy) %*% debiased_Sigma_xx_inv)

  return(list(A = A, B = B, AB = A %*% B))

}
