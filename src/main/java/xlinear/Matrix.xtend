package xlinear



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
  
  def CholeskyDecomposition cholesky()
  def Matrix transpose()
  
  //// scalar *
  
  def Matrix *(Number n)
  def Matrix mul(Number n)
  
  
  //// scalar *=
  
  def void *=(Number n) { mulInPlace(n) }
  def void mulInPlace(Number n)
  
  //// matrix *
  
  def Matrix *(Matrix m)
  def DenseMatrix *(DenseMatrix m)
  def Matrix *(SparseMatrix m)
  
  def Matrix mul(Matrix m) {
    switch m {
      SparseMatrix  : return mul(m)
      DenseMatrix   : return mul(m)
      default :
        throw StaticUtils::denseOrSparseException
    }
  }
  def DenseMatrix mul(DenseMatrix m)
  def Matrix mul(SparseMatrix m)
  
  
  //// matrix *= : not supported as efficient implementations used here typically 
  ////             need an extra matrix anyways
  
  //// +
  
  def Matrix +(Matrix m)         
  def DenseMatrix +(DenseMatrix m)  
  def Matrix +(SparseMatrix m) 
  
  def Matrix add(Matrix m) {
    switch m {
      SparseMatrix : return add(m)
      DenseMatrix  : return add(m)
      default :
        throw StaticUtils::denseOrSparseException
    }
  }
  def DenseMatrix add(DenseMatrix m)
  def Matrix add(SparseMatrix m)
  
  //// +=
  
  def void +=(Matrix m)       { addInPlace(m) }
  def void +=(DenseMatrix m)  { addInPlace(m) }
  def void +=(SparseMatrix m) { addInPlace(m) }
  
  def void addInPlace(Matrix m) {
    switch m {
      DenseMatrix  : addInPlace(m)
      SparseMatrix : addInPlace(m)
      default :
        throw StaticUtils::denseOrSparseException
    }
  }
  def void addInPlace(DenseMatrix m)
  def void addInPlace(SparseMatrix m)
  
  //// -
  
  def Matrix -(Matrix m)         
  def DenseMatrix -(DenseMatrix m)  
  def Matrix -(SparseMatrix m) 
  
  def Matrix sub(Matrix m) {
    switch m {
      SparseMatrix : return sub(m)
      DenseMatrix  : return sub(m)
      default :
        throw StaticUtils::denseOrSparseException
    }
  }
  def DenseMatrix sub(DenseMatrix m)
  def Matrix sub(SparseMatrix m)
  
  
  //// -=
  
  def void -=(Matrix m)       { subInPlace(m) }
  def void -=(DenseMatrix m)  { subInPlace(m) }
  def void -=(SparseMatrix m) { subInPlace(m) }
  
  def void subInPlace(Matrix m) {
    switch m {
      DenseMatrix  : subInPlace(m)
      SparseMatrix : subInPlace(m)
      default :
        throw StaticUtils::denseOrSparseException
    }
  }
  def void subInPlace(DenseMatrix m)
  def void subInPlace(SparseMatrix m)
  
  // TODO: offer implementations of equals, hashcode (use visitSkipSomeZeros? which you may want to add here in interface, or not needed actually)
  // TODO: same for toString, with options to limit # of entries
  
}

