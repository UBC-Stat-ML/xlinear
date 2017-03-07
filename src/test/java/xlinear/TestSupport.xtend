package xlinear

import org.junit.Assert

import static extension xlinear.MatrixExtensions.*

class TestSupport {
  
  def static void assertMatch(Matrix m, double[][] expected) {
    assertMatch(m, expected, 1e-100)
  }
  
  def static void assertMatch(Matrix m, double[][] expected, double tol) {
    if (m.nRows != expected.length || m.nCols != expected.get(0).length)
      throw new RuntimeException
    for (var int row = 0; row < m.nRows; row++)
      for (var int col = 0; col < m.nCols; col++)
        Assert.assertEquals(expected.get(row).get(col), m.get(row, col), tol)
  }
  
  def static void assertMatch(Matrix m1, Matrix m2, double tol) {
    assertMatch(m1, m2.toArray, tol)
  }
  
  def static void assertThrownExceptionMatches(Runnable code, Throwable expectedException) {
    assertThrownExceptionMatches(code, expectedException, true)
  }
  
  def static void assertTypeOfThrownExceptionMatches(Runnable code, Throwable expectedException) {
    assertThrownExceptionMatches(code, expectedException, false)
  }
  
  def private static void assertThrownExceptionMatches(Runnable code, Throwable expectedException, boolean checkMessage) {
    var Throwable thrown = null
    try { 
      code.run
    }
    catch (Throwable t) { thrown = t }
    val String expectedStr = "" + if (checkMessage) expectedException?.toString else expectedException?.class.simpleName
    val String actualStr   = "" + if (checkMessage) thrown?.toString else thrown?.class?.simpleName
    val boolean ok = expectedStr == actualStr
    Assert.assertTrue("Expected exception: " + expectedStr + "; got: " + actualStr , ok)
  }
}