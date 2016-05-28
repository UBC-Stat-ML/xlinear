package xlinear.internals

import xlinear.DenseMatrix
import org.eclipse.xtend.lib.annotations.Data
import org.apache.commons.math3.linear.BlockRealMatrix
import org.apache.commons.math3.linear.RealMatrixChangingVisitor
import cern.colt.matrix.tdouble.impl.DenseDoubleMatrix2D
import java.util.Locale
import xlinear.StaticUtils

@Data class CommonsDenseMatrix implements DenseMatrix {
  
  val BlockRealMatrix implementation
  
  // Wrap around Commons' slightly verbose interface
  override void visit(MatrixVisitorViewOnly visitor) {
    implementation.walkInOptimizedOrder(new RealMatrixChangingVisitor() {
      override end() { 0.0 }
      override start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
      override visit(int row, int column, double value) {
        visitor.visit(row, column, value)
        return value
      }
    })
  }
  
  override editInPlace(MatrixVisitorEditInPlace visitor) {
    implementation.walkInOptimizedOrder(new RealMatrixChangingVisitor() {
      override end() { 0.0 }
      override start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
      override visit(int row, int column, double value) {
        return visitor.editInPlace(row, column, value)
      }
    })
  }
  
  override CommonsDenseMatrix createEmpty(int nRows, int nCols) {
    return new CommonsDenseMatrix(new BlockRealMatrix(nRows, nCols))
  }
  
  override DenseMatrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub")
  }
  
  override CommonsDenseMatrix multiplyTo(DenseMatrix another) {
    // TODO: if big, attempt JBlas/JEigen?
    switch another {
      CommonsDenseMatrix : new CommonsDenseMatrix(this.implementation.multiply(another.implementation))
      default : throw new UnsupportedOperationException("TODO: if small, use default impl; later, if big create a copy in efficient storage?")
    }
  }
  
  override int nRows() {
    return implementation.rowDimension
  }
  
  override int nCols() {
    return implementation.columnDimension
  }
  
  override double get(int row, int col) {
    return implementation.getEntry(row, col)
  }
  
  override void set(int row, int col, double v) {
    implementation.setEntry(row, col, v)
  }
  
  override String toString() {
    // TODO: use views to truncate
    return StaticUtils::toStringDimensions(this) + " dense matrix\n" + StaticUtils::toString(this)
  }
  
}