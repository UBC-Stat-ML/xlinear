package xlinear.internals

import xlinear.SparseMatrix
import org.eclipse.xtend.lib.annotations.Data
import cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D

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
  
  override nRows() {
    return implementation.rows
  }
  
  override nCols() {
    return implementation.columns
  }
  
  override get(int row, int col) {
    implementation.get(row, col)
  }
  
  override set(int row, int col, double v) {
    implementation.set(row, col, v)
  }
  
}