package xlinear

import static extension xlinear.MatrixOperations.*

import static xlinear.TestData.*

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
  
}