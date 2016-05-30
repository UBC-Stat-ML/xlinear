package xlinear

import static extension xlinear.MatrixOperations.*

import static xlinear.TestSupport.*

import static xlinear.TestData.*

import org.junit.Test
import org.apache.commons.math3.exception.DimensionMismatchException
import java.util.Random
import java.util.List

/** 
 * Systematic check of all combinations of sparse/dense/scalar +, -, +=, -=, *, *=
 */
class OperationsTest {
  
  static private interface MatrixProvider {
    def Matrix provide(double [][] data)
  }
  
  @Test
  def void testPlusMinusScale() {
    
    // test all combinations of (sparse/dense/view of sparse/view of dense) cross (+/-/+=/-=/* scalar) cross (sparse/dense/view of sparse/view of dense)
    val List<MatrixProvider> sparseProviders = #[[double [][] data | sparseCopy(data)], [double [][] data | growAndView(sparseCopy(data))]]
    val List<MatrixProvider> denseProviders  = #[[double [][] data | denseCopy(data)],  [double [][] data | growAndView(denseCopy(data))]]
    
    for (sp1 : sparseProviders)
      for (sp2 : sparseProviders)
        for (dp1 : denseProviders)
          for (dp2 : denseProviders)
            testPlusMinusScale(sp1, sp2, dp1, dp2)
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
    
  def void testPlusMinusScale(MatrixProvider sparses1, MatrixProvider sparses2, MatrixProvider denses1, MatrixProvider denses2) {
    
    //// +
    
    assertMatch(denses1.provide(dataA)  + denses2.provide(dataB), sum)
    assertMatch(sparses1.provide(dataA) + sparses2.provide(dataB), sum)
    assertMatch(sparses1.provide(dataA) + denses2.provide(dataB), sum)
    assertMatch(denses1.provide(dataA)  + sparses2.provide(dataB), sum)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([denses1.provide(dataA)   + denses2.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses1.provide(dataA)  + sparses2.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses1.provide(dataA)  + denses2.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([denses1.provide(dataA)   + sparses2.provide(dataC)], new DimensionMismatchException(3,2))
    
    
    //// +=
    
    assertMatch(addByAddInPlace(denses1.provide(dataA),  denses2.provide(dataB)), sum)
    assertMatch(addByAddInPlace(sparses1.provide(dataA), sparses2.provide(dataB)), sum)
    assertMatch(addByAddInPlace(sparses1.provide(dataA), denses2.provide(dataB)), sum)
    assertMatch(addByAddInPlace(denses1.provide(dataA),  sparses2.provide(dataB)), sum)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([addByAddInPlace(denses1.provide(dataA),  denses2.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(sparses1.provide(dataA), sparses2.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(sparses1.provide(dataA), denses2.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([addByAddInPlace(denses1.provide(dataA),  sparses2.provide(dataC))], new DimensionMismatchException(3,2))
    
    
    // make sure behavior is ok when both arg are identical
    
    assertMatch(denses1.provide(dataA)  + denses2.provide(dataA), a2)
    assertMatch(sparses1.provide(dataA) + sparses2.provide(dataA), a2)
    assertMatch(sparses1.provide(dataA) + denses2.provide(dataA), a2)
    assertMatch(denses1.provide(dataA)  + sparses2.provide(dataA), a2)
    
    val Matrix dense = denses1.provide(dataA)
    val Matrix sparse = sparses1.provide(dataA)
    assertMatch(addByAddInPlace(dense,  dense), a2)
    assertMatch(addByAddInPlace(sparse, sparse), a2)
    
    
    //// -
    
    assertMatch(denses1.provide(dataA)  - denses2.provide(dataB), diff)
    assertMatch(sparses1.provide(dataA) - sparses2.provide(dataB), diff)
    assertMatch(sparses1.provide(dataA) - denses2.provide(dataB), diff)
    assertMatch(denses1.provide(dataA)  - sparses2.provide(dataB), diff)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([denses1.provide(dataA)  - denses2.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses1.provide(dataA) - sparses2.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses1.provide(dataA) - denses2.provide(dataC)], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([denses1.provide(dataA)  - sparses2.provide(dataC)], new DimensionMismatchException(3,2))
    
    
    //// -=
    
    assertMatch(subByAddInPlace(denses1.provide(dataA),  denses2.provide(dataB)), diff)
    assertMatch(subByAddInPlace(sparses1.provide(dataA), sparses2.provide(dataB)), diff)
    assertMatch(subByAddInPlace(sparses1.provide(dataA), denses2.provide(dataB)), diff)
    assertMatch(subByAddInPlace(denses1.provide(dataA),  sparses2.provide(dataB)), diff)
    
    
    // check mismatches throw exceptions
    
    assertThrownExceptionMatches([subByAddInPlace(denses1.provide(dataA),  denses2.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(sparses1.provide(dataA), sparses2.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(sparses1.provide(dataA), denses2.provide(dataC))], new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([subByAddInPlace(denses1.provide(dataA),  sparses2.provide(dataC))], new DimensionMismatchException(3,2))
    
    
    //// * scalar
    
    assertMatch(denses1.provide(dataA)  * 2, a2)
    assertMatch(sparses1.provide(dataA) * 2, a2)
    assertMatch(2 * denses1.provide(dataA), a2)
    assertMatch(2 * sparses1.provide(dataA), a2)
    
    
    // special case
    
    assertMatch(denses1.provide(dataA)  * 1.0, dataA)
    assertMatch(sparses1.provide(dataA) * 1.0, dataA)
    assertMatch(1.0 * denses1.provide(dataA), dataA)
    assertMatch(1.0 * sparses1.provide(dataA), dataA)
    
    
    //// *= scalar
    
    assertMatch(scaleByScaleInPlace(denses1.provide(dataA), 2), a2)
    assertMatch(scaleByScaleInPlace(sparses1.provide(dataA), 2), a2)
    
  }
  
  @Test
  def void testMatrixMultiply() {
    
    val List<MatrixProvider> sparseProviders = #[[double [][] data | sparseCopy(data)], [double [][] data | growAndView(sparseCopy(data))]]
    val List<MatrixProvider> denseProviders  = #[[double [][] data | denseCopy(data)],  [double [][] data | growAndView(denseCopy(data))]]
    
    for (sp1 : sparseProviders)
      for (sp2 : sparseProviders)
        for (dp1 : denseProviders)
          for (dp2 : denseProviders)
            testMatrixMultiply(sp1, sp2, dp1, dp2)
  }
  
  def void testMatrixMultiply(MatrixProvider sparses1, MatrixProvider sparses2, MatrixProvider denses1, MatrixProvider denses2) {
    
    assertMatch(denses1.provide(dataC)  * denses2.provide(dataD), prod)
    assertMatch(sparses1.provide(dataC) * sparses2.provide(dataD), prod)
    assertMatch(sparses1.provide(dataC) * denses2.provide(dataD), prod)
    assertMatch(denses1.provide(dataC)  * sparses2.provide(dataD), prod)
    
    // check exceptions for dim mismatch
    assertThrownExceptionMatches([denses1.provide(dataB)  * denses2.provide(dataC)],new DimensionMismatchException(3,2)) 
    assertThrownExceptionMatches([sparses1.provide(dataB) * sparses2.provide(dataC)],new DimensionMismatchException(3,2))
    assertThrownExceptionMatches([sparses1.provide(dataB) * denses2.provide(dataC)],new DimensionMismatchException(3,2)) 
    assertThrownExceptionMatches([denses1.provide(dataB)  * sparses2.provide(dataC)],new DimensionMismatchException(3,2)) 
    
    // check unsupported *= operations
    assertTypeOfThrownExceptionMatches([denses1.provide(dataB)  *= denses2.provide(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([sparses1.provide(dataB) *= sparses2.provide(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([sparses1.provide(dataB) *= denses2.provide(dataC)], new UnsupportedOperationException)
    assertTypeOfThrownExceptionMatches([denses1.provide(dataB)  *= sparses2.provide(dataC)], new UnsupportedOperationException)
    
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
