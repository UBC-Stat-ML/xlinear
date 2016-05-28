package xlinear

import static extension xlinear.MatrixOperations.*
import java.util.Random
import org.junit.Test
import org.junit.Assert
import org.apache.commons.math3.linear.Array2DRowRealMatrix

/** 
 * Systematic check of all combinations of sparse/dense/scalar +, -, +=, -=, *, *=
 */
class AgreementTest {
  
  //// Test critical methods
  
  @Test
  def void testPrint() {
    
    var Matrix matrix = denseCopy(dataA)
    var expectedString = '''
    2 x 3 dense matrix
           0              1                2
    0 |    1.50000      -45.0000         NAN
    1 |   -5.00000E-15    0.00000  -INFINITY'''
    Assert.assertEquals(expectedString, matrix.toString)
    
    matrix = sparseCopy(dataA)
    expectedString = '''
    2 x 3 sparse matrix
           0              1               2
    0 |    1.50000      -45.0000        NAN
    1 |   -5.00000E-15            -INFINITY'''
    Assert.assertEquals(expectedString, matrix.toString)
  }
  
  //// Test +,-,* systematically on all sparse/dense inplace/not in place combinations
  
  val double[][] dataA = #[
    #[ 1.5,    -45, Double.NaN],
    #[-0.5e-14,  0, Double.NEGATIVE_INFINITY]
  ]
  
  val double[][] dataB = #[
    #[ 1.1,    -2.2, 5.1],
    #[-0.5e-14,   0, Double.POSITIVE_INFINITY]
  ]
  
  // compute sum, diff, and scaling using an independent method
  val double[][] sum = new Array2DRowRealMatrix(dataA).add(new Array2DRowRealMatrix(dataB)).dataRef
  val double[][] diff = new Array2DRowRealMatrix(dataA).subtract(new Array2DRowRealMatrix(dataB)).dataRef
  val double[][] a2 = new Array2DRowRealMatrix(dataA).scalarMultiply(2.0).data

  
  def void assertMatch(Matrix m, double[][] expected) {
    if (m.nRows != expected.length || m.nCols != expected.get(0).length)
      throw new RuntimeException
    for (var int row = 0; row < m.nRows; row++)
      for (var int col = 0; col < m.nCols; col++)
        Assert.assertEquals(expected.get(row).get(col), m.get(row, col), 1e-100)
  }
  
  def static Matrix addByAddInPlace(Matrix m1, Matrix m2) {
    m1 += m2 
    return m1
  }
  
  def static Matrix subByAddInPlace(Matrix m1, Matrix m2) {
    m1 -= m2
    return m1
  }
  
  def static Matrix scaleByScaleInPlace(Matrix m1, double value) {
    m1 *= value
    return m1
  }

  @Test
  def void testPlusMinusScale() {
    
    assertMatch(denseCopy(dataA)  + denseCopy(dataB), sum)
    assertMatch(sparseCopy(dataA) + sparseCopy(dataB), sum)
    assertMatch(sparseCopy(dataA) + denseCopy(dataB), sum)
    assertMatch(denseCopy(dataA)  + sparseCopy(dataB), sum)
    
    assertMatch(addByAddInPlace(denseCopy(dataA),  denseCopy(dataB)), sum)
    assertMatch(addByAddInPlace(sparseCopy(dataA), sparseCopy(dataB)), sum)
    assertMatch(addByAddInPlace(sparseCopy(dataA), denseCopy(dataB)), sum)
    assertMatch(addByAddInPlace(denseCopy(dataA),  sparseCopy(dataB)), sum)
    
    // make sure behavior is ok when both arg are identical
    assertMatch(denseCopy(dataA)  + denseCopy(dataA), a2)
    assertMatch(sparseCopy(dataA) + sparseCopy(dataA), a2)
    assertMatch(sparseCopy(dataA) + denseCopy(dataA), a2)
    assertMatch(denseCopy(dataA)  + sparseCopy(dataA), a2)
    
    val DenseMatrix dense = denseCopy(dataA)
    val SparseMatrix sparse = sparseCopy(dataA)
    assertMatch(addByAddInPlace(dense,  dense), a2)
    assertMatch(addByAddInPlace(sparse, sparse), a2)
    
    assertMatch(denseCopy(dataA)  - denseCopy(dataB), diff)
    assertMatch(sparseCopy(dataA) - sparseCopy(dataB), diff)
    assertMatch(sparseCopy(dataA) - denseCopy(dataB), diff)
    assertMatch(denseCopy(dataA)  - sparseCopy(dataB), diff)
    
    assertMatch(subByAddInPlace(denseCopy(dataA),  denseCopy(dataB)), diff)
    assertMatch(subByAddInPlace(sparseCopy(dataA), sparseCopy(dataB)), diff)
    assertMatch(subByAddInPlace(sparseCopy(dataA), denseCopy(dataB)), diff)
    assertMatch(subByAddInPlace(denseCopy(dataA),  sparseCopy(dataB)), diff)
    
    assertMatch(denseCopy(dataA)  * 2, a2)
    assertMatch(sparseCopy(dataA) * 2, a2)
    assertMatch(2 * denseCopy(dataA), a2)
    assertMatch(2 * sparseCopy(dataA), a2)
    
    assertMatch(denseCopy(dataA)  * 1.0, dataA)
    assertMatch(sparseCopy(dataA) * 1.0, dataA)
    assertMatch(1.0 * denseCopy(dataA), dataA)
    assertMatch(1.0 * sparseCopy(dataA), dataA)
    
    assertMatch(scaleByScaleInPlace(denseCopy(dataA), 2), a2)
    assertMatch(scaleByScaleInPlace(sparseCopy(dataA), 2), a2)
  }
  
  val double[][] dataC = #[
    #[ 1.5,    -45],
    #[-0.5e-14,  0]
  ]
  
  val double[][] dataD = #[
    #[ 1.1,    -2.2],
    #[-0.5e-14,   0]
  ]
  
  val double[][] prod = new Array2DRowRealMatrix(dataC).multiply(new Array2DRowRealMatrix(dataD)).dataRef
  
  def static Matrix multByMultInPlace(Matrix m1, Matrix m2) {
    m1 *= m2
    return m1
  }
  
  @Test
  def void testMatrixMultiply() {
    
    assertMatch(denseCopy(dataC)  * denseCopy(dataD), prod)
    assertMatch(sparseCopy(dataC) * sparseCopy(dataD), prod)
    assertMatch(sparseCopy(dataC) * denseCopy(dataD), prod)
    assertMatch(denseCopy(dataC)  * sparseCopy(dataD), prod)
    
//    next: check exception is thrown by A *= B (first build sep utility class for test support)
    
//    assertMatch(multByMultInPlace(denseCopy(dataC),  denseCopy(dataD)), prod)
//    assertMatch(multByMultInPlace(sparseCopy(dataC), sparseCopy(dataD)), prod)
//    assertMatch(multByMultInPlace(sparseCopy(dataC), denseCopy(dataD)), prod)
//    assertMatch(multByMultInPlace(denseCopy(dataC),  sparseCopy(dataD)), prod)
    
    
  }
  
//  def private Matrix getTestMatrix(Random rand, int n) {
//    val SparseMatrix m1 = RandomMatrices::erdosRenyi(rand, n, 0.1)
//    m1 *= rand.nextGaussian
//    val SparseMatrix m2 = RandomMatrices::erdosRenyi(rand, n, 0.1)
//    m2 *= rand.nextGaussian
//    return m1 + m2
//  }
  
//  @Test
//  def void testNorm() {
//    val dense  = erdosTestDense(1000)
//    val sparse = erdosTestSparse(1000)
//    Assert.assertEquals(norm(sparse), norm(dense), 0.0)
//  }
//  
//  @Test
//  def void testToString() {
//    val dense  = erdosTestDense(20)
//    val sparse = erdosTestSparse(20) 
//    System.out.println(dense.toString)
//  }
//  
//  def add(boolean withSparse0, boolean withSparse1) {
//    
////    val m0 = zeroes(154, 1234, withSparse0)
//    
//    
//    
//  }
//  
//  def private erdosTestDense(int n) {
//    denseCopy(erdosTestSparse(n))
//  }
//  
//  def private erdosTestSparse(int n) {
//    val random = new Random(1)
//    erdosRenyi(random, n, 0.1)
//  }

  
}
