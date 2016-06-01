package xlinear.internals

import xlinear.DenseMatrix
import org.eclipse.xtend.lib.annotations.Data
import org.apache.commons.math3.linear.BlockRealMatrix
import org.apache.commons.math3.linear.RealMatrixChangingVisitor
import xlinear.StaticUtils
import org.apache.commons.math3.linear.RealMatrixPreservingVisitor
import xlinear.CholeskyDecomposition
import org.apache.commons.math3.linear.RealMatrix

@Data class CommonsDenseMatrix implements DenseMatrix {
  
  val RealMatrix implementation
  
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
  
  override CommonsDenseMatrix mul(DenseMatrix another) {
    StaticUtils::checkMatrixMultiplicationDimensionsMatch(this, another)
    // TODO: if big, attempt JBlas/JEigen?
    switch another {
      CommonsDenseMatrix : 
        return new CommonsDenseMatrix(this.implementation.multiply(another.implementation))
      default : 
        return mul(StaticUtils::convertToCommonsDenseMatrix(another)) // TODO: if small, use default implementation instead?
    }
  }
  
  override CholeskyDecomposition cholesky() {
    // TODO: catch exceptions to harmonize them with Dense
    // TODO: attempt to use JEigen if matrix is large
    val chol = 
      new org.apache.commons.math3.linear.CholeskyDecomposition(implementation)
    val CommonsDenseMatrix L = new CommonsDenseMatrix(chol.l)
    return new CholeskyDecomposition(L.readOnlyView);
  }
  
  override CommonsDenseMatrix createEmpty(int nRows, int nCols) {
    return new CommonsDenseMatrix(new BlockRealMatrix(nRows, nCols))
  }
  
  override DenseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean readOnly) {
    StaticUtils::checkValidSlice(this, row0Incl, row1Excl, col0Incl, col1Excl)
    return new CommonsDenseMatrixSlice(this, row0Incl, row1Excl, col0Incl, col1Excl, readOnly)
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
  
  private static class CommonsDenseMatrixSlice extends Slice implements DenseMatrix {
    
    def private CommonsDenseMatrix root() {
      return rootMatrix as CommonsDenseMatrix
    }
    
    new(CommonsDenseMatrix rootMatrix, int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean readOnly) {
      super(rootMatrix, row0Incl, row1Excl, col0Incl, col1Excl, readOnly)
    }
    
    override DenseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Incl, boolean subSliceReadOnly) {
      super.slice(row0Incl, row1Excl, col0Incl, col1Incl, subSliceReadOnly) as DenseMatrix
    }
    
    override void visit(MatrixVisitorViewOnly visitor) {
      // Warning: code similar to editInPlace
      root().implementation.walkInOptimizedOrder(new RealMatrixPreservingVisitor() {
        override double end() { 0.0 }
        override void start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
        override void visit(int row, int col, double value) {
          visitor.visit(
            rowRoot2Slice(row),
            colRoot2Slice(col), 
            value
          )
        }
      }, row0Incl, row1Excl - 1, // NB: Commons API uses inclusive end point for some reason
         col0Incl, col1Excl - 1);
    }
    
    override void editInPlace(MatrixVisitorEditInPlace visitor) {
      if (readOnly)
        throw new UnsupportedOperationException
      // Warning: code similar to editInPlace
      root().implementation.walkInOptimizedOrder(new RealMatrixChangingVisitor() {
        override double end() { 0.0 }
        override void start(int rows, int columns, int startRow, int endRow, int startColumn, int endColumn) {}
        override double visit(int row, int col, double value) {
          return visitor.editInPlace(
            rowRoot2Slice(row), 
            colRoot2Slice(col), 
            value
          )
        }
      }, row0Incl, row1Excl - 1, // NB: Commons API uses inclusive end point for some reason
         col0Incl, col1Excl - 1);
    }
    
    override DenseMatrix createEmpty(int nRows, int nCols) {
      return root().createEmpty(nRows, nCols)
    }
    
    override DenseMatrix mul(DenseMatrix another) {
      // The cost of copying is negligible for matrix multiplication
      val DenseMatrix copy = StaticUtils::copy(this)
      return copy.mul(another)
    }
    
    override String toString() {
      // TODO: use views to truncate (ALSO IN VIEW AND SPARSE AND DENSE)
      return StaticUtils::toStringDimensions(this) + " dense matrix" + 
        (if (readOnly) " read-only" else "") + 
        " slice\n" + StaticUtils::toString(this)
    }
  }
}