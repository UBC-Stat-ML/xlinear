package xlinear

import org.junit.Test

import static xlinear.TestData.*

import static xlinear.MatrixOperations.*

class CholeskyTests {
  
  @Test
  def void simpleTest() {
    simpleTest(sparseCopy(smallPositiveDefiniteExample)) 
    println("---")
    simpleTest(denseCopy(smallPositiveDefiniteExample))
  }
  
  def void simpleTest(Matrix m) {
    println(m)
    val L = m.cholesky.L
    println(L)
    println(L * L.transpose)
  }
}