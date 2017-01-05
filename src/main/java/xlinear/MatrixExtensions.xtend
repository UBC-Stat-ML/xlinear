package xlinear

import xlinear.internals.JavaUtils

class MatrixExtensions {
  
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
  
  def static DenseMatrix denseCopy(Matrix matrix) {
    val DenseMatrix result = MatrixOperations::dense(matrix.nRows, matrix.nCols)
    result += matrix
    return result
  }
  
  def static SparseMatrix sparseCopy(Matrix matrix) {
    val SparseMatrix result = MatrixOperations::sparse(matrix.nRows, matrix.nCols)
    result += matrix
    return result
  }
  
  
  //// Norms, etc
  
  def static double sum(Matrix m) {
    m.nonZeroEntries().sum()
  }
  
  
  def static double norm(Matrix m) {
    val double sumOfSqrs = m.nonZeroEntries().map[double value | value * value].sum()
    return Math.sqrt(sumOfSqrs)
  }
  
    
  //// Conversion into other representations
  
  def static double[][] toArray(Matrix m) {
    return JavaUtils::toArray(m)
  }
  
  def static double[] vectorToArray(Matrix m) {
    return JavaUtils::vectorToArray(m);
  }
  
  
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

  
  //// Dot product 
  
  def static double dot(Matrix vector1, Matrix vector2) {
    // TODO: make more efficient; transpose copies stuff as of now
         if (isColumnVector(vector1) && isColumnVector(vector2)) return (vector1.transpose() * vector2).doubleValue
    else if (isRowVector   (vector1) && isRowVector   (vector2)) return (vector1 * vector2.transpose()).doubleValue
    else throw new IllegalArgumentException("Dot product should be one two row vectors (or two column vectors). Use * for standard matrix multiplication.")
  }
  
  
  //// Cast 1x1 to scalar
  
  def static double doubleValue(Matrix m) {
    if (m.nRows() > 1 || m.nCols() > 1) {
      throw StaticUtils::notAScalarException
    }
    return m.get(0,0)
  }


  //// Dimensionality shortcuts
  
  def static boolean isColumnVector(Matrix m) {
    m.nCols == 1 
  }
  
  def static boolean isRowVector(Matrix m) {
    m.nRows == 1
  }
  
  
  
  private new() {}
}