package xlinear

import xlinear.DenseMatrix
import xlinear.SparseMatrix
import xlinear.StaticUtils

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
  
  
  //// Creating matrices by copying
  
  def static SparseMatrix copy(SparseMatrix model) {
    StaticUtils::copy(model)
  }
  
  def static DenseMatrix copy(DenseMatrix model) {
    StaticUtils::copy(model)
  }
  
  def static Matrix copy(Matrix model) {
    switch model {
      SparseMatrix : copy(model)
      DenseMatrix  : copy(model)
      default :
        throw StaticUtils::denseOrSparseException
    }
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

  def static DenseMatrix denseCopy(Matrix matrix) {
    val DenseMatrix result = dense(matrix.nRows, matrix.nCols)
    result += matrix
    return result
  }
  
  def static SparseMatrix sparseCopy(double[][] data) {
    StaticUtils::createSparseMatrixByCopyingArrayContents(data)
  }
  
  def static SparseMatrix sparseCopy(double[] data) {
    StaticUtils::createSparseMatrixByCopyingArrayContents(data)
  }
  
  def static SparseMatrix sparseCopy(Matrix matrix) {
    val SparseMatrix result = sparse(matrix.nRows, matrix.nCols)
    result += matrix
    return result
  }
  
  
  
  
  
  //// Norms
  
//  /**
//   * L2 norm of a vector or matrix (in the matrix case it is also known 
//   * as the Frobenius norm).
//   */
//  def static double norm(Matrix m) {
//    StaticUtils::norm(m)
//  } 
   



//  //// Matrix inversion
//  
//  // NB: do not put in interface since e.g. this would not make sense for non-square matrices
//  def static DenseMatrix inv(DenseMatrix m) {
//    matrix(new LUDecomposition(m.implementation).getSolver().getInverse())
//  }
//  
//  
//  //// Dimensionality shortcuts
//  
//  def static boolean isColumnVector(Matrix m) {
//    m.nCols == 1 
//  }
//  
//  def static boolean isRowVector(Matrix m) {
//    m.nRows == 1
//  }
//  
//  
//  //// Dot product 
//  
//  def static dispatch double dot(Matrix vector1, Matrix vector2) {
//    throw new UnsupportedOperationException
//  } 
//  
//  def static dispatch double dot(DenseMatrix vector1, DenseMatrix vector2) {
//    var sum = 0.0
//         if (isColumnVector(vector1) && isColumnVector(vector2) && vector1.nRows == vector2.nRows) for (var i = 0; i < vector1.nRows; i++) sum += vector1.implementation.getEntry(i, 0) * vector2.implementation.getEntry(i, 0)
//    else if (isRowVector   (vector1) && isRowVector   (vector2) && vector1.nCols == vector2.nCols) for (var i = 0; i < vector1.nCols; i++) sum += vector1.implementation.getEntry(0, i) * vector2.implementation.getEntry(0, i)
//    else throw new RuntimeException() // TODO: better exception
//    return sum 
//  }
  
  
  //////// Rest of the file defines +, -, *, +=, -=, *= 


  
  //// Matrix scaling
  
  def static DenseMatrix *(Number scalar, DenseMatrix m) {
    m.mul(scalar)
  }
  
  def static SparseMatrix *(Number scalar, SparseMatrix m) {
    m.mul(scalar)
  }
  
  def static Matrix *(Number scalar, Matrix m) {
    m.mul(scalar)
  }

  
  private new() {}
}