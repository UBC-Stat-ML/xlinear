package xlinear

import org.eclipse.xtend.lib.annotations.Data
import org.apache.commons.math3.linear.OpenMapRealMatrix

// need this to isolate the user from Math Commons' bloated API
// we avoid generics here because we want dispatch methods to work properly (type erasure)
@Data class SparseMatrix implements Matrix {
    
  val package OpenMapRealMatrix implementation
  
  override nRows() {
    implementation.rowDimension
  }
  
  override nCols() {
    implementation.columnDimension
  }
  
  override toString() {
    implementation.toString
  }
  
}