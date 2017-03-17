package xlinear

import org.eclipse.xtend.lib.annotations.Data

@Data class CholeskyDecomposition {
  
  /**
   * Read-only triangular factor.
   */
  val public Matrix L
  
  val public Solver solver
  
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
  
  public static interface Solver {
    def DenseMatrix solve(Matrix b)
  }
}