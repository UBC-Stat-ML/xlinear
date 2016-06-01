package xlinear

import org.junit.Test

import static xlinear.TestData.*

import static xlinear.MatrixOperations.*

class CholeskyTests {
  
  @Test
  def void simpleTest() {
    simpleTest(sparseCopy(smallPosDef))
    println("---")
    simpleTest(denseCopy(smallPosDef))
  }
  
  def void simpleTest(Matrix m) {
    println(m)
    val L = m.cholesky.L
    println(L)
    println(L * L.transpose)
  }
}