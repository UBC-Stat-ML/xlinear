package xlinear.internals

import xlinear.Matrix
import org.eclipse.xtend.lib.annotations.Data
import xlinear.StaticUtils

// TODO: rename to slice
// also, use this to also offer read-only functionality

@Data abstract class MatrixView implements Matrix {
  
  /**
   * The concrete matrix that is viewed by this MatrixView instance.
   */
  val protected Matrix rootMatrix
   
  val protected int row0Incl
  val protected int row1Excl
  val protected int col0Incl
  val protected int col1Excl
  
  /**
   * Translate a row index relative to the view to a row index
   * relative to the rootMatrix matrix
   * 
   * Note: assumes bounds have already been checked.
   */
  def protected int translateRowView2Root(int viewRowIndex) { return viewRowIndex + row0Incl }
  def protected int translateColView2Root(int viewColIndex) { return viewColIndex + col0Incl }
  
  /**
   * Translate a row index relative to the root to a row index
   * relative to the view matrix
   * 
   * Note: assumes bounds have already been checked.
   */
  def protected int translateRowRoot2View(int rootRowIndex) { return rootRowIndex - row0Incl }
  def protected int translateColRoot2View(int rootColIndex) { return rootColIndex + col0Incl }
  
  override Matrix view(int row0Incl, int row1Excl, int col0Incl, int col1Incl) {
    StaticUtils::checkBounds(this, row0Incl,     col0Incl)  // TODO: encapsulate this and check everywhere 
    StaticUtils::checkBounds(this, row1Excl - 1, col1Excl - 1) // - 1 since the second pair is exclusive
    return rootMatrix.view(
      translateRowView2Root(row0Incl), translateRowView2Root(row1Excl),
      translateColView2Root(col0Incl), translateColView2Root(col1Excl)
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
      translateRowView2Root(row),
      translateColView2Root(col)
    )
  }
  
  override void set(int row, int col, double v) {
    StaticUtils::checkBounds(this, row, col)
    rootMatrix.set(
      translateRowView2Root(row),
      translateColView2Root(col),
      v
    )
  }
}