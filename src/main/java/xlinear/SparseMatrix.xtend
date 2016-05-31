package xlinear

import xlinear.internals.MatrixVisitorViewOnly
import xlinear.internals.MatrixVisitorEditInPlace
import java.util.concurrent.locks.ReentrantReadWriteLock.ReadLock

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
   * 
   * We assume the visits are done sequentially (refactor at some 
   * point with the Stream framework to give choice in future?)
   */
  def void visitNonZeros(MatrixVisitorViewOnly visitor)
  def void editNonZerosInPlace(MatrixVisitorEditInPlace visitor)
  
  override SparseMatrix createEmpty(int nRows, int nCols)
  
  def SparseMatrix multiplyTo(SparseMatrix another)
  
  override SparseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean makeReadOnly)
  override SparseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl) {
    return Matrix.super.slice(row0Incl, row1Excl, col0Incl, col1Excl) as SparseMatrix
  }
  override SparseMatrix row(int index) {
    return Matrix.super.row(index) as SparseMatrix
  }
  override SparseMatrix col(int index) {
    return Matrix.super.col(index) as SparseMatrix
  }
  override SparseMatrix readOnlyView() {
    return Matrix.super.readOnlyView() as SparseMatrix
  }
}