package xlinear.internals

import xlinear.DenseMatrix
import org.eclipse.xtend.lib.annotations.Data
import org.apache.commons.math3.linear.BlockRealMatrix
import org.apache.commons.math3.linear.RealMatrixChangingVisitor
import xlinear.StaticUtils
import org.apache.commons.math3.linear.RealMatrixPreservingVisitor

@Data class CommonsDenseMatrix implements DenseMatrix {
  
  val BlockRealMatrix implementation
  
  override void visit(MatrixVisitorViewOnly visitor) {
    // Wrap around Commons' verbose interface
    implementation.walkInOptimizedOrder(new RealMatrixPreservingVisitor() {
      override double end() { 0.0 }
      override void start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
      override void visit(int row, int column, double value) {
        visitor.visit(row, column, value)
      }
    })
  }
  
  override editInPlace(MatrixVisitorEditInPlace visitor) {
    implementation.walkInOptimizedOrder(new RealMatrixChangingVisitor() {
      override double end() { 0.0 }
      override void start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
      override double visit(int row, int column, double value) {
        return visitor.editInPlace(row, column, value)
      }
    })
  }
  
  override CommonsDenseMatrix multiplyTo(DenseMatrix another) {
    StaticUtils::checkMatrixMultiplicationDimensionsMatch(this, another)
    // TODO: if big, attempt JBlas/JEigen?
    switch another {
      CommonsDenseMatrix : new CommonsDenseMatrix(this.implementation.multiply(another.implementation))
      default : throw new UnsupportedOperationException("TODO: if small, use default impl; later, if big create a copy in efficient storage?")
    }
  }
  
  override CommonsDenseMatrix createEmpty(int nRows, int nCols) {
    return new CommonsDenseMatrix(new BlockRealMatrix(nRows, nCols))
  }
  
  override DenseMatrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl) {
    return new CommonsDenseMatrixView(this, row0Incl, row1Excl, col0Incl, col1Incl)
  }
  
  override int nRows() {
    return implementation.rowDimension
  }
  
  override int nCols() {
    return implementation.columnDimension
  }
  
  override double get(int row, int col) {
    // StaticUtils::checkBounds(this, row, col)  Note: not needed, already checked in impl
    return implementation.getEntry(row, col)
  }
  
  override void set(int row, int col, double v) {
    // StaticUtils::checkBounds(this, row, col)  Note: not needed, already checked in impl
    implementation.setEntry(row, col, v)
  }
  
  override String toString() {
    // TODO: use views to truncate (ALSO IN VIEW AND SPARSE AND DENSE)
    return StaticUtils::toStringDimensions(this) + " dense matrix\n" + StaticUtils::toString(this)
  }
  
  private static class CommonsDenseMatrixView extends MatrixView implements DenseMatrix {
    
    def private CommonsDenseMatrix root() {
      return rootMatrix as CommonsDenseMatrix
    }
    
    new(CommonsDenseMatrix rootMatrix, int row0Incl, int row1Excl, int col0Incl, int col1Excl) {
      super(rootMatrix, row0Incl, row1Excl, col0Incl, col1Excl)
    }
    
    override visit(MatrixVisitorViewOnly visitor) {
      // Warning: code similar to editInPlace
      root().implementation.walkInOptimizedOrder(new RealMatrixPreservingVisitor() {
        override double end() { 0.0 }
        override void start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
        override void visit(int row, int col, double value) {
          visitor.visit(
            translateRowRoot2View(row), 
            translateColRoot2View(col), value
          )
        }
      }, row0Incl, row1Excl - 1, // NB: Commons API uses inclusive end point for some reason
         col0Incl, col1Excl - 1);
    }
    
    override editInPlace(MatrixVisitorEditInPlace visitor) {
      // Warning: code similar to editInPlace
      root().implementation.walkInOptimizedOrder(new RealMatrixChangingVisitor() {
        override double end() { 0.0 }
        override void start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
        override double visit(int row, int col, double value) {
          return visitor.editInPlace(
            translateRowRoot2View(row), 
            translateColRoot2View(col), value
          )
        }
      }, row0Incl, row1Excl - 1, // NB: Commons API uses inclusive end point for some reason
         col0Incl, col1Excl - 1);
    }
    
    override createEmpty(int nRows, int nCols) {
      return root().createEmpty(nRows, nCols)
    }
    
    override DenseMatrix multiplyTo(DenseMatrix another) {
      // The cost of copying is negligible for matrix multiplication
      val DenseMatrix copy = StaticUtils::copy(this)
      return copy.multiplyTo(another)
    }
    
    override String toString() {
      // TODO: use views to truncate (ALSO IN VIEW AND SPARSE AND DENSE)
      return StaticUtils::toStringDimensions(this) + " dense matrix view\n" + StaticUtils::toString(this)
    }
  }
}