package xlinear.internals

import xlinear.Matrix
import org.eclipse.xtend.lib.annotations.Data
import xlinear.StaticUtils


@Data abstract class Slice implements Matrix {
  
  /**
   * The concrete matrix that is viewed by this MatrixView instance.
   */
  val public Matrix rootMatrix
   
  val public int row0Incl
  val public int row1Excl
  val public int col0Incl
  val public int col1Excl
  
  val protected boolean readOnly
  
  /**
   * Translate a row index relative to the slice to a row index
   * relative to the rootMatrix matrix
   * 
   * Note: assumes bounds have already been checked.
   */
  def protected int rowSlice2Root(int sliceRowIndex) { return sliceRowIndex + row0Incl }
  def protected int colSlice2Root(int sliceColIndex) { return sliceColIndex + col0Incl }
  
  /**
   * Translate a row index relative to the root to a row index
   * relative to the slice 
   * 
   * Note: assumes bounds have already been checked.
   */
  def protected int rowRoot2Slice(int rootRowIndex) { return rootRowIndex - row0Incl }
  def protected int colRoot2Slice(int rootColIndex) { return rootColIndex - col0Incl }
  
  override Matrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean makeSubSliceReadOnly) {
    StaticUtils::checkValidSlice(this, row0Incl, row1Excl, col0Incl, col1Excl) 
    return rootMatrix.slice(
      rowSlice2Root(row0Incl), rowSlice2Root(row1Excl),
      colSlice2Root(col0Incl), colSlice2Root(col1Excl),
      makeSubSliceReadOnly || readOnly
    )
  }
  
  override int nRows() {
    return row1Excl - row0Incl
  }
  
  override int nCols() {
    return col1Excl - col0Incl
  }
  
  override double get(int row, int col) {
    StaticUtils::checkBounds(this, row, col)
    return rootMatrix.get(
      rowSlice2Root(row),
      colSlice2Root(col)
    )
  }
  
  override void set(int row, int col, double value) {
    if (readOnly)
      throw new UnsupportedOperationException
    StaticUtils::checkBounds(this, row, col)
    rootMatrix.set(
      rowSlice2Root(row),
      colSlice2Root(col),
      value
    )
  }
}