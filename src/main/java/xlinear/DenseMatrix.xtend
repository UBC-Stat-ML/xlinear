package xlinear

import xlinear.internals.MatrixVisitorViewOnly
import xlinear.internals.MatrixVisitorEditInPlace

interface DenseMatrix extends Matrix {
    
  // note: impl should eventually include Symmetric, etc
  
  /**
   * Efficient traversal of all entries. 
   * 
   * Specific order at which these entries are visited is up to 
   * the implementation.
   */
  def void visit(MatrixVisitorViewOnly visitor)
  def void editInPlace(MatrixVisitorEditInPlace visitor)
  
  override DenseMatrix createEmpty(int nRows, int nCols)
  
  def DenseMatrix multiplyTo(DenseMatrix another) 
  
  override DenseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean readOnly)
  override DenseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl) {
    return Matrix.super.slice(row0Incl, row1Excl, col0Incl, col1Excl) as DenseMatrix
  }
  override DenseMatrix row(int index) {
    return Matrix.super.row(index) as DenseMatrix
  }
  override DenseMatrix col(int index) {
    return Matrix.super.col(index) as DenseMatrix
  }
  override DenseMatrix readOnlyView() {
    return Matrix.super.readOnlyView() as DenseMatrix
  }
}