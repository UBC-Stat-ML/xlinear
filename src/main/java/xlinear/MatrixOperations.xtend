package xlinear

import xlinear.DenseMatrix
import xlinear.SparseMatrix
import xlinear.StaticUtils

class MatrixOperations {
  
  //// Copy
  
  def dispatch static SparseMatrix copy(SparseMatrix model) {
    StaticUtils::copy(model)
  }
  
  def dispatch static DenseMatrix copy(DenseMatrix model) {
    StaticUtils::copy(model)
  }
  
  
//    //// Norms
//  
//  /**
//   * L2 norm of a vector or matrix (in which case it is also known 
//   * as the Frobenius norm).
//   */
//  def dispatch static double norm(DenseMatrix m) {
//    m.implementation.frobeniusNorm
//  } 
//   
//  def dispatch static double norm(SparseMatrix m) {
//    val double [] sum = newDoubleArrayOfSize(1)
//    m.implementation.elements.forEachPair[long key, double value |
//      sum.set(0, sum.get(0) + value * value)
//      true
//    ]
//    Math.sqrt(sum.get(0))
//  }
//  
//  def dispatch static double norm(Matrix m) {
//    throw notImplemented("norm", m)
//  }
//
//  
//  //// Matrix creation
//  
//  def static Matrix zeros(int nRows, int nCols, boolean sparse) {
//    if (sparse)
//      sparse(nRows, nCols)
//    else
//      zeros(nRows, nCols)
//  }
//  
//  def static DenseMatrix zeros(int nRows, int nCols) {
//    adapt(new BlockRealMatrix(nRows, nCols))
//  }
//  
//  def static DenseMatrix dense(int nRows, int nCols) {
//    zeros(nRows, nCols)
//  }
//  
//  def static SparseMatrix sparse(int nRows, int nCols) {
//    adapt(new SparseDoubleMatrix2D(nRows, nCols))
//  }
//  
//
//  //// Matrix creation by copying another one
//  
//  def static DenseMatrix denseCopy(Matrix matrix) {
//    val result = dense(matrix.nRows, matrix.nCols)
//    result.implementation.walkInOptimizedOrder(new RealMatrixChangingVisitor() {
//      override end() { 0.0 }
//      override start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
//      override visit(int row, int column, double value) {
//        matrix.get(row, column)
//      }
//    })
//    result
//  }
//  
//  def dispatch static SparseMatrix sparseCopy(SparseMatrix matrix) {
//    val result = sparse(matrix.nRows, matrix.nCols)
//    matrix.implementation.forEachNonZero[int row, int col, double value |
//      result.set(row, col, value)
//      value
//    ]
//    result
//  }
//  
//  def dispatch static SparseMatrix sparseCopy(Matrix matrix) {
//    throw notImplemented("sparseCopy", matrix)
//  }
//
//  
//  //// Wrapping implementations into our types
//  
//  def static DenseMatrix adapt(RealMatrix impl) {
//    new DenseMatrix(impl)
//  }
//  
//  def static SparseMatrix adapt(SparseDoubleMatrix2D impl) {
//    new SparseMatrix(impl)
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
  
  
  //////// Rest of the file defines +, -, * 
  
    // TODO: missing matrix multiplication!
  
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