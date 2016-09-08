package xlinear

import org.junit.Test
import static extension xlinear.MatrixExtensions.*
import static xlinear.MatrixOperations.*
import org.junit.Assert

class TestStream {
  
  
  @Test
  def void test() {
    val Matrix m1 = denseCopy(#[#[1.0, 2.0], #[3.0,4.0]])
    val Matrix m2 = sparseCopy(#[#[1.0, 2.0], #[3.0,4.0]])
    Assert.assertEquals(m1.sum, 10.0, 10e-100)
    Assert.assertEquals(m2.sum, 10.0, 10e-100)
  }
}