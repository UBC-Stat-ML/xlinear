package xlinear

import static extension xlinear.MatrixOperations.*
import static xlinear.TestData.*
import static xlinear.TestSupport.*
import org.junit.Test
import org.junit.Assert

class SliceTests {
  
  @Test
  def void testSlices() {
    testSlice(denseCopy(dataA))
    testSlice(sparseCopy(dataA))
  }
  
  def void testSlice(Matrix matrix) {
    
    var expected = '''
           0              1                2
    0 |    1.50000      -45.0000         NAN
    1 |   -5.00000E-15    0.00000  -INFINITY'''
    Assert.assertEquals(StaticUtils::toString(matrix), expected)
    
    val Matrix view = matrix.slice(1, 2, 1, 3, false) 
    
    
    // TODO: need to check for slice x concrete implementation as well
    // TODO: (global) start documentation
    // TODO: create wrappers based on https://github.com/scalanlp/breeze/wiki/Linear-Algebra-Cheat-Sheet
    // TODO: det, eig, chol, inv, etc
    // TODO: hook up jeigen
    
    expected = '''
          0                1
    0 |   0.00000  -INFINITY'''
    Assert.assertEquals(StaticUtils::toString(view), expected)
    
    // change the underlying matrix and make sure it 
    // changes the slice as well
    matrix.set(1, 1, 44)
    matrix.set(1, 2, 17)
    
    expected = '''
           0        1     
    0 |   44.0000  17.0000'''
    Assert.assertEquals(StaticUtils::toString(view), expected)
    
    // conversely, changing the slice changes the 
    // underlying and the view too
    view.set(0, 1, 100)
    
    expected = '''
           0         1    
    0 |   44.0000  100.000'''
    Assert.assertEquals(StaticUtils::toString(view), expected)
    
    expected = '''
           0              1         2    
    0 |    1.50000      -45.0000  NAN    
    1 |   -5.00000E-15   44.0000  100.000'''
    Assert.assertEquals(StaticUtils::toString(matrix), expected)
    
    // Now test the view of a view
    
    val Matrix subView = view.slice(0,1, 1,2, false)
    
    expected = '''
            0    
    0 |   100.000'''
    Assert.assertEquals(StaticUtils::toString(subView), expected)
    
    // Check exception thrown on empty slices
    assertTypeOfThrownExceptionMatches([ matrix.slice(0, 1, 0, 0, true)], new IllegalArgumentException)
    assertTypeOfThrownExceptionMatches([subView.slice(0, 1, 0, 0, true)], new IllegalArgumentException)
    
    // Check exception thrown on out of bounds
    assertThrownExceptionMatches([view.get(1,1)], StaticUtils::outOfRangeException(1,0,true))
    assertThrownExceptionMatches([view.get(0,2)], StaticUtils::outOfRangeException(2,1,false))
    
    // check read only slice is read only
    val Matrix ro = matrix.slice(0, 1, 0, 1, true)
    
    ro.get(0, 0)
    assertTypeOfThrownExceptionMatches([ro.set(0, 0, 34)], new UnsupportedOperationException)
    
  }
  
}