package xlinear

import xlinear.SparseMatrix
import org.apache.commons.math3.exception.DimensionMismatchException
import xlinear.internals.CommonsDenseMatrix
import org.apache.commons.math3.linear.BlockRealMatrix

/*
 * Static utilities, which, in contrast to those in MatrixOperations, 
 * are written without dispatch methods.
 * 
 * This makes them marginally more efficient in some case compared to
 * their MatrixOperations counterparts, but the latter is much more 
 * user friendly, especially in Xtend (but also in Java).
 * 
 * For example, using the MatrixOperations implementation, one could 
 * just define the covariance of a Gaussian to be of type Matrix, and 
 * efficient operations for the sparse vs dense case will be picked at runtime.
 * In contrast, with the statically linked methods in StaticUtils, one
 * would have to have a Gaussian with SparseMatrix, and one with DenseMatrix.
 */
class StaticUtils {
  
  static def DenseMatrix createDenseMatrixByCopyingArrayContents(double [][] data) {
    return new CommonsDenseMatrix(new BlockRealMatrix(data))
  }
  
  static def DenseMatrix createEmptyDenseMatrix(int nRows, int nCols) {
    return new CommonsDenseMatrix(new BlockRealMatrix(nRows, nCols))
  }

  static def SparseMatrix copy(SparseMatrix model) {
    val SparseMatrix result = model.createEmpty(model.nRows, model.nCols)
    model.visitNonZeros[int row, int col, double currentValue |
      result.set(row, col, currentValue)
    ]
    return result
  }
  
  static def DenseMatrix copy(DenseMatrix model) {
    val DenseMatrix result = model.createEmpty(model.nRows, model.nCols)
    result.editInPlace[int row, int col, double currentValue |
      model.get(row, col)
    ]
    return result
  }
  
  static def SparseMatrix multiply(SparseMatrix sparse, DenseMatrix dense) {
    checkMatrixMultiplicationDimensionsMatch(sparse, dense)
    val SparseMatrix result = sparse.createEmpty(sparse.nRows, dense.nCols)
    sparse.visitNonZeros[int m1Row, int sharedDim, double m1Value |
      for (var int m2Col = 0; m2Col < dense.nCols; m2Col++) {
        val m2Value = dense.get(sharedDim, m2Col)
        if (m2Value != 0.0)
          increment(result, m1Row, m2Col, m1Value * m2Value)
      }
    ]
    return result
  }
  
  static def SparseMatrix multiply(DenseMatrix dense, SparseMatrix sparse) {
    checkMatrixMultiplicationDimensionsMatch(dense, sparse)
     val SparseMatrix result = sparse.createEmpty(dense.nRows, sparse.nCols)
     sparse.visitNonZeros[int sharedDim, int m2Col, double m2Value |
       for (var int m1Row = 0; m1Row < dense.nRows; m1Row++) {
         val m1Value = dense.get(m1Row, sharedDim)
         if (m1Value != 0.0)
          increment(result, m1Row, m2Col, m1Value * m2Value)
       }
     ]
     return result
  }
  
  static def void increment(Matrix m, int row, int col, double increment) {
    m.set(row, col, increment + m.get(row, col))
  }
  
  /**
   * return matrix1 + matrix2 for dense matrices
   */
  static def DenseMatrix add(DenseMatrix matrix1, DenseMatrix matrix2) {
    val DenseMatrix result = copy(matrix1)
    addInPlace(result, matrix2)
    return result
  }
  
  /**
   * destination += source for dense matrices
   */
  static def void addInPlace(DenseMatrix destination, DenseMatrix source) {
    checkSizesEqual(destination, source)
    // assume efficient iteration order matches for the two
    destination.editInPlace[int row, int col, double currentValue |
      source.get(row, col) + currentValue
    ]
  }
  
  static def SparseMatrix add(SparseMatrix matrix1, SparseMatrix matrix2) {
    val SparseMatrix result = copy(matrix1)
    addInPlace(result, matrix2)
    return result
  }
  
  /*
   * Design note: Adding a sparse matrix to a dense matrix results in a dense matrix.
   * SparseMatrix's implementation is inefficient when the matrix is in 
   * fact dense, so we return a DenseMatrix.
   */
  static def DenseMatrix add(SparseMatrix matrix2, DenseMatrix matrix1) {
    val DenseMatrix result = copy(matrix1)
    addInPlace(result, matrix2)
    return result
  }
  
  /**
   * destination += source when the source is a sparse matrix
   */
  static def void addInPlace(Matrix destination, SparseMatrix source) {
    if (destination === source) { 
      // avoid iterating over an object being modified in case this leads to weird behavior 
      // for example, set might have some routine to reclaim zeros
      // in contrast, scaleInPlace makes changes via the iterator only
      scaleInPlace(source, 2.0)
      return;
    }
    checkSizesEqual(destination, source)
    // in contrast to the the dense case, we need to iterate over the source
    source.visitNonZeros[int row, int col, double currentValue |
      destination.set(row, col, currentValue + destination.get(row, col))
    ]
  }
  
  static def void scaleInPlace(SparseMatrix matrix, double scalar) {
    if (scalar == 1.0)
      return;
    matrix.editNonZerosInPlace[int row, int col, double value |
      value * scalar
    ]
  }
  
  static def SparseMatrix scale(SparseMatrix matrix, double scalar) {
    val SparseMatrix result = copy(matrix)
    scaleInPlace(result, scalar)
    return result
  }
  
  static def void scaleInPlace(DenseMatrix matrix, double scalar) {
    if (scalar == 1.0)
      return;
    matrix.editInPlace[int row, int col, double value |
      value * scalar
    ]
  }
  
  static def DenseMatrix scale(DenseMatrix matrix, double scalar) {
    val DenseMatrix result = copy(matrix)
    scaleInPlace(result, scalar)
    return result
  }
  
  static def void subtractInPlace(DenseMatrix matrix1, DenseMatrix matrix2) {
    addInPlace(matrix1, scale(matrix2, -1.0))
  }
  
  static def void subtractInPlace(SparseMatrix matrix1, SparseMatrix matrix2) {
    addInPlace(matrix1, scale(matrix2, -1.0))
  }
  
  // subtractInPlace(SparseMatrix matrix1, DenseMatrix matrix2) omitted
  // since the resulting matrix will not be sparse

  static def void subtractInPlace(DenseMatrix matrix1, SparseMatrix matrix2) {
    addInPlace(matrix1, scale(matrix2, -1.0))
  }
  
  static def DenseMatrix subtract(DenseMatrix matrix1, DenseMatrix matrix2) {
    subtract(matrix1, scale(matrix2, -1.0))
  }
  
  static def SparseMatrix subtract(SparseMatrix matrix1, SparseMatrix matrix2) {
    subtract(matrix1, scale(matrix2, -1.0))
  }
  
  static def DenseMatrix subtract(SparseMatrix matrix1, DenseMatrix matrix2) {
    subtract(matrix1, scale(matrix2, -1.0))
  }
  
  static def DenseMatrix subtract(DenseMatrix matrix1, SparseMatrix matrix2) {
    subtract(matrix1, scale(matrix2, -1.0))
  }
  
  def static checkMatrixMultiplicationDimensionsMatch(Matrix matrix1, Matrix matrix2) {
    if (matrix1.nCols != matrix2.nRows)
      throw new DimensionMismatchException(matrix1.nCols, matrix2.nRows)
  }
  
  def static checkSizesEqual(Matrix matrix1, Matrix matrix2) {
    if (matrix1.nRows != matrix2.nRows || 
        matrix1.nCols != matrix2.nCols)
      throw sizesNoteEqualException(matrix1, matrix2)
  }
  
  def static sizesNoteEqualException(Matrix matrix1, Matrix matrix2) {
    if (matrix1.nRows != matrix2.nRows)
      new DimensionMismatchException(matrix1.nRows, matrix2.nRows)
    else
      new DimensionMismatchException(matrix1.nCols, matrix2.nCols)
  }
  
}