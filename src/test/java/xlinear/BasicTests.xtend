package xlinear

import static extension xlinear.MatrixOperations.*

import static xlinear.TestData.*

import static xlinear.TestSupport.*

import org.junit.Test
import org.junit.Assert

class BasicTests {
  
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
  
  @Test
  def void testAccessors() {
    
    testAccessors(sparse(2, 3))
    testAccessors(dense(2, 3))
    
  }
  
  def void testAccessors(Matrix m) {
    
    m.set(0, 0, 1.5)
    m.set(0, 1, -45)
    m.set(0, 2, Double.NaN)
    
    Assert.assertTrue(m.get(0, 0) == 1.5)
    Assert.assertTrue(m.get(0, 1) == -45.0)
    Assert.assertTrue(Double.isNaN(m.get(0, 2)))
    Assert.assertTrue(m.get(1, 1) == 0.0)
    
    assertThrownExceptionMatches([m.set(2,0, -5)], StaticUtils::outOfRangeException(2, 1, true))
    assertThrownExceptionMatches([m.set(1,3, -5)], StaticUtils::outOfRangeException(3, 2, false))
    assertThrownExceptionMatches([m.set(-1,0, -5)], StaticUtils::outOfRangeException(-1, 1, true))
    
    assertThrownExceptionMatches([m.get(2,0)], StaticUtils::outOfRangeException(2, 1, true))
    assertThrownExceptionMatches([m.get(1,3)], StaticUtils::outOfRangeException(3, 2, false))
    assertThrownExceptionMatches([m.get(-1,0)], StaticUtils::outOfRangeException(-1, 1, true))
  }
  
  
  
}