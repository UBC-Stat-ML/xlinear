package xlinear


/*
 * Design notes
 * 
 * Objective: a matrix library for the xblang probabilistic programming language.
 * 
 * General design goals:
 *  1. simplicity
 *  2. all features needed for design of probability models should be offered
 *  3. reasonable performance
 * 
 * Features decisions for first release:
 *  - Support overloading of +,-,*
 *  - All dense matrix common operations, functions, decompositions
 *  - Views into entries
 *  - Mutability: interfaces used in model building does not allow modif, 
 *      implementations do (so that samplers can be defined) <- skip this?
 *  - Basic sparse matrix features (needed for Sparse precision Gaussian)
 *  - Start with MathCommons instead of JBlas for dense
 *      (will need for fallback anyways, and it's 4-5x faster for 2x2 matrices)
 *  - Implementation of the interface should take minimal effort 
 *      (examples of use case: designing simplex vector distribution, matrix of Dirichlets, etc)
 * 
 * Not needed in first release:
 *  - Only double storage offered, float less reliable for probabilistic inference
 *  - Complex support not so useful for probabilistic inference? also better get them via composition A + i * B
 *  - Avoid separate Vector, SquareMatrix, etc. 
 *    - Type checker is not good enough to cover all cases.
 *    - Marginal utility of having partial coverage. Just check at runtime. 
 *    - Instead, use dispatch functions for dot(.,.), chol(.), etc
 * 
 * Design notes:
 *  - Difficulty in previous package is that there are theoretically several axes to pack in the
 *    class hierarchy: (double/float x real/complex) x vec/sqr/general/colVec x storage strategies(dense/sparse/..)
 *    - Type erasure makes it hard to approach in a generic framework
 *    - Resorting to unwindy class names is not user friendly and lead to bloated code bases
 *    - Solution in our case: only the storage strategy axis really matters
 * 
 */
  
/**
 * Note: it is not recommended that the user implements this interface
 *   directly, since many operators depend on more detailed knowledge of 
 *   the implementation for efficiency, in particular if the matrix is dense
 *   or sparse. So we assume at many places a finite number of direct sub-classes 
 *   of this interface.
 * 
 * TODO: add instructions on how to sub-class, by using DenseMatrix or SparseMatrix
 */
interface Matrix { 
  
  def Matrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean makeReadOnly) 
  
  def Matrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl) {
    return slice(row0Incl, row1Excl, col0Incl, col1Excl, false)
  }
  def Matrix row(int index) {
    return slice(index, index + 1, 0, nCols, false)
  }
  def Matrix col(int index) {
    return slice(0, nRows, index, index + 1, false)
  }
  def Matrix readOnlyView() {
    return slice(0, nRows, 0, nCols, true)
  }
  
  def int nRows()
  def int nCols()

  def double get(int row, int col)
  def void set(int row, int col, double v)
  
  def Matrix createEmpty(int nRows, int nCols)
  
  static interface SliceProducer<T extends Matrix> {
    def int nRows()
    def int nCols()
    def T slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean makeReadOnly)
    def T slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl) {
      return slice(row0Incl, row1Excl, col0Incl, col1Excl, false)
    }
    def T row(int index) {
      return slice(index, index + 1, 0, nCols, false)
    }
    def Matrix col(int index) {
      return slice(0, nRows, index, index + 1, false)
    }
    def Matrix readOnlyView() {
      return slice(0, nRows, 0, nCols, true)
    }
  }
  
  // TODO: offer implementations of equals, hashcode (use visitSkipSomeZeros? which you may want to add here in interface, or not needed actually)
  // TODO: same for toString, with options to limit # of entries
  
}

