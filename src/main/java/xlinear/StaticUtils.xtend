package xlinear

import xlinear.SparseMatrix
import org.apache.commons.math3.exception.DimensionMismatchException
import xlinear.internals.CommonsDenseMatrix
import org.apache.commons.math3.linear.BlockRealMatrix
import xlinear.internals.ColtSparseMatrix
import cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D
import java.util.Locale
import xlinear.internals.MatrixVisitorViewOnly
import xlinear.internals.TablePrettyPrinter
import org.apache.commons.math3.exception.NotStrictlyPositiveException
import org.apache.commons.math3.exception.OutOfRangeException
import org.apache.commons.math3.exception.util.LocalizedFormats

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
  
  //// copy, etc
  
  static def DenseMatrix createDenseMatrixByCopyingArrayContents(double [][] data) {
    return new CommonsDenseMatrix(new BlockRealMatrix(data))
  }
  
  static def SparseMatrix createSparseMatrixByCopyingArrayContents(double [][] data) {
    val int nRows = data.length
    val int nCols = data.get(0).length
    if (nRows < 1) throw new NotStrictlyPositiveException(nRows);
    if (nCols < 1) throw new NotStrictlyPositiveException(nCols);
    val SparseMatrix result = createEmptySparseMatrix(nRows, nCols)
    for (var int row = 0; row < nRows; row++) {
      val double[] rowArray = data.get(row)
      if (rowArray.length != nCols)
        throw new DimensionMismatchException(data.get(row).length, nCols)
      for (var int col = 0; col < nCols; col++) {
        val current = rowArray.get(col)
        if (current != 0.0)
          result.set(row, col, current)
      }
    }  
    return result
  }
  
  static def DenseMatrix createDenseMatrixByCopyingArrayContents(double [] data) {
    val DenseMatrix result = createEmptyDenseMatrix(data.length, 1);
    copyTo(data, result)
    return result
  }
  
  static def SparseMatrix createSparseMatrixByCopyingArrayContents(double [] data) {
    val SparseMatrix result = createEmptySparseMatrix(data.length, 1);
    copyTo(data, result)
    return result
  }
  
  def static private void copyTo(double [] src, Matrix destination) {
    if (src.length != destination.nRows || destination.nCols != 1)
      throw new RuntimeException
    for (var int r = 0; r < src.length; r++)
      destination.set(r, 0, src.get(r))
  }
  
  static def DenseMatrix createEmptyDenseMatrix(int nRows, int nCols) {
    return new CommonsDenseMatrix(new BlockRealMatrix(nRows, nCols))
  }
  
  static def SparseMatrix createEmptySparseMatrix(int nRows, int nCols) {
    return new ColtSparseMatrix(new SparseDoubleMatrix2D(nRows, nCols))
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
  
  def static ColtSparseMatrix convertToColtSparseMatrix(SparseMatrix model) {
    val ColtSparseMatrix result = new ColtSparseMatrix(new SparseDoubleMatrix2D(model.nRows, model.nCols))
    model.visitNonZeros[int row, int col, double currentValue |
      result.set(row, col, currentValue)
    ]
    return result
  }
  
  def static CommonsDenseMatrix convertToCommonsDenseMatrix(DenseMatrix model) {
    val CommonsDenseMatrix result = new CommonsDenseMatrix(new BlockRealMatrix(model.nRows, model.nCols))
    result.editInPlace[int row, int col, double currentValue |
      return model.get(row, col)
    ]
    return result
  }
  
  
  //// Special matrices
  
  static def SparseMatrix identity(int size) {
    // TODO: create an implicit object?
    val SparseMatrix result = createEmptySparseMatrix(size, size)
    for (var int i = 0; i < size; i++)
      result.set(i, i, 1.0)
    return result
  }
  
  
  //// toString
  
  /**
   * Human-readable multi-line tabulated string for the provided matrix.
   * Since numbers are rounded and the method is not designed for efficiency, 
   * do not use to record matrices to file.
   */
  static def String toString(Matrix matrix) {
    val printer = new TablePrettyPrinter
    for (var int row = 0; row < matrix.nRows; row++)
      printer.set(1 + row, 0, "" + row + " | ")
    for (var int col = 0; col < matrix.nCols; col++) {
      printer.set(0, 1 + 2*col, "" + col)
      printer.makeJustificationToLeft(1 + 2*col + 1)
    }
    forceVisitAllEntries(matrix)[int row, int col, double value |
      val String str = String.format(Locale.US, "%G", value)
      val int dotLocation = str.indexOf('.')
      val prefix = if (dotLocation == -1) str else str.subSequence(0, dotLocation)
      val suffix = if (dotLocation == -1) ""  else str.subSequence(dotLocation, str.length)
      printer.set(1 + row, 1 + 2*col + 0, "  " + prefix.toString)
      printer.set(1 + row, 1 + 2*col + 1, suffix.toString)
    ]
    printer.toString("")
  }
  
  static def String toStringDimensions(Matrix matrix) {
    return "" + matrix.nRows + " x " + matrix.nCols
  }
  
  //// Utilities to iterate over matrices
  
  /**
   * Iterate over entries of the matrix, where zeros may or may not be skipped 
   * depending on the runtime type of the matrix (sparse vs dense)
   */
  static def void visitSkippingSomeZeros(Matrix matrix, MatrixVisitorViewOnly visitor) {
    switch matrix {
      SparseMatrix : matrix.visitNonZeros(visitor)
      DenseMatrix  : matrix.visit(visitor)
      default      : throw denseOrSparseException
    }
  }
  
  /**
   * Note: this is inefficient for sparse matrices. Used in cases where this would not 
   * be a bottleneck e.g. in toString
   */
  static def void forceVisitAllEntries(Matrix matrix, MatrixVisitorViewOnly visitor) {
    switch matrix {
      DenseMatrix  : matrix.visit(visitor)
      SparseMatrix : {
        for (var int r = 0; r < matrix.nRows; r++)
          for (var int c = 0; c < matrix.nCols; c++)
            visitor.visit(r, c, matrix.get(r, c))
      }
      default:
        throw denseOrSparseException
    }
  }
  
  //// Below are support methods for +,-,*
  
  static def DenseMatrix multiply(SparseMatrix sparse, DenseMatrix dense) {
    checkMatrixMultiplicationDimensionsMatch(sparse, dense)
    val DenseMatrix result = dense.createEmpty(sparse.nRows, dense.nCols)  
    sparse.visitNonZeros[int m1Row, int sharedDim, double m1Value |
      for (var int m2Col = 0; m2Col < dense.nCols; m2Col++) {
        val m2Value = dense.get(sharedDim, m2Col)
        if (m2Value != 0.0)
          increment(result, m1Row, m2Col, m1Value * m2Value)
      }
    ]
    return result
  }
  
  static def DenseMatrix multiply(DenseMatrix dense, SparseMatrix sparse) {
    checkMatrixMultiplicationDimensionsMatch(dense, sparse)
     val DenseMatrix result = dense.createEmpty(dense.nRows, sparse.nCols)  
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
  
  static def DenseMatrix add(DenseMatrix matrix1, DenseMatrix matrix2) {
    val DenseMatrix result = copy(matrix1)
    addInPlace(result, matrix2)
    return result
  }
  
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
  
  static def void addInPlace(SparseMatrix destination, DenseMatrix source) {
    if (destination === source) 
      throw notBothSparseAndDense
    checkSizesEqual(destination, source)
    source.visit[int row, int col, double value |
      increment(destination, row, col, value)
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
  
  static def void subtractInPlace(SparseMatrix matrix1, DenseMatrix matrix2) {
    addInPlace(matrix1, scale(matrix2, -1.0))
  }

  static def void subtractInPlace(DenseMatrix matrix1, SparseMatrix matrix2) {
    addInPlace(matrix1, scale(matrix2, -1.0))
  }
  
  static def DenseMatrix subtract(DenseMatrix matrix1, DenseMatrix matrix2) {
    add(matrix1, scale(matrix2, -1.0))
  }
  
  static def SparseMatrix subtract(SparseMatrix matrix1, SparseMatrix matrix2) {
    add(matrix1, scale(matrix2, -1.0))
  }
  
  static def DenseMatrix subtract(SparseMatrix matrix1, DenseMatrix matrix2) {
    add(matrix1, scale(matrix2, -1.0))
  }
  
  static def DenseMatrix subtract(DenseMatrix matrix1, SparseMatrix matrix2) {
    add(scale(matrix2, -1.0), matrix1)
  }
  
  
  //// Utilities for exception handling
  
  def static void checkValidSlice(Matrix m, int row0Incl, int row1Excl, int col0Incl, int col1Excl) {
    if (row1Excl <= row0Incl || col1Excl <= col0Incl)
      throw new IllegalArgumentException("Slice dimensions should be positive.")
    StaticUtils::checkBounds(m, row0Incl,     col0Incl)  // TODO: encapsulate this and check everywhere 
    StaticUtils::checkBounds(m, row1Excl - 1, col1Excl - 1) // - 1 since the second pair is exclusive
  }
  
  def static void checkBounds(Matrix m, int row, int col) {
    if (row < 0 || row >= m.nRows) throw outOfRangeException(row, m.nRows - 1, true)
    if (col < 0 || col >= m.nCols) throw outOfRangeException(col, m.nCols - 1, false)
  }
  
  def static OutOfRangeException outOfRangeException(int index, int max, boolean isRow) {
    return new OutOfRangeException(
      if (isRow) LocalizedFormats.ROW_INDEX else LocalizedFormats.COLUMN_INDEX, 
      index, 0, max
    )
  }
  
  def static checkMatrixMultiplicationDimensionsMatch(Matrix matrix1, Matrix matrix2) {
    if (matrix1.nCols != matrix2.nRows)
      throw new DimensionMismatchException(matrix1.nCols, matrix2.nRows)
  }
  
  def static checkMatrixIsSquare(Matrix matrix) {
    if (matrix.nCols != matrix.nRows)
      throw notSquare
  }
  
  def private static checkSizesEqual(Matrix matrix1, Matrix matrix2) {
    if (matrix1.nRows != matrix2.nRows || 
        matrix1.nCols != matrix2.nCols)
      throw sizesNoteEqualException(matrix1, matrix2)
  }
  
  def private static DimensionMismatchException sizesNoteEqualException(Matrix matrix1, Matrix matrix2) {
    if (matrix1.nRows != matrix2.nRows)
      return dimensionMismatchException(matrix1.nRows, matrix2.nRows)
    else
      return dimensionMismatchException(matrix1.nCols, matrix2.nCols)
  }
  
  def private static DimensionMismatchException dimensionMismatchException(int d1, int d2) {
    new DimensionMismatchException(Math::max(d1, d2), Math::min(d1, d2))
  }
  
  val public  static notAVectorException = new RuntimeException("This operation is only supported on a 1 by n or n by 1 matrix.")
  val public  static notAScalarException = new RuntimeException("This operation is only supported on a 1 by 1 matrix.")
  val public  static notSymmetricPosDef = new RuntimeException("This operation is only supported on a symmetric positive definite matrix.")
  val public  static notSquare = new RuntimeException("This operation is only supported on a square matrix.")
  val package static denseOrSparseException = new RuntimeException("Either a SparseMatrix or DenseMatrix required.")
  val package static notBothSparseAndDense = new RuntimeException("A matrix should not be both a SparseMatrix and a DenseMatrix")
}