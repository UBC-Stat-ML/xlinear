package xlinear

import org.eclipse.xtend.lib.annotations.Data


@Data class SparseMatrix implements Matrix {
  
  /*
   * Design decision: we use Colt instead of Math Commons sparse matrices,
   * because Math Commons has the artificial restriction that nRows * nCols has to 
   * be smaller than Integer.MAX_VALUE (no matter how sparse it is).
   * Colt can hold up to Integer.LONG_VALUE (but this is poorly documented), which 
   * should be more than enough; for more would need more than int's for rows and cols.
   */
  
  val cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D implementation

  override int nRows() {
    implementation.rows
  }

  override int nCols() {
    implementation.columns
  }
  
  override get(int row, int col) {
    implementation.get(row, col)
  }
  
  override set(int row, int col, double v) {
    implementation.set(row, col, v)
  }
  
  
  
//  @FunctionalInterface
//  static interface SparseIterator {
//    def Double visit(int row, int col, double currentValue);
//  }
  
//  def iterateOnNonZeroEntries(SparseIterator iterator) {
//    if (implementation.isView)
//      throw new UnsupportedOperationException
//    implementation.elements.forEachPair[long key, double value |
//      val int row = (key / implementation.columns) as int
//      val int col = (key % implementation.columns) as int
//      val Double r = iterator.visit(row, col, value)
//      if (r != null)
//        
//      true
//    ]
//  }
//  
////          if (this.isNoView) {
////            this.elements.forEachPair(new cern.colt.function.tdouble.LongDoubleProcedure() {
////                public boolean apply(long key, double value) {
////                    int i = (int) (key / columns);
////                    int j = (int) (key % columns);
////                    double r = function.apply(i, j, value);
////                    if (r != value)
////                        elements.put(key, r);
////                    return true;
////                }
////            });
////        } else {
////            super.forEachNonZero(function);
////        }
}
