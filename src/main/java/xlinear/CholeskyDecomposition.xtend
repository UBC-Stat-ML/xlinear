package xlinear

import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * A lower triangular matrix L such that M = L * L.transpose 
 * and utilities for solving systems of the form
 * M*x = b, or
 * M*L = b, or
 * M*L.transpose = b
 */
@Data class CholeskyDecomposition {
  
  /**
   * Read-only triangular factor.
   */
  val public Matrix L
  
  @Accessors(NONE)
  val private CholeskySolver solver 
  
  /**
   * log | determinant |
   */
  def double logDet() {
    var double sum = 0.0
    for (var int i = 0; i < L.nRows; i++) {
      sum += Math.log(Math.abs(L.get(i, i)))
    }
    // *2 because det(precision) = det(L) * det(L^T)
    return 2*sum;
  }
  
  /**
   * For given b and M, find x such that 
   * M * x = b
   */
  def DenseMatrix solve(Matrix b) {
    StaticUtils::checkMatrixMultiplicationDimensionsMatch(L, b) 
    return solver.solve(b, SolverMode.M)
  }
  
  /**
   * For given b and L, find x such that 
   * L * x = b
   */
  def DenseMatrix solveWithLCoefficients(Matrix b) {
    StaticUtils::checkMatrixMultiplicationDimensionsMatch(L, b) 
    return solver.solve(b, SolverMode.L)
  }
  
    /**
   * For given b and L, find x such that 
   * L.transpose * x = b
   */
  def DenseMatrix solveWithLtransposeCoefficients(Matrix b) {
    StaticUtils::checkMatrixMultiplicationDimensionsMatch(L, b) 
    return solver.solve(b, SolverMode.Lt)
  }
  
  static interface CholeskySolver { 
    def DenseMatrix solve(Matrix b, SolverMode mode)
  }
  
  static enum SolverMode {
    M, L, Lt
  }
}