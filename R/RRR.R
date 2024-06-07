#' This is the function to get naive reduced rank regression estimator for
#' the causal effect (Under random effect setting in MR)
#'
#' @param Y Y in Y = CX + error
#' @param X X in Y = CX + error
#' @param r the specified reduced rank r
#' @param sqrt_Gamma Any weight matrix
#' @param sqrt_Gamma_inv Inverse of weight matrix
#'
#' @return A list of the estimated A, B and AB
#' @export
RRR = function(Y, X, r, sqrt_Gamma = NULL, sqrt_Gamma_inv = NULL) {

  XtY = crossprod(X, Y)
  XtX_inv = solve(crossprod(X))

  if (is.null(sqrt_Gamma)) {
    sqrt_Gamma = diag(1, ncol(Y), ncol(Y))
    sqrt_Gamma_inv = sqrt_Gamma
  }

  V = sqrt_Gamma %*% t(XtY) %*% XtX_inv %*% XtY %*% sqrt_Gamma / nrow(Y)
  V = eigen(V)$vec[, 1:r, drop = FALSE]

  if (is.null(sqrt_Gamma_inv)) sqrt_Gamma_inv = solve(sqrt_Gamma)

  A = sqrt_Gamma_inv %*% V
  B = crossprod(V, sqrt_Gamma %*% t(XtY) %*% XtX_inv)

  return(list(A = A, B = B, AB = A %*% B))

}
