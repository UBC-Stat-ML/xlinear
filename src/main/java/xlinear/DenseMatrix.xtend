package xlinear

import org.eclipse.xtend.lib.annotations.Data
import java.util.Formatter
import java.util.Locale
import java.text.DecimalFormat
import org.jblas.DoubleMatrix
import cern.colt.matrix.tdouble.DoubleMatrix2D
import cern.colt.matrix.tdouble.impl.DenseDoubleMatrix2D

@Data class DenseMatrix implements Matrix {
  
  val org.apache.commons.math3.linear.RealMatrix implementation
  
  override nRows() {
    implementation.rowDimension
  }
  
  override nCols() {
    implementation.columnDimension
  }
  
  override get(int row, int col) {
    implementation.getEntry(row, col)
  }
  
  override set(int row, int col, double v) {
    implementation.setEntry(row, col, v)
  }
  
  override toString() {
    // Design note: Math commons printing is poor, use ParallelColt's instead
    //   Inefficient, but OK given the API of toString defined 
    //   in Matrix
//    val DenseDoubleMatrix2D converted = new DenseDoubleMatrix2D(implementation.)
  }
  
//  val static TAB = "  "
//  override toString() {
////    val DecimalFormat formatter = DecimalFormat.
////    formatter.
////    formatter.minimumFractionDigits = 2
////    formatter.maximumFractionDigits = 2
//    val builder = new StringBuilder
//    builder.append(implementation.class.simpleName + " " + nRows + " by " + nCols + "\n")
//    for (var row = 0; row < nRows; row++) {
//      for (var col = 0; col < nCols; col++) 
//        builder.append(TAB + formatter.format(get(row, col)))
//      builder.append("\n")
//    }
//    builder.toString
//  }

//  def static void main(String [] args) {
//    val double[][] mtx = 
//      #[
//        #[1.0, 2.0], 
//        #[3.0, 4.0]
//      ]
//    val DoubleMatrix m = new DoubleMatrix(mtx)
//    println(m)
//    
//    val DoubleMatrix2D m2 = new DenseDoubleMatrix2D(mtx)
//    
//    println(m2)
//    
//  }
  
}