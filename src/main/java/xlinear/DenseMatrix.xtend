package xlinear

import xlinear.internals.MatrixVisitorViewOnly
import xlinear.internals.MatrixVisitorEditInPlace
import cern.colt.matrix.tdouble.impl.DenseDoubleMatrix2D

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
  
  def DenseMatrix createEmpty(int nRows, int nCols)
  override DenseMatrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl) 
  
  def DenseMatrix multiplyTo(DenseMatrix another) 
}