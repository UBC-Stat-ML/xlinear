package xlinear

import org.junit.Test

import static xlinear.TestData.*

import static xlinear.MatrixOperations.*

import static xlinear.TestSupport.*

class CholeskyTests {
  
  @Test
  def void simpleTest() {
    simpleTest(sparseCopy(smallPositiveDefiniteExample)) 
    simpleTest(denseCopy(smallPositiveDefiniteExample))
  }
  
  def void simpleTest(Matrix m) {
    val L = m.cholesky.L
    assertMatch(L * L.transpose, m, 1e-5)
    val b = denseCopy(#[1.3, 3.2, 4.4])
    val x = m.cholesky.solver.solve(b)
    assertMatch(b, m * x, 1e-5)
  }
}