package xlinear

import org.junit.Test

import static xlinear.TestData.*

import static xlinear.MatrixOperations.*

import static xlinear.TestSupport.*

class DecompositionTests {
  
  @Test
  def void cholTest() {
    cholTest(sparseCopy(smallPositiveDefiniteExample)) 
    cholTest(denseCopy(smallPositiveDefiniteExample))
  }
  
  def void cholTest(Matrix m) {
    val L = m.cholesky.L
    assertMatch(L * L.transpose, m, 1e-5)
    val b = denseCopy(#[1.3, 3.2, 4.4])
    val x = m.cholesky.solve(b)
    assertMatch(b, m * x, 1e-5)
    
    val x2 = m.cholesky.solveWithLCoefficients(b)
    assertMatch(b, L * x2, 1e-5)
    
    val x3 = m.cholesky.solveWithLtransposeCoefficients(b)
    assertMatch(b, L.transpose * x3, 1e-5)
  }
  
  @Test
  def void luTest() {
    luTest(sparseCopy(smallPositiveDefiniteExample)) 
    luTest(denseCopy(smallPositiveDefiniteExample))
    luTest(sparseCopy(smallNonSymExample)) 
    luTest(denseCopy(smallNonSymExample))
  }
  
  def void luTest(Matrix m) {
    val b = denseCopy(#[1.3, 3.2, 4.4])
    val x = m.lu.solve(b)
    assertMatch(b, m * x, 1e-5)
  }
}