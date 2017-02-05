package xlinear

import xlinear.DenseMatrix
import xlinear.SparseMatrix
import xlinear.StaticUtils
import java.util.Random
import org.jblas.DoubleMatrix

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
  
  def static DenseMatrix ones(int rows, int cols) {
    val DenseMatrix result = dense(rows, cols)
    result.editInPlace[1.0]
    return result
  }
  
  def static DenseMatrix ones(int size) {
    ones(size, 1)
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
  
  def static DenseMatrix denseCopy(DoubleMatrix jblasMatrix) {
    val DenseMatrix result = dense(jblasMatrix.rows, jblasMatrix.columns);
    result.editInPlace[int row, int col, double zero |
      jblasMatrix.get(row, col)      
    ]
    return result
  }

  def static SparseMatrix sparseCopy(double[][] data) {
    StaticUtils::createSparseMatrixByCopyingArrayContents(data)
  }
  
  def static SparseMatrix sparseCopy(double[] data) {
    StaticUtils::createSparseMatrixByCopyingArrayContents(data)
  }
  
  
  //// random vectors
  
  def static DenseMatrix standardNormalVector(Random random, int dim) {
    val DenseMatrix result = dense(dim)
    for (var int i = 0; i < dim; i++) {
      result.set(i, random.nextGaussian)
    }
    return result
  }
  
  private new() {}
}