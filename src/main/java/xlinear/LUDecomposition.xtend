package xlinear

import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * For a square matrix A, the LU decomposition is an 
 * unit lower triangular matrix L, an upper triangular matrix U, 
 * and a permutation vector piv so that A(piv,:) = L*U
 * Also contains utilities for solving systems of the form
 * M*x = b
 */
@Data class LUDecomposition {
  
  /**
   * Read-only triangular factors.
   */
  val public Matrix L
  val public Matrix U
  
  @Accessors(NONE)
  val private LUSolver solver 
  
  /**
   * log | determinant |
   */
  def double logDet() {
    var double sum = 0.0
    for (var int i = 0; i < L.nRows; i++) {
      sum += Math.log(Math.abs(L.get(i, i)))
      sum += Math.log(Math.abs(U.get(i, i)))
    }
    return sum;
  }
  
  /**
   * For given b and M, find x such that 
   * M * x = b
   */
  def DenseMatrix solve(Matrix b) {
    StaticUtils::checkMatrixMultiplicationDimensionsMatch(L, b) 
    return solver.solve(b)
  }
  
  static interface LUSolver { 
    def DenseMatrix solve(Matrix b)
  }
}