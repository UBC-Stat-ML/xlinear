package xlinear

import org.apache.commons.math3.linear.LUDecomposition
import org.apache.commons.math3.linear.OpenMapRealMatrix
import org.apache.commons.math3.linear.RealMatrix
import cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D
import cern.jet.math.tdouble.DoublePlusMultSecond
import org.apache.commons.math3.linear.RealMatrixPreservingVisitor
import org.apache.commons.math3.linear.BlockRealMatrix
import cern.colt.function.tdouble.IntIntDoubleFunction
import cern.colt.function.tdouble.LongDoubleProcedure
import org.apache.commons.math3.linear.RealMatrixChangingVisitor

class MatrixOperations {
  
  
  //// Matrix addition
  
  def dispatch static DenseMatrix +(DenseMatrix m1, DenseMatrix m2) {
    // In the case of a BlockRealMatrix type for m1.impl and m2.impl, BlockRealMatrix.add does 
    // attempt a typecast on m2.impl to BlockRealMatrix to get the higher efficiency
    adapt(m1.implementation.add(m2.implementation))
  }
  
  static val coltAdditionFunction = DoublePlusMultSecond.plusMult(1.0)
  def dispatch static SparseMatrix +(SparseMatrix m1, SparseMatrix m2) {
    val SparseDoubleMatrix2D m1Copy = m1.implementation.copy as SparseDoubleMatrix2D
    m1Copy.assign(m2.implementation, coltAdditionFunction)
    adapt(m1Copy)
  }
  
  /*
   * Design note: Adding a sparse matrix to a dense matrix results in a dense matrix.
   * SparseMatrix's implementation is inefficient when the matrix is in 
   * fact dense, so we return a DenseMatrix.
   */
  def dispatch static DenseMatrix +(SparseMatrix m1, DenseMatrix m2) {
    val m2Copy = m2.implementation.copy
    m1.implementation.forEachNonZero[int row, int col, double value |
      m2Copy.addToEntry(row, col, value)
      value
    ]
    adapt(m2Copy)    
//    val SparseDoubleMatrix2D m1Copy = m1.implementation.copy as SparseDoubleMatrix2D
//    m2.implementation.walkInOptimizedOrder(new RealMatrixPreservingVisitor() {
//      override end() { 0.0 }
//      override start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
//      override visit(int row, int column, double value) {
//        if (value != 0.0)
//          m1Copy.set(row, column, value + m1Copy.get(row, column))
//      }
//    })
//    adapt(m1Copy)
  }
  
  def dispatch static Matrix +(DenseMatrix m1, SparseMatrix m2) {
    operator_plus(m2, m1)
  }
  
  def dispatch static Matrix +(Matrix m1, Matrix m2) {
    throw notImplemented("+", m1, m2)
  }
  
  
//  //// Matrix subtraction 
//  
//  def static DenseMatrix -(DenseMatrix m1, DenseMatrix m2) {
//    // TODO: handle sparsity; warning: rules are laxer than with addition (Dense + Sparse => can do sparse with the right order)
//    matrix(m1.implementation.subtract(m2.implementation))
//  }
//  
//  def static SparseMatrix -(SparseMatrix m1, SparseMatrix m2) {
//    // TODO: handle sparsity
//    matrix(m1.implementation.subtract(m2.implementation))
//  }
//  
//  
//  //// Matrix multiplication
//  
//  def static DenseMatrix *(DenseMatrix m1, DenseMatrix m2) {
//    // TODO: handle sparsity
//    matrix(m1.implementation.multiply(m2.implementation))
//  }
//  
//  def static SparseMatrix *(SparseMatrix m1, DenseMatrix m2) {
//    matrix(m1.implementation.multiply(m2.implementation) as OpenMapRealMatrix)
//  }
//  
//  def static SparseMatrix *(DenseMatrix m1, SparseMatrix m2) {
//    // we want m2's implementation, and preMultiply takes care of 
//    // applying * in the right order as it is non-commutative
//    matrix(m2.implementation.preMultiply(m1.implementation) as OpenMapRealMatrix)
//  }
//  
//  def static SparseMatrix *(SparseMatrix m1, SparseMatrix m2) {
//    matrix(m1.implementation.multiply(m2.implementation))
//  }
//  
//  
//  //// Matrix times a scalar
//  
//  def static DenseMatrix *(DenseMatrix m, Number scalar) {
//    matrix(m.implementation.scalarMultiply(scalar.doubleValue))
//  }
//  
//  def static DenseMatrix *(Number scalar, DenseMatrix m) {
//    MatrixOperations::operator_multiply(m, scalar)
//  }
  
  
  //// Dense matrix creation
  
//  def static DenseMatrix matrix(double [][] data) {
//    // TODO: check dim > 0, and equal across (if not checked already in BlockRealMatrix)
//    // TODO: if data is big, use JBLAS?
//    matrix(new BlockRealMatrix(data))
//  }


  //// Norms
  
  /**
   * L2 norm of a vector or matrix (in which case it is also known 
   * as the Frobenius norm).
   */
  def dispatch static double norm(DenseMatrix m) {
    m.implementation.frobeniusNorm
  } 
   
  def dispatch static double norm(SparseMatrix m) {
    val double [] sum = newDoubleArrayOfSize(1)
    m.implementation.elements.forEachPair[long key, double value |
      sum.set(0, sum.get(0) + value * value)
      true
    ]
    Math.sqrt(sum.get(0))
  }
  
  def dispatch static double norm(Matrix m) {
    throw notImplemented("norm", m)
  }

  
  //// Matrix creation
  
  def static Matrix zeros(int nRows, int nCols, boolean sparse) {
    if (sparse)
      sparse(nRows, nCols)
    else
      zeros(nRows, nCols)
  }
  
  def static DenseMatrix zeros(int nRows, int nCols) {
    adapt(new BlockRealMatrix(nRows, nCols))
  }
  
  def static DenseMatrix dense(int nRows, int nCols) {
    zeros(nRows, nCols)
  }
  
  def static SparseMatrix sparse(int nRows, int nCols) {
    adapt(new SparseDoubleMatrix2D(nRows, nCols))
  }
  

  //// Matrix creation by copying another one
  
  def static DenseMatrix denseCopy(Matrix matrix) {
    val result = dense(matrix.nRows, matrix.nCols)
    result.implementation.walkInOptimizedOrder(new RealMatrixChangingVisitor() {
      override end() { 0.0 }
      override start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
      override visit(int row, int column, double value) {
        matrix.get(row, column)
      }
    })
    result
  }
  
  def dispatch static SparseMatrix sparseCopy(SparseMatrix matrix) {
    val result = sparse(matrix.nRows, matrix.nCols)
    matrix.implementation.forEachNonZero[int row, int col, double value |
      result.set(row, col, value)
      value
    ]
    result
  }
  
  def dispatch static SparseMatrix sparseCopy(Matrix matrix) {
    throw notImplemented("sparseCopy", matrix)
  }

  
  //// Wrapping implementations into our types
  
  def static DenseMatrix adapt(RealMatrix impl) {
    new DenseMatrix(impl)
  }
  
  def static SparseMatrix adapt(SparseDoubleMatrix2D impl) {
    new SparseMatrix(impl)
  }
  
  
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
  
  
  //// Utilities
  
  def private static notImplemented(String opName, Matrix m1, Matrix m2) {
    new UnsupportedOperationException("Operation " + opName + " not supported on type(s) " +
      m1.class + 
      if (m2 == null)  
        "" 
      else 
        "," + m2.class)
  }
  
  def private static notImplemented(String opName, Matrix m1) {
    notImplemented(opName, m1, null)
  }
  
  private new() {}
  
}