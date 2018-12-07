package xlinear.internals

import xlinear.SparseMatrix
import org.eclipse.xtend.lib.annotations.Data
import cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D
import xlinear.StaticUtils
import cern.colt.matrix.tdouble.DoubleMatrix2D
import xlinear.CholeskyDecomposition
import xlinear.Matrix
import cern.colt.matrix.tdouble.impl.DenseDoubleMatrix1D
import xlinear.MatrixOperations
import xlinear.CholeskyDecomposition.SolverMode
import xlinear.LUDecomposition
import cern.colt.matrix.tdouble.algo.decomposition.SparseDoubleLUDecomposition
import xlinear.CholeskyDecomposition.CholeskySolver
import xlinear.LUDecomposition.LUSolver
import cern.colt.matrix.tdouble.algo.decomposition.CSparseDoubleLUDecomposition

/*
 * Design decision: for first version, use Colt instead of Math Commons sparse matrices,
 * because Math Commons has the artificial restriction that nRows * nCols has to 
 * be smaller than Integer.MAX_VALUE (no matter how sparse it is).
 * Colt can hold up to Long.LONG_VALUE (but this is poorly documented), which 
 * should be more than enough; for more would need more than int's for rows and cols.
 */
@Data class ColtSparseMatrix implements SparseMatrix {
  
  val DoubleMatrix2D implementation
  
  override void visitNonZeros(MatrixVisitorViewOnly visitor) {
    implementation.forEachNonZero[int row, int col, double value |
      visitor.visit(row, col, value)
      return value
    ]
  }
  
  override void editNonZerosInPlace(MatrixVisitorEditInPlace visitor) {
    implementation.forEachNonZero[int row, int col, double value |
      return visitor.editInPlace(row, col, value)
    ]
  }
  
  override ColtSparseMatrix createEmpty(int nRows, int nCols) {
    return new ColtSparseMatrix(new SparseDoubleMatrix2D(nRows, nCols))
  }
  
  override SparseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean readOnly) {
    StaticUtils::checkValidSlice(this, row0Incl, row1Excl, col0Incl, col1Excl)
    return new ColtSparseMatrixSlice(this, row0Incl, row1Excl, col0Incl, col1Excl, readOnly)
  }
  
  override ColtSparseMatrix mul(SparseMatrix another) {
    StaticUtils::checkMatrixMultiplicationDimensionsMatch(this, another)
    // TODO: if big, attempt JEigen?
    switch another {
      ColtSparseMatrix : {
        val ColtSparseMatrix result = createEmpty(nRows, another.nCols)
        implementation.zMult(another.implementation, result.implementation)
        return result
      }
      default :  // TODO: if small, use default implementation instead?
        return mul(StaticUtils::convertToColtSparseMatrix(another)) 
    }
  }
  
  override CholeskyDecomposition cholesky() {
    StaticUtils::checkMatrixIsSquare(this) 
    // TODO: attempt to use JEigen if matrix is large
    switch implementation {
      SparseDoubleMatrix2D : {
        try {
          val CustomizedColtSparseDoubleCholesky chol = 
            new CustomizedColtSparseDoubleCholesky(
                implementation.getColumnCompressed(false), 0)
          val SparseMatrix L = new ColtSparseMatrix(chol.l)
          return new CholeskyDecomposition(L.readOnlyView, new SparseCholeskySolver(chol))
        } catch (IllegalArgumentException iae) {
          throw StaticUtils::notSymmetricPosDef
        }
      }
      default :
        return StaticUtils::convertToColtSparseMatrix(this).cholesky()
    }
  }
  
  override LUDecomposition lu() {
    StaticUtils::checkMatrixIsSquare(this) 
    // TODO: attempt to use JEigen if matrix is large
    switch implementation {
      SparseDoubleMatrix2D : {
        val SparseDoubleLUDecomposition lu = 
          new CSparseDoubleLUDecomposition(
              implementation.getColumnCompressed(false), 0, true)
        val SparseMatrix L = new ColtSparseMatrix(lu.l)
        val SparseMatrix U = new ColtSparseMatrix(lu.u)
        return new LUDecomposition(L.readOnlyView, U.readOnlyView, new SparseLUSolver(lu))
      }
      default :
        return StaticUtils::convertToColtSparseMatrix(this).lu()
    }
  }
  
  @Data
  private static class SparseCholeskySolver implements CholeskySolver {
    val CustomizedColtSparseDoubleCholesky implementation   
    override solve(Matrix b, SolverMode mode) {
      if (!b.isVector()) 
        throw StaticUtils::notAVectorException
      val DenseDoubleMatrix1D copy = new DenseDoubleMatrix1D(b.nEntries)
      for (var int i = 0; i < b.nEntries; i++) {
        copy.set(i, b.get(i))
      }
      implementation.solve(copy, mode)
      return MatrixOperations::denseCopy(copy.toArray)
    }
  }
  
  @Data
  private static class SparseLUSolver implements LUSolver {
    val SparseDoubleLUDecomposition implementation   
    override solve(Matrix b) {
      if (!b.isVector()) 
        throw StaticUtils::notAVectorException
      val DenseDoubleMatrix1D copy = new DenseDoubleMatrix1D(b.nEntries)
      for (var int i = 0; i < b.nEntries; i++) {
        copy.set(i, b.get(i))
      }
      implementation.solve(copy)
      return MatrixOperations::denseCopy(copy.toArray)
    }
  }
  
  override int nRows() {
    return implementation.rows
  }
  
  override int nCols() {
    return implementation.columns
  }
  
  override double get(int row, int col) {
    StaticUtils::checkBounds(this, row, col)
    implementation.get(row, col)
  }
  
  override void set(int row, int col, double v) {
    StaticUtils::checkBounds(this, row, col)
    implementation.set(row, col, v)
  }
  
  override String toString() {
    // TODO: use views to truncate
    return StaticUtils::toStringDimensions(this) + " sparse matrix\n" + StaticUtils::toString(this)
  }
  
  private static class ColtSparseMatrixSlice extends Slice implements SparseMatrix {
    
    def private ColtSparseMatrix root() {
      return rootMatrix as ColtSparseMatrix
    }
    
    new(ColtSparseMatrix rootMatrix, int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean readOnly) {
      super(rootMatrix, row0Incl, row1Excl, col0Incl, col1Excl, readOnly)
    }
    
    override SparseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Incl, boolean subSliceReadOnly) {
      super.slice(row0Incl, row1Excl, col0Incl, col1Incl, subSliceReadOnly) as SparseMatrix
    }
    
    override void visitNonZeros(MatrixVisitorViewOnly visitor) {
      if (nRows * nCols < root().implementation.cardinality) {
        // optimization for small slices
        for (var int row = 0; row < nRows; row++) {
          for (var int col = 0; col < nCols; col++) {
            val value = get(row, col)
            if (value != 0.0) {
              visitor.visit(row, col, value)
            }
          }
        }
      } else {
        root().visitNonZeros[int row, int col, double value |
          if (row >= row0Incl && row < row1Excl &&
              col >= col0Incl && col < col1Excl)
            visitor.visit(
              rowRoot2Slice(row), 
              colRoot2Slice(col), 
              value
            )
        ] 
      }
    }
    
    override void editNonZerosInPlace(MatrixVisitorEditInPlace visitor) {
      if (readOnly) {
        throw new UnsupportedOperationException
      }
      if (nRows * nCols < root().implementation.cardinality) {
        // optimization for small slices
        for (var int row = 0; row < nRows; row++) {
          for (var int col = 0; col < nCols; col++) {
            val value = get(row, col)
            if (value != 0.0) {
              set(row, col, visitor.editInPlace(row, col, value))
            }
          }
        }
      } else {
        root().editNonZerosInPlace[int row, int col, double value |
          if (row >= row0Incl && row < row1Excl &&
              col >= col0Incl && col < col1Excl)
            return visitor.editInPlace(
              rowRoot2Slice(row), 
              colRoot2Slice(col), 
              value
            )
          else
            return value
        ]
      }
    }
    
    override SparseMatrix createEmpty(int nRows, int nCols) {
      return root().createEmpty(nRows, nCols)
    }
    
    override SparseMatrix mul(SparseMatrix another) {
      // The cost of copying is negligible for matrix multiplication
      val SparseMatrix copy = StaticUtils::copy(this)
      return copy.mul(another)
    }
    
    override String toString() {
      // TODO: use views to truncate (ALSO IN VIEW AND SPARSE AND DENSE)
      return StaticUtils::toStringDimensions(this) + " sparse matrix" + 
        (if (readOnly) " read-only" else "") + 
        " slice\n" + StaticUtils::toString(this)
    }
  }
}