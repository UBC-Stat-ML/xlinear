package xlinear.prototype2

import xlinear.prototype2.Matrix.DenseMatrix
import xlinear.prototype2.Matrix.SparseMatrix

class MatrixOperations {
  
  //// Copy
  
  def dispatch static SparseMatrix copy(SparseMatrix model) {
    StaticUtils::copy(model)
  }
  
  def dispatch static DenseMatrix copy(DenseMatrix model) {
    StaticUtils::copy(model)
  }
  
  
  //////// Rest of the file defines +, -, * 
  
  
  //// Matrix additions
  
  def dispatch static DenseMatrix +(DenseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::add(matrix1, matrix2)
  }
  
  def dispatch static void +=(DenseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::addInPlace(matrix1, matrix2)
  }
  
  def dispatch static SparseMatrix +(SparseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::add(matrix1, matrix2)
  } 
  
  def dispatch static void +=(SparseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::addInPlace(matrix1, matrix2)
  } 
  
  /*
   * Design note: Adding a sparse matrix to a dense matrix results in a dense matrix.
   * SparseMatrix's implementation is inefficient when the matrix is in 
   * fact dense, so we return a DenseMatrix.
   */
  def dispatch static DenseMatrix +(SparseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::add(matrix1, matrix2)
  }
  
  // corresponding += in place not defined for the above design note reason
  
  def dispatch static DenseMatrix +(DenseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::add(matrix2, matrix1) // ! note: using commutativity of + here
  }
  
  def dispatch static void +=(DenseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::addInPlace(matrix1, matrix2)
  }
  
  
  //// Matrix scaling
  
  def dispatch static DenseMatrix *(DenseMatrix m, Number scalar) {
    StaticUtils::scale(m, scalar.doubleValue)
  }
  
  def dispatch static DenseMatrix *(Number scalar, DenseMatrix m) {
    StaticUtils::scale(m, scalar.doubleValue)
  }
  
  def dispatch static void *=(DenseMatrix m, Number scalar) {
    StaticUtils::scaleInPlace(m, scalar.doubleValue)
  }
  
  def dispatch static void *=(Number scalar, DenseMatrix m) {
    StaticUtils::scaleInPlace(m, scalar.doubleValue)
  }
  
  def dispatch static SparseMatrix *(SparseMatrix m, Number scalar) {
    StaticUtils::scale(m, scalar.doubleValue)
  }
  
  def dispatch static SparseMatrix *(Number scalar, SparseMatrix m) {
    StaticUtils::scale(m, scalar.doubleValue)
  }
  
  def dispatch static void *=(SparseMatrix m, Number scalar) {
    StaticUtils::scaleInPlace(m, scalar.doubleValue)
  }
  
  def dispatch static void *=(Number scalar, SparseMatrix m) {
    StaticUtils::scaleInPlace(m, scalar.doubleValue)
  }
  
  
  //// subtraction 
  
  def dispatch static DenseMatrix -(DenseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::subtract(matrix1, matrix2)
  }
  
  def dispatch static SparseMatrix -(SparseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::subtract(matrix1, matrix2)
  }
  
  def dispatch static DenseMatrix -(SparseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::subtract(matrix1, matrix2)  
  }
  
  def dispatch static DenseMatrix -(DenseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::subtract(matrix1, matrix2)
  }
  
  def dispatch static void -=(DenseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::subtractInPlace(matrix1, matrix2)
  }
  
  def dispatch static void -=(SparseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::subtractInPlace(matrix1, matrix2)
  }
  
  // -=(SparseMatrix matrix1, DenseMatrix matrix2) skipped for same reason as corresp. +=

  def dispatch static void -=(DenseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::subtractInPlace(matrix1, matrix2)
  }
  
  private new() {}
}