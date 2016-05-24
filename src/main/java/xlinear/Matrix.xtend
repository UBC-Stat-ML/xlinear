package xlinear



/**
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
interface Matrix {
	
  def int nRows()
  def int nCols()
  
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