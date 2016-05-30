package xlinear

import static extension xlinear.MatrixOperations.*

import static xlinear.TestSupport.*

import static xlinear.TestData.*

import org.junit.Test
import org.apache.commons.math3.exception.DimensionMismatchException
import java.util.Random

/** 
 * Systematic check of all combinations of sparse/dense/scalar +, -, +=, -=, *, *=
 */
class OperationsTest {
  
  @Test
  def void testPlusMinusScale() {
    
    //// +
    
    assertMatch(denseCopy(dataA)  + denseCopy(dataB), sum)
    assertMatch(sparseCopy(dataA) + sparseCopy(dataB), sum)
    assertMatch(sparseCopy(dataA) + denseCopy(dataB), sum)
    assertMatch(denseCopy(dataA)  + sparseCopy(dataB), sum)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([denseCopy(dataA)   + denseCopy(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparseCopy(dataA)  + sparseCopy(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparseCopy(dataA)  + denseCopy(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([denseCopy(dataA)   + sparseCopy(dataC)], new DimensionMismatchException(3,2))
    
    
    //// +=
    
    assertMatch(addByAddInPlace(denseCopy(dataA),  denseCopy(dataB)), sum)
    assertMatch(addByAddInPlace(sparseCopy(dataA), sparseCopy(dataB)), sum)
    assertMatch(addByAddInPlace(sparseCopy(dataA), denseCopy(dataB)), sum)
    assertMatch(addByAddInPlace(denseCopy(dataA),  sparseCopy(dataB)), sum)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([addByAddInPlace(denseCopy(dataA),  denseCopy(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(sparseCopy(dataA), sparseCopy(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(sparseCopy(dataA), denseCopy(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(denseCopy(dataA),  sparseCopy(dataC))], new DimensionMismatchException(3,2))
    
    
    // make sure behavior is ok when both arg are identical
    
    assertMatch(denseCopy(dataA)  + denseCopy(dataA), a2)
    assertMatch(sparseCopy(dataA) + sparseCopy(dataA), a2)
    assertMatch(sparseCopy(dataA) + denseCopy(dataA), a2)
    assertMatch(denseCopy(dataA)  + sparseCopy(dataA), a2)
    
    val DenseMatrix dense = denseCopy(dataA)
    val SparseMatrix sparse = sparseCopy(dataA)
    assertMatch(addByAddInPlace(dense,  dense), a2)
    assertMatch(addByAddInPlace(sparse, sparse), a2)
    
    
    //// -
    
    assertMatch(denseCopy(dataA)  - denseCopy(dataB), diff)
    assertMatch(sparseCopy(dataA) - sparseCopy(dataB), diff)
    assertMatch(sparseCopy(dataA) - denseCopy(dataB), diff)
    assertMatch(denseCopy(dataA)  - sparseCopy(dataB), diff)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([denseCopy(dataA)  - denseCopy(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparseCopy(dataA) - sparseCopy(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparseCopy(dataA) - denseCopy(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([denseCopy(dataA)  - sparseCopy(dataC)], new DimensionMismatchException(3,2))
    
    
    //// -=
    
    assertMatch(subByAddInPlace(denseCopy(dataA),  denseCopy(dataB)), diff)
    assertMatch(subByAddInPlace(sparseCopy(dataA), sparseCopy(dataB)), diff)
    assertMatch(subByAddInPlace(sparseCopy(dataA), denseCopy(dataB)), diff)
    assertMatch(subByAddInPlace(denseCopy(dataA),  sparseCopy(dataB)), diff)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([subByAddInPlace(denseCopy(dataA),  denseCopy(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(sparseCopy(dataA), sparseCopy(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(sparseCopy(dataA), denseCopy(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(denseCopy(dataA),  sparseCopy(dataC))], new DimensionMismatchException(3,2))
    
    
    //// * scalar
    
    assertMatch(denseCopy(dataA)  * 2, a2)
    assertMatch(sparseCopy(dataA) * 2, a2)
    assertMatch(2 * denseCopy(dataA), a2)
    assertMatch(2 * sparseCopy(dataA), a2)
    
    
    // special case
    
    assertMatch(denseCopy(dataA)  * 1.0, dataA)
    assertMatch(sparseCopy(dataA) * 1.0, dataA)
    assertMatch(1.0 * denseCopy(dataA), dataA)
    assertMatch(1.0 * sparseCopy(dataA), dataA)
    
    
    //// *= scalar
    
    assertMatch(scaleByScaleInPlace(denseCopy(dataA), 2), a2)
    assertMatch(scaleByScaleInPlace(sparseCopy(dataA), 2), a2)
    
  }
  
  @Test
  def void testMatrixMultiply() {
    
    assertMatch(denseCopy(dataC)  * denseCopy(dataD), prod)
    assertMatch(sparseCopy(dataC) * sparseCopy(dataD), prod)
    assertMatch(sparseCopy(dataC) * denseCopy(dataD), prod)
    assertMatch(denseCopy(dataC)  * sparseCopy(dataD), prod)
    
    // check exceptions for dim mismatch
    assertThrownExceptionMatches([denseCopy(dataB)  * denseCopy(dataC)],new DimensionMismatchException(3,2)) 
    assertThrownExceptionMatches([sparseCopy(dataB) * sparseCopy(dataC)],new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparseCopy(dataB) * denseCopy(dataC)],new DimensionMismatchException(3,2)) 
    assertThrownExceptionMatches([denseCopy(dataB)  * sparseCopy(dataC)],new DimensionMismatchException(3,2)) 
    
    // check unsupported *= operations
    assertTypeOfThrownExceptionMatches([denseCopy(dataB)  *= denseCopy(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([sparseCopy(dataB) *= sparseCopy(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([sparseCopy(dataB) *= denseCopy(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([denseCopy(dataB)  *= sparseCopy(dataC)], new UnsupportedOperationException)
    
  }
  
  @Test
  def void testEfficient() {
    
    val Random rand = new Random(1)
    val int largeDim = 10_000
    val SparseMatrix matrix1 = randomSparse(rand, largeDim, 10)
    val SparseMatrix matrix2 = randomSparse(rand, largeDim, 10)
    
    // test the test (ie. make sure the picked dim crashes if dense matrices are used)
    assertTypeOfThrownExceptionMatches([testEfficient(denseCopy(matrix1), denseCopy(matrix2))], new OutOfMemoryError)
    
    // check it's all good with sparse matrices 
    testEfficient(matrix1, matrix2)
    
  }
  
  def static void testEfficient(Matrix matrix1, Matrix matrix2) {
    matrix1 += matrix2
    matrix1 *= 2
    
    matrix1 * matrix2
    matrix1 + matrix2
    matrix1 * 2
    matrix1 - matrix2
    matrix1 -= matrix2
    
    val Matrix dense1 = dense(matrix1.nRows, 3)
    matrix1 * dense1
    
    val Matrix dense2 = dense(3, matrix1.nRows)
    dense2 * matrix1
  }
  
  def private static SparseMatrix randomSparse(Random rand, int graphSize, int numberSampled) {
    
    val SparseMatrix result = sparse(graphSize, graphSize)
    
    for (var int i = 0; i < numberSampled; i++) {
      val int row = rand.nextInt(graphSize)
      val int col = rand.nextInt(graphSize)
      result.set(row, col, rand.nextDouble)
    }
    
    return result
  }
    
  def static Matrix multByMultInPlace(Matrix m1, Matrix m2) {
    m1 *= m2
    return m1
  }
  
  def static Matrix addByAddInPlace(Matrix m1, Matrix m2) {
    m1 += m2 
    return m1
  }
  
  def static Matrix subByAddInPlace(Matrix m1, Matrix m2) {
    m1 -= m2
    return m1
  }
  
  def static Matrix scaleByScaleInPlace(Matrix m1, double value) {
    m1 *= value
    return m1
  }
  
}
