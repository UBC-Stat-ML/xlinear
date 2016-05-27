package xlinear

interface DenseMatrix extends Matrix {
    
  // note: impl should eventually include Symmetric, etc
  
  /**
   * Efficient traversal of all entries. 
   * 
   * Specific order at which these entries are visited is up to 
   * the implementation.
   */
  def void visitAllEntries(MatrixEntryVisitor visitor)
  def DenseMatrix createEmpty(int nRows, int nCols)
  override DenseMatrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl)
  
  // Note: DenseMatrix can be easily made into the specialized type of interest at a 
  // cost negligible compared to matrix mult
  def void multiplyInPlace(DenseMatrix another)
  
  // mixed sparse-dense still need to be manually created though

}