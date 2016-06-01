package xlinear

import org.apache.commons.math3.linear.Array2DRowRealMatrix

class TestData {
  
  val public static double[][] dataA = #[
    #[ 1.5,    -45, Double.NaN],
    #[-0.5e-14,  0, Double.NEGATIVE_INFINITY]
  ]
  
  val public static double[][] dataB = #[
    #[ 1.1,    -2.2, 5.1],
    #[-0.5e-14,   0, Double.POSITIVE_INFINITY]
  ]
  
  val public static double[][] dataC = #[
    #[ 1.5,    -45],
    #[-0.5e-14,  0]
  ]
  
  val public static double[][] dataD = #[
    #[ 1.1,    -2.2],
    #[-0.5e-14,   0]
  ]
  
  // compute sum, diff, and scaling using an independent method
  val public static double[][] sum = new Array2DRowRealMatrix(dataA).add(new Array2DRowRealMatrix(dataB)).dataRef
  val public static double[][] diff = new Array2DRowRealMatrix(dataA).subtract(new Array2DRowRealMatrix(dataB)).dataRef
  val public static double[][] a2 = new Array2DRowRealMatrix(dataA).scalarMultiply(2.0).data
  val public static double[][] prod = new Array2DRowRealMatrix(dataC).multiply(new Array2DRowRealMatrix(dataD)).dataRef
  
  val public static double[][] smallPositiveDefiniteExample = #[
    #[ 2, -1,   0],
    #[-1,  2,  -1],
    #[ 0, -1,   2]
  ]
  
  
}