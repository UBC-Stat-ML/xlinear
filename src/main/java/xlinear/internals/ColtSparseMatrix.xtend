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
  
  override SparseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean readOnly) {
    StaticUtils::checkValidSlice(this, row0Incl, row1Excl, col0Incl, col1Excl)
    return new ColtSparseMatrixSlice(this, row0Incl, row1Excl, col0Incl, col1Excl, readOnly)
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
      default : 
        return multiplyTo(convert(another)) // TODO: if small, use default implementation instead?
    }
  }
  
  def static private SparseMatrix convert(SparseMatrix model) {
    val ColtSparseMatrix result = new ColtSparseMatrix(new SparseDoubleMatrix2D(model.nRows, model.nCols))
    model.visitNonZeros[int row, int col, double currentValue |
      result.set(row, col, currentValue)
    ]
    return result
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
  
  private static class ColtSparseMatrixSlice extends Slice implements SparseMatrix {
    
    def private ColtSparseMatrix root() {
      return rootMatrix as ColtSparseMatrix
    }
    
    new(ColtSparseMatrix rootMatrix, int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean readOnly) {
      super(rootMatrix, row0Incl, row1Excl, col0Incl, col1Excl, readOnly)
    }
    
    override SparseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Incl, boolean subSliceReadOnly) {
      super.slice(row0Incl, row1Excl, col0Incl, col1Incl, subSliceReadOnly) as SparseMatrix
    }
    
    override void visitNonZeros(MatrixVisitorViewOnly visitor) {
      root().visitNonZeros[int row, int col, double value |
        if (row >= row0Incl && row < row1Excl &&
            col >= col0Incl && col < col1Excl)
          visitor.visit(
            rowRoot2Slice(row), 
            colRoot2Slice(col), 
            value
          )
      ]
    }
    
    override void editNonZerosInPlace(MatrixVisitorEditInPlace visitor) {
      if (readOnly)
        throw new UnsupportedOperationException
      root().editNonZerosInPlace[int row, int col, double value |
        if (row >= row0Incl && row < row1Excl &&
            col >= col0Incl && col < col1Excl)
          return visitor.editInPlace(
            rowRoot2Slice(row), 
            colRoot2Slice(col), 
            value
          )
        else
          return value
      ]
    }
    
    override SparseMatrix createEmpty(int nRows, int nCols) {
      return root().createEmpty(nRows, nCols)
    }
    
    override SparseMatrix multiplyTo(SparseMatrix another) {
      // The cost of copying is negligible for matrix multiplication
      val SparseMatrix copy = StaticUtils::copy(this)
      return copy.multiplyTo(another)
    }
    
    override String toString() {
      // TODO: use views to truncate (ALSO IN VIEW AND SPARSE AND DENSE)
      return StaticUtils::toStringDimensions(this) + " sparse matrix" + 
        (if (readOnly) " read-only" else "") + 
        " slice\n" + StaticUtils::toString(this)
    }
  }
}