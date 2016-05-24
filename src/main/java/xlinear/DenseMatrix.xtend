package xlinear

import org.eclipse.xtend.lib.annotations.Data
import org.apache.commons.math3.linear.RealMatrix

// need this to isolate the user from Math Commons' bloated API
  // create one to shadow the other 
@Data class DenseMatrix implements Matrix {
    
  val package RealMatrix implementation
  
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