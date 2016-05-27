package xlinear

import org.apache.commons.math3.linear.RealMatrix
import org.apache.commons.math3.linear.SparseRealMatrix

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
 *      implementations do (so that samplers can be defined)
 *  - Basic sparse matrix features (needed for Sparse precision Gaussian)
 *  - Start with MathCommons instead of JBlas for dense
 *      (will need for fallback anyways, and it's 4-5x faster for 2x2 matrices)
 *  - Implementation of the interface should take minimal effort 
 *      (examples of use case: designing simplex vector distribution, matrix of Dirichlets, etc)
 * 
 * Not needed in first release:
 *  - Only double storage offered, float less reliable for probabilistic inference
 *  - Complex support not so useful for probabilistic inference?
 *  - Avoid separate Vector, SquareMatrix, etc. 
 *    - Type checker is not good enough to cover all cases.
 *    - Marginal utility of having partial coverage. Just check at runtime. 
 *    - Instead, use dispatch functions for dot(.,.), chol(.), etc
 * 
 * Design notes:
 *  - Immutability: 
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
 * TODO: add instructions on how to sub-class.
 */
interface Matrix {
	
  def int nRows()
  def int nCols()
  
  def double get(int row, int col)
  def void set(int row, int col, double v)
  
  /**
   * Human readable output. Not recommended for storing to file as 
   * precision is truncated and implementation is not geared for 
   * high throughput.
   */
  override String toString()
  
  /*
    Design note: we are with-holding
      def double get(int rowIndex, int colIndex)
    Since this would encourage sub-classing Matrix, 
    which is not the preferred hook for custom sub-classes 
    Also, it commits to a storage strategy and to is not a 
    good fit for sparse matrices anyways (might be inefficient).
    Often time we do not care about individual entries anyways.
    What matter is operators on matrices.
  */
    
//  def RealMatrix implementation()
//  
//  static interface SparseMatrix extends Matrix {
//  	
//  	override SparseRealMatrix implementation()
//  	
//  }
//  
//  lessons learned tonight:
//    - need dispatch (e.g. normal will have a Matrix precision)
//    - proposed hierarchy:
//        ComplexMatrix
//        final Matrix [with only nRows, nCols, Object impl]; impl can be:
//          DenseMatrix  [with only a RealMatrix impl]
//          SparseMatrix [with only a SparseDoubleMatrix impl; eg need .det and x M xt]
//          
//    - imp. question: need to think about how this will work for sampler (eg. for a dirichlet-constructed transition matrix)
  
  
  // this could be dangerous in an init block..; or just inefficient
  // but this might be ok
  // also, does commit to double-backed 
  // also, might be inefficient in sparse cases
  // def double get(int row, int col)
  
//  static interface SparseMatrix extends Matrix {
//    
//    // TODO
//  	
//  }
  
//  static interface DenseDoubleMatrix extends Matrix {
//    
//    def double get(int row, int col)
//    
//  }

  
  


  
}