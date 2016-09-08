package xlinear

import xlinear.DenseMatrix
import xlinear.SparseMatrix
import xlinear.StaticUtils
import xlinear.internals.JavaUtils

class MatrixOperations {
  
  //// Empty matrix creation
  
  def static DenseMatrix dense(int nRows, int nCols) {
    StaticUtils::createEmptyDenseMatrix(nRows, nCols)
  }
  
  def static SparseMatrix sparse(int nRows, int nCols) {
    StaticUtils::createEmptySparseMatrix(nRows, nCols)
  }
  
  
  //// Empty vector creation (n x 1)
  
  def static DenseMatrix dense(int nRows) {
    StaticUtils::createEmptyDenseMatrix(nRows, 1)
  }
  
  def static SparseMatrix sparse(int nRows) {
    StaticUtils::createEmptySparseMatrix(nRows, 1)
  }
  
  
  //// Special matrices
  
  def static SparseMatrix identity(int size) {
    StaticUtils::identity(size)
  }
  
  
  /*
   * Design note: we avoid copy(double [][] data) in a dispatch method 
   * because it then doesn't work with copy(#[#[1.2, 4.5]]) idiom (Xtend 
   * only translates #[..] to double [] if it can infer from static 
   * analysis)
   */
//  def dispatch static DenseMatrix copy(double[][] data) {
//    StaticUtils::createDenseMatrixByCopyingArrayContents(data)
//  }
  
  def static DenseMatrix denseCopy(double[][] data) {
    StaticUtils::createDenseMatrixByCopyingArrayContents(data)
  }
  
  def static DenseMatrix denseCopy(double[] data) {
    StaticUtils::createDenseMatrixByCopyingArrayContents(data)
  }

  def static SparseMatrix sparseCopy(double[][] data) {
    StaticUtils::createSparseMatrixByCopyingArrayContents(data)
  }
  
  def static SparseMatrix sparseCopy(double[] data) {
    StaticUtils::createSparseMatrixByCopyingArrayContents(data)
  }
  
  private new() {}
}