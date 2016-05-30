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
  
  static private interface MatrixProvider {
    def Matrix provide(double [][] data)
  }
  
  @Test
  def void testPlusMinusScale() {
    testPlusMinusScale(
      [double [][] data | sparseCopy(data)],
      [double [][] data | denseCopy(data)])
    // test views too
    testPlusMinusScale(
      [double [][] data | growAndView(sparseCopy(data))],
      [double [][] data | growAndView(denseCopy(data))])
  }
  
  def private Matrix growAndView(Matrix m) {
    val Matrix augmented = m.createEmpty(m.nRows + 2, m.nCols + 2)
    for (var int r = 0; r < m.nRows; r++)
      for (var int c = 0; c < m.nCols; c++)
        augmented.set(r + 1, c + 1, m.get(r, c))
    val Matrix result = augmented.slice(1, augmented.nRows - 1, 1, augmented.nCols - 1, false)
    if (result.nRows != m.nRows || result.nCols != m.nCols)
      throw new RuntimeException
    return result
  }
    
  def void testPlusMinusScale(MatrixProvider sparses, MatrixProvider denses) {
    
    //// +
    
    assertMatch(denses.provide(dataA)  + denses.provide(dataB), sum)
    assertMatch(sparses.provide(dataA) + sparses.provide(dataB), sum)
    assertMatch(sparses.provide(dataA) + denses.provide(dataB), sum)
    assertMatch(denses.provide(dataA)  + sparses.provide(dataB), sum)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([denses.provide(dataA)   + denses.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses.provide(dataA)  + sparses.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses.provide(dataA)  + denses.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([denses.provide(dataA)   + sparses.provide(dataC)], new DimensionMismatchException(3,2))
    
    
    //// +=
    
    assertMatch(addByAddInPlace(denses.provide(dataA),  denses.provide(dataB)), sum)
    assertMatch(addByAddInPlace(sparses.provide(dataA), sparses.provide(dataB)), sum)
    assertMatch(addByAddInPlace(sparses.provide(dataA), denses.provide(dataB)), sum)
    assertMatch(addByAddInPlace(denses.provide(dataA),  sparses.provide(dataB)), sum)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([addByAddInPlace(denses.provide(dataA),  denses.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(sparses.provide(dataA), sparses.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(sparses.provide(dataA), denses.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(denses.provide(dataA),  sparses.provide(dataC))], new DimensionMismatchException(3,2))
    
    
    // make sure behavior is ok when both arg are identical
    
    assertMatch(denses.provide(dataA)  + denses.provide(dataA), a2)
    assertMatch(sparses.provide(dataA) + sparses.provide(dataA), a2)
    assertMatch(sparses.provide(dataA) + denses.provide(dataA), a2)
    assertMatch(denses.provide(dataA)  + sparses.provide(dataA), a2)
    
    val Matrix dense = denses.provide(dataA)
    val Matrix sparse = sparses.provide(dataA)
    assertMatch(addByAddInPlace(dense,  dense), a2)
    assertMatch(addByAddInPlace(sparse, sparse), a2)
    
    
    //// -
    
    assertMatch(denses.provide(dataA)  - denses.provide(dataB), diff)
    assertMatch(sparses.provide(dataA) - sparses.provide(dataB), diff)
    assertMatch(sparses.provide(dataA) - denses.provide(dataB), diff)
    assertMatch(denses.provide(dataA)  - sparses.provide(dataB), diff)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([denses.provide(dataA)  - denses.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses.provide(dataA) - sparses.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses.provide(dataA) - denses.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([denses.provide(dataA)  - sparses.provide(dataC)], new DimensionMismatchException(3,2))
    
    
    //// -=
    
    assertMatch(subByAddInPlace(denses.provide(dataA),  denses.provide(dataB)), diff)
    assertMatch(subByAddInPlace(sparses.provide(dataA), sparses.provide(dataB)), diff)
    assertMatch(subByAddInPlace(sparses.provide(dataA), denses.provide(dataB)), diff)
    assertMatch(subByAddInPlace(denses.provide(dataA),  sparses.provide(dataB)), diff)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([subByAddInPlace(denses.provide(dataA),  denses.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(sparses.provide(dataA), sparses.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(sparses.provide(dataA), denses.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(denses.provide(dataA),  sparses.provide(dataC))], new DimensionMismatchException(3,2))
    
    
    //// * scalar
    
    assertMatch(denses.provide(dataA)  * 2, a2)
    assertMatch(sparses.provide(dataA) * 2, a2)
    assertMatch(2 * denses.provide(dataA), a2)
    assertMatch(2 * sparses.provide(dataA), a2)
    
    
    // special case
    
    assertMatch(denses.provide(dataA)  * 1.0, dataA)
    assertMatch(sparses.provide(dataA) * 1.0, dataA)
    assertMatch(1.0 * denses.provide(dataA), dataA)
    assertMatch(1.0 * sparses.provide(dataA), dataA)
    
    
    //// *= scalar
    
    assertMatch(scaleByScaleInPlace(denses.provide(dataA), 2), a2)
    assertMatch(scaleByScaleInPlace(sparses.provide(dataA), 2), a2)
    
  }
  
  @Test
  def void testMatrixMultiply() {
    testMatrixMultiply(
      [double [][] data | sparseCopy(data)],
      [double [][] data | denseCopy(data)])
  }
  
  def void testMatrixMultiply(MatrixProvider sparses, MatrixProvider denses) {
    
    assertMatch(denses.provide(dataC)  * denses.provide(dataD), prod)
    assertMatch(sparses.provide(dataC) * sparses.provide(dataD), prod)
    assertMatch(sparses.provide(dataC) * denses.provide(dataD), prod)
    assertMatch(denses.provide(dataC)  * sparses.provide(dataD), prod)
    
    // check exceptions for dim mismatch
    assertThrownExceptionMatches([denses.provide(dataB)  * denses.provide(dataC)],new DimensionMismatchException(3,2)) 
    assertThrownExceptionMatches([sparses.provide(dataB) * sparses.provide(dataC)],new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses.provide(dataB) * denses.provide(dataC)],new DimensionMismatchException(3,2)) 
    assertThrownExceptionMatches([denses.provide(dataB)  * sparses.provide(dataC)],new DimensionMismatchException(3,2)) 
    
    // check unsupported *= operations
    assertTypeOfThrownExceptionMatches([denses.provide(dataB)  *= denses.provide(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([sparses.provide(dataB) *= sparses.provide(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([sparses.provide(dataB) *= denses.provide(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([denses.provide(dataB)  *= sparses.provide(dataC)], new UnsupportedOperationException)
    
  }
  
  @Test
  def void testEfficient() {
    
    val Random rand = new Random(1)
    val int largeDim = 10_000
    val SparseMatrix matrix1 = randomSparse(rand, largeDim, 10)
    val SparseMatrix matrix2 = randomSparse(rand, largeDim, 10)
    
    // This works, but somehow sometimes much more than the allocated heap is claimed 
    // so this makes test unstable
//    // test the test (ie. make sure the picked dim crashes if dense matrices are used)
//    assertTypeOfThrownExceptionMatches([testEfficient(denseCopy(matrix1), denseCopy(matrix2))], new OutOfMemoryError)
    
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
