package xlinear.prototype2

import xlinear.prototype2.Matrix.SparseMatrix
import xlinear.prototype2.Matrix.DenseMatrix
import org.apache.commons.math3.exception.DimensionMismatchException

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
  
  static def SparseMatrix copy(SparseMatrix model) {
    val SparseMatrix result = model.createEmpty(model.nRows, model.nCols)
    model.visitNonZeroEntries[int row, int col, double currentValue |
      result.set(row, col, currentValue)
      currentValue
    ]
    result
  }
  
  static def DenseMatrix copy(DenseMatrix model) {
    val DenseMatrix result = model.createEmpty(model.nRows, model.nCols)
    result.visitAllEntries[int row, int col, double currentValue |
      model.get(row, col)
    ]
    result
  }
  
  /**
   * return matrix1 + matrix2 for dense matrices
   */
  static def DenseMatrix add(DenseMatrix matrix1, DenseMatrix matrix2) {
    val DenseMatrix result = copy(matrix1)
    addInPlace(result, matrix2)
    result
  }
  
  /**
   * destination += source for dense matrices
   */
  static def void addInPlace(DenseMatrix destination, DenseMatrix source) {
    checkSizesEqual(destination, source)
    // assume efficient iteration order matches for the two
    destination.visitAllEntries[int row, int col, double currentValue |
      source.get(row, col) + currentValue
    ]
  }
  
  static def SparseMatrix add(SparseMatrix matrix1, SparseMatrix matrix2) {
    val SparseMatrix result = copy(matrix1)
    addInPlace(result, matrix2)
    result
  }
  
  /*
   * Design note: Adding a sparse matrix to a dense matrix results in a dense matrix.
   * SparseMatrix's implementation is inefficient when the matrix is in 
   * fact dense, so we return a DenseMatrix.
   */
  static def DenseMatrix add(SparseMatrix matrix2, DenseMatrix matrix1) {
    val DenseMatrix result = copy(matrix1)
    addInPlace(result, matrix2)
    result
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
    source.visitNonZeroEntries[int row, int col, double currentValue |
      destination.set(row, col, currentValue + destination.get(row, col))
      currentValue
    ]
  }
  
  static def void scaleInPlace(SparseMatrix matrix, double scalar) {
    if (scalar == 0.0)
      return;
    matrix.visitNonZeroEntries[int row, int col, double value |
      value * scalar
    ]
  }
  
  static def SparseMatrix scale(SparseMatrix matrix, double scalar) {
    val SparseMatrix result = copy(matrix)
    scaleInPlace(result, scalar)
    result
  }
  
  static def void scaleInPlace(DenseMatrix matrix, double scalar) {
    if (scalar == 0.0)
      return;
    matrix.visitAllEntries[int row, int col, double value |
      value * scalar
    ]
  }
  
  static def DenseMatrix scale(DenseMatrix matrix, double scalar) {
    val DenseMatrix result = copy(matrix)
    scaleInPlace(result, scalar)
    result
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