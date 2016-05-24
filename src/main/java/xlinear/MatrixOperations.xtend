package xlinear

import org.apache.commons.math3.linear.BlockRealMatrix
import org.apache.commons.math3.linear.LUDecomposition
import org.apache.commons.math3.linear.OpenMapRealMatrix
import org.apache.commons.math3.linear.RealMatrix

class MatrixOperations {
  
  
  //// Matrix addition
  
  def static dispatch Matrix +(Matrix m1, Matrix m2) {
    throw new UnsupportedOperationException
  }
  
  def static dispatch Matrix +(DenseMatrix m1, DenseMatrix m2) {
    // TODO: handle sparsity - need to do runtime check and type cast on m2 to make sure 
    matrix(m1.implementation.add(m2.implementation))
  }
  
  def static dispatch Matrix +(SparseMatrix m1, SparseMatrix m2) {
    matrix(m1.implementation.add(m2.implementation))
  }
  
  
  //// Matrix subtraction 
  
  def static dispatch Matrix -(Matrix m1, Matrix m2) {
    throw new UnsupportedOperationException
  }
  
  def static dispatch Matrix -(DenseMatrix m1, DenseMatrix m2) {
    // TODO: handle sparsity; warning: rules are laxer than with addition (Dense + Sparse => can do sparse with the right order)
    matrix(m1.implementation.subtract(m2.implementation))
  }
  
    def static dispatch Matrix -(SparseMatrix m1, SparseMatrix m2) {
    // TODO: handle sparsity
    matrix(m1.implementation.subtract(m2.implementation))
  }
  
  
  //// Matrix multiplication
  
  def static dispatch Matrix *(Matrix m1, Matrix m2) {
    throw new UnsupportedOperationException
  }
  
  def static dispatch Matrix *(DenseMatrix m1, DenseMatrix m2) {
    // TODO: handle sparsity
    matrix(m1.implementation.multiply(m2.implementation))
  }
  
  
  //// Matrix times a scalar
  
  def static dispatch Matrix *(DenseMatrix m, Number scalar) {
    matrix(m.implementation.scalarMultiply(scalar.doubleValue))
  }
  
  def static dispatch Matrix *(Number scalar, DenseMatrix m) {
    MatrixOperations::operator_multiply(m, scalar)
  }
  
  
  
  
  //// Dense matrix creation
  
  def static Matrix matrix(double [][] data) {
    // TODO: check dim > 0, and equal across (if not checked already in BlockRealMatrix)
    // TODO: if data is big, use JBLAS?
    matrix(new BlockRealMatrix(data))
  }
  
  def static dispatch Matrix matrix(OpenMapRealMatrix sparseMatrix) {
    new SparseMatrix(sparseMatrix)
  }
  
  def static dispatch Matrix matrix(RealMatrix matrix) {
    new DenseMatrix(matrix)
  }
  
  def static dispatch Matrix sparse(int nRows, int nCols) {
    matrix(new OpenMapRealMatrix(nRows, nCols))
  }
  
  //// Matrix inversion
  
  // NB: do not put in interface since e.g. this would not make sense for non-square matrices
  def static dispatch Matrix inv(Matrix m) {
    throw new UnsupportedOperationException
  }
  
  def static dispatch Matrix inv(DenseMatrix m) {
    matrix(new LUDecomposition(m.implementation).getSolver().getInverse())
  }
  
  
  //// Dimensionality shortcuts
  
  def static boolean isColumnVector(Matrix m) {
    m.nCols == 1 
  }
  
  def static boolean isRowVector(Matrix m) {
    m.nRows == 1
  }
  
  
  //// Dot product 
  
  def static dispatch double dot(Matrix vector1, Matrix vector2) {
    throw new UnsupportedOperationException
  } 
  
  def static dispatch double dot(DenseMatrix vector1, DenseMatrix vector2) {
    var sum = 0.0
         if (isColumnVector(vector1) && isColumnVector(vector2) && vector1.nRows == vector2.nRows) for (var i = 0; i < vector1.nRows; i++) sum += vector1.implementation.getEntry(i, 0) * vector2.implementation.getEntry(i, 0)
    else if (isRowVector   (vector1) && isRowVector   (vector2) && vector1.nCols == vector2.nCols) for (var i = 0; i < vector1.nCols; i++) sum += vector1.implementation.getEntry(0, i) * vector2.implementation.getEntry(0, i)
    else throw new RuntimeException() // TODO: better exception
    return sum 
  }
  
  private new() {}
  
}