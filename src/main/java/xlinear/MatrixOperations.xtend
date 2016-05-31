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
  
  def dispatch static SparseMatrix copy(SparseMatrix model) {
    StaticUtils::copy(model)
  }
  
  def dispatch static DenseMatrix copy(DenseMatrix model) {
    StaticUtils::copy(model)
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
  
  //// Matrix multiplication
  
  def dispatch static DenseMatrix *(DenseMatrix matrix1, DenseMatrix matrix2) {
    matrix1.multiplyTo(matrix2)
  }
  
  def dispatch static SparseMatrix *(SparseMatrix matrix1, SparseMatrix matrix2) {
    matrix1.multiplyTo(matrix2)
  }
  
  def dispatch static SparseMatrix *(SparseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::multiply(matrix1, matrix2)
  }
  
  def dispatch static SparseMatrix *(DenseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::multiply(matrix1, matrix2)
  }

  @Deprecated
  def static dispatch void *=(Matrix m1, Matrix m2) {
    throw new UnsupportedOperationException(
      "Matrix multiplication cannot be computed more efficiently in place. Use C = A * B; A = C;")
  }
  
  //// Matrix additions
  
  def dispatch static DenseMatrix +(DenseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::add(matrix1, matrix2)
  }
  
  def dispatch static SparseMatrix +(SparseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::add(matrix1, matrix2)
  } 
  
  /*
   * Design note: Adding a sparse matrix to a dense matrix results in a dense matrix.
   * SparseMatrix's implementation is inefficient when the matrix is in 
   * fact dense, so we return a DenseMatrix.
   */
  def dispatch static DenseMatrix +(SparseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::add(matrix1, matrix2)
  }
  
  def dispatch static DenseMatrix +(DenseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::add(matrix2, matrix1) // ! note: using commutativity of + here
  }
  
  def dispatch static void +=(DenseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::addInPlace(matrix1, matrix2)
  }
  
  def dispatch static void +=(SparseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::addInPlace(matrix1, matrix2)
  } 
  
  def dispatch static void +=(DenseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::addInPlace(matrix1, matrix2)
  }
  
  def dispatch static void +=(SparseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::addInPlace(matrix1, matrix2)
  }
  
  
  //// Matrix scaling
  
  def dispatch static DenseMatrix *(DenseMatrix m, Number scalar) {
    StaticUtils::scale(m, scalar.doubleValue)
  }
  
  def dispatch static DenseMatrix *(Number scalar, DenseMatrix m) {
    StaticUtils::scale(m, scalar.doubleValue)
  }
  
  def dispatch static SparseMatrix *(SparseMatrix m, Number scalar) {
    StaticUtils::scale(m, scalar.doubleValue)
  }
  
  def dispatch static SparseMatrix *(Number scalar, SparseMatrix m) {
    StaticUtils::scale(m, scalar.doubleValue)
  }
  
  def dispatch static void *=(DenseMatrix m, Number scalar) {
    StaticUtils::scaleInPlace(m, scalar.doubleValue)
  }
  
  def dispatch static void *=(SparseMatrix m, Number scalar) {
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
  
  def dispatch static void -=(DenseMatrix matrix1, SparseMatrix matrix2) {
    StaticUtils::subtractInPlace(matrix1, matrix2)
  }
  
  def dispatch static void -=(SparseMatrix matrix1, DenseMatrix matrix2) {
    StaticUtils::subtractInPlace(matrix1, matrix2)
  }
  
  
  //// shortcuts for Java users
  
  /**
   * Multiply either two matrices or a matrix and a scalar, equivalent to Xtend's
   * 
   * matrixOrScalar1 * matrixOrScalar2
   * 
   * This will result in a sparse matrix if at least one (or both) of the two input 
   * matrices is sparse, otherwise this will result in a dense matrix if all 
   * matrices involved are dense.
   */
  def static Matrix mult(Object matrixOrScalar1, Object matrixOrScalar2) {
    return operator_multiply(matrixOrScalar1, matrixOrScalar2)
  }
  
  /**
   * Multiply the matrix in place by a scalar, equivalent to Xtend's
   * 
   * matrix *= scalar
   * 
   * Sparsity will be preserved.
   * 
   * Note that matrix multiplication in place is not implemented since efficient 
   * matrix routines typically need to write in a fresh matrix.
   * 
   */
  def static void multEquals(Matrix matrix, Number scalar) {
    operator_multiplyAssign(matrix, scalar)
  }
  
  /**
   * Add two matrices, equivalent to Xtend's
   * 
   * matrix1 + matrix2
   * 
   * This will result in a dense matrix if at least one (or both) of the input 
   * matrices is dense, otherwise this will result in a sparse matrix if the two 
   * matrices are sparse.
   */
  def static Matrix add(Matrix matrix1, Matrix matrix2) {
    return operator_plus(matrix1, matrix2)
  }
  
  /**
   * Add in place matrix2 into matrix1, equivalent to Xtend's
   * 
   * matrix1 += matrix2
   * 
   * The type (dense/sparse) of matrix1 is forced to stay the same.
   */
  def static void addEquals(Matrix matrix1, Matrix matrix2 ) {
    operator_add(matrix1, matrix2)
  }
  
  /**
   * Subtract two matrices, equivalent to Xtend's
   * 
   * matrix1 - matrix2
   * 
   * This will result in a dense matrix if at least one (or both) of the input 
   * matrices is dense, otherwise this will result in a sparse matrix if the two 
   * matrices are sparse.
   */
  def static Matrix sub(Matrix matrix1, Matrix matrix2) {
    return operator_minus(matrix1, matrix2)
  }
  
  /**
   * Subtract in place matrix2 from matrix1, equivalent to Xtend's
   * 
   * matrix1 -= matrix2
   * 
   * The type (dense/sparse) of matrix1 is forced to stay the same.
   */
  def static void subEquals(Matrix matrix1, Matrix matrix2) {
    operator_remove(matrix1, matrix2)
  }
  
  private new() {}
}