package xlinear

interface SparseMatrix extends Matrix {
    
  // note: impl should eventually include diag, band diag, Symmetric, etc
  
  /*
   * Design decision: for first version, use Colt instead of Math Commons sparse matrices,
   * because Math Commons has the artificial restriction that nRows * nCols has to 
   * be smaller than Integer.MAX_VALUE (no matter how sparse it is).
   * Colt can hold up to Integer.LONG_VALUE (but this is poorly documented), which 
   * should be more than enough; for more would need more than int's for rows and cols.
   */
  
  /**
   * Efficient traversal of non zero entries. 
   * 
   * Specific order at which these entries are visited is up to 
   * the implementation.
   */
  def void visitNonZeroEntries(MatrixEntryVisitor visitor)
  def SparseMatrix createEmpty(int nRows, int nCols)
  override SparseMatrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl)
  
  def void multiplyInPlace(SparseMatrix another)
  
}