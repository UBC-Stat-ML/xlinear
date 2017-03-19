package xlinear

import static extension xlinear.MatrixExtensions.*
import static xlinear.MatrixOperations.*
import java.util.Random
import org.junit.Test

class TestSampling {
  
  @Test
  def void test() {
    
    // test scalability
    val id = identity(100_000)
    sampleNormalByPrecision(new Random(1), id)
    
    // test correctness
    check(true,  true)
    check(false, true)
    check(true,  false)
    check(false, false)
  }
  
  def static void check(boolean byPrecision, boolean useSparse) {  
    val sums = 
      dense(2, 2)
    var denom = 0.0
    
    val rand = new Random(1)
    
    val covar = denseCopy(
      #[
        #[2.0, 1.4],
        #[1.4, 1.7]
      ]
    )
    var Matrix precision = covar.inverse
    
    if (useSparse) {
      precision = sparseCopy(precision)
    }
    
    for (i : 1 .. 100_000) {
      var cur = 
        if (byPrecision) {
          sampleNormalByPrecision(rand, precision)
        } else {
          sampleNormalByCovariance(rand, covar)
        }
      sums += cur * cur.transpose
      denom ++
    }
    
    sums /= denom
    
    TestSupport::assertMatch(sums, covar, 0.01)
  }
  
}