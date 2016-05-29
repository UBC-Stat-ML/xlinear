package xlinear.internals

import xlinear.SparseMatrix
import org.eclipse.xtend.lib.annotations.Data
import cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D
import xlinear.StaticUtils

@Data class ColtSparseMatrix implements SparseMatrix {
  
  val SparseDoubleMatrix2D implementation
  
  override void visitNonZeros(MatrixVisitorViewOnly visitor) {
    implementation.forEachNonZero[int row, int col, double value |
      visitor.visit(row, col, value)
      return value
    ]
  }
  
  override void editNonZerosInPlace(MatrixVisitorEditInPlace visitor) {
    implementation.forEachNonZero[int row, int col, double value |
      return visitor.editInPlace(row, col, value)
    ]
  }
  
  override ColtSparseMatrix createEmpty(int nRows, int nCols) {
    return new ColtSparseMatrix(new SparseDoubleMatrix2D(nRows, nCols))
  }
  
  override SparseMatrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub")
  }
  
  override ColtSparseMatrix multiplyTo(SparseMatrix another) {
    StaticUtils::checkMatrixMultiplicationDimensionsMatch(this, another)
    // TODO: if big, attempt JEigen?
    switch another {
      ColtSparseMatrix : {
        val ColtSparseMatrix result = createEmpty(nRows, another.nCols)
        implementation.zMult(another.implementation, result.implementation)
        return result
      }
      default : throw new UnsupportedOperationException("TODO: if small, use default impl; later, if big create a copy in efficient storage?")
    }
  }
  
  override int nRows() {
    return implementation.rows
  }
  
  override int nCols() {
    return implementation.columns
  }
  
  override double get(int row, int col) {
    StaticUtils::checkBounds(this, row, col)
    implementation.get(row, col)
  }
  
  override void set(int row, int col, double v) {
    StaticUtils::checkBounds(this, row, col)
    implementation.set(row, col, v)
  }
  
  override String toString() {
    // TODO: use views to truncate
    return StaticUtils::toStringDimensions(this) + " sparse matrix\n" + StaticUtils::toString(this)
  }
}