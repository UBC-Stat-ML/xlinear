package xlinear

import static extension xlinear.MatrixOperations.*
import static xlinear.TestData.*
import org.junit.Test

class ViewsTests {
  
  @Test
  def void testView() {
    testView(denseCopy(dataA))
  }
  
  def void testView(Matrix matrix) {
    
    println(matrix)
    
    val Matrix view = matrix.view(1, 2, 1, 3)
    
    println(view)
    
    matrix.set(1, 1, 44)
    matrix.set(1, 2, 17)
    
    println(view)
    
    view.set(0, 1, 100)
    
    println(view)
    
    println(matrix)
    
  }
  
}