#' Get the square root of a given matrix
#'
#' @param mat the input matrix
#' @param inv do we want to return the inverse of square root
#'
#' @return (inverse of the) square root of the given matrix
#' @export
sqrt_matrix = function(mat, inv = FALSE) {
  eigen_mat = eigen(mat)
  if (inv) {
    d = 1 / sqrt(eigen_mat$val)
  } else {
    d = sqrt(eigen_mat$val)
  }
  eigen_mat$vec %*% diag(d) %*% t(eigen_mat$vec)
}
