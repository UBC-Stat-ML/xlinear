package xlinear.prototype2

import org.apache.commons.math3.exception.DimensionMismatchException

//// that's what the user deals with:
  
interface Matrix { 
  
  //def T copy(int row0Incl, int row1Excl, int col0Incl, int col1Incl) // provide default implementation?
  def Matrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl) // provide default lazy implementation?
  //def T getImplementation()
  
  def int nRows()
  def int nCols()

  def double get(int row, int col)
  def void set(int row, int col, double v)
  
  // empty! all the behavior based on static extension
  
  //// below is what the implementor uses
  
  static interface DenseMatrix extends Matrix {
    /**
     * Efficient traversal of all entries. 
     * 
     * Specific order at which these entries are visited is up to 
     * the implementation.
     */
    def void visitAllEntries(MatrixEntryVisitor visitor)
    def DenseMatrix createEmpty(int nRows, int nCols)
    override DenseMatrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl)
    
    def void multiplyInPlace(DenseMatrix another)
  }
  
  static interface SparseMatrix extends Matrix {
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
  
//  @Data static abstract class DenseMatrixView<T extends DenseMatrixView<T>> implements DenseMatrix<T> {
//    
//     // These will depend on the user implementing visitAllEntries() and visitNonZeroEntries() efficiently
//    
//     // Note: do we need a different stuff for Dense and Sparse?
//    
//     val DenseMatrix<T> viewed
//     
//     val int row0Incl
//     val int row1Excl
//     val int col0Incl
//     val int col1Excl
//     
//     override T createEmpty(int nRows, int nCols) {
//       viewed.createEmpty(nRows, nCols)
//     }
//     
//     override T view(int row0Incl, int row1Excl, int col0Incl, int col1Incl) {
//       throw new UnsupportedOperationException // TODO
//     }
//     
//     override int nRows() {
//       row1Excl - row0Incl
//     }
//     
//     override int nCols() {
//       col1Excl - col0Incl
//     }
//     
//     override double get(int row, int col) {
//       throw new UnsupportedOperationException // TODO
//     }
//     
//     override set(int row, int col, double v) {
//       throw new UnsupportedOperationException // TODO
//     }
//     
//     override void multiplyInPlace(T another) {
//       throw new UnsupportedOperationException // TODO
//     }
//     
//  }
  
  //// Support (do not subclass directly)
  

  
  @FunctionalInterface
  static interface MatrixEntryVisitor {
    def double visit(int row, int col, double currentValue)
  }
  
  static class MatrixImplementationUtilities {
    
    

    
  }
  
}

