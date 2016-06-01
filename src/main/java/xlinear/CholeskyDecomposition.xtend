package xlinear

import org.eclipse.xtend.lib.annotations.Data

@Data class CholeskyDecomposition {
  
  /**
   * Read-only triangular factor.
   */
  val public Matrix L
}