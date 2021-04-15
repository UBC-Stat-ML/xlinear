package xlinear

import org.junit.Test

import static extension xlinear.MatrixExtensions.*
import static xlinear.MatrixOperations.*

import static extension java.lang.Math.*
import java.util.Random
import static extension org.junit.Assert.assertEquals
import org.junit.Assert
import java.util.stream.Collectors

class TestPointwise {
  
  @Test
  def void test() {
    val dense = dense(4,2)
    val rand = new Random(1)
    dense.col(0) += sampleStandardNormal(rand, 4)
    
    val result = dense.pointwise[pow(2)]
    
    println(dense)
    println(result)
    
    Assert.assertEquals(dense.get(0,0) ** 2, result.get(0,0), 0.0)
    
    val another = dense(4,2)
    another.col(0) += sampleStandardNormal(rand, 4)
    
    println("--")
    println(another)
    println(result)
    
    val sum = result.pointwise(another) [a,b|a+b]
    
    Assert.assertEquals(sum.get(0,0), result.get(0,0) + another.get(0, 0), 0.0)
    
    println(another)
    println(sum)
  }
  
  @Test
  def void testScalar() {
    val scalar = 56.0
    val asMatrix = scalar.asMatrix
    Assert.assertEquals(asMatrix.get(0), scalar, 0.0)
  }
  
  @Test
  def void testEntries() {
    val dense = dense(4,2)
    val rand = new Random(1)
    dense.col(0) += sampleStandardNormal(rand, 4)
    Assert.assertEquals(dense.entries.count, 8)
    Assert.assertEquals(dense.nonZeroEntries.count, 4)
    
  }
}