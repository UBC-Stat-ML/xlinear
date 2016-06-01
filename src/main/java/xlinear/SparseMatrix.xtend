package xlinear

import xlinear.internals.MatrixVisitorViewOnly
import xlinear.internals.MatrixVisitorEditInPlace

interface SparseMatrix extends Matrix {
    
  // note: impl should eventually include diag, band diag, Symmetric, etc
  
  /*
   * Design decision: for first version, use Colt instead of Math Commons sparse matrices,
   * because Math Commons has the artificial restriction that nRows * nCols has to 
   * be smaller than Integer.MAX_VALUE (no matter how sparse it is).
   * Colt can hold up to Integer.LONG_VALUE (but this is poorly documented), which 
   * should be more than enough; for more would need more than int's for rows and cols.
   */
  
  /**
   * Efficient traversal of non zero entries. 
   * 
   * Specific order at which these entries are visited is up to 
   * the implementation.
   * 
   * We assume the visits are done sequentially (refactor at some 
   * point with the Stream framework to give choice in future?)
   */
  def void visitNonZeros(MatrixVisitorViewOnly visitor)
  def void editNonZerosInPlace(MatrixVisitorEditInPlace visitor)
  
  override SparseMatrix createEmpty(int nRows, int nCols)
  
  //// scalar *
  
  override SparseMatrix *(Number n)   { return mul(n) }
  override SparseMatrix mul(Number n) {
    return StaticUtils::scale(this, n.doubleValue)
  }
  
  //// scalar *=
  
  override void mulInPlace(Number n) {
    StaticUtils::scaleInPlace(this, n.doubleValue)
  }
  
  //// matrix * 
  override SparseMatrix *(Matrix m)        { mul(m) }
  override SparseMatrix *(DenseMatrix m)   { mul(m) }
  override SparseMatrix *(SparseMatrix m)  { mul(m) }
  
  override SparseMatrix mul(Matrix m) {
    return Matrix.super.mul(m) as SparseMatrix
  }
  override SparseMatrix mul(DenseMatrix m) {
    return StaticUtils::multiply(this, m)
  }
  override SparseMatrix mul(SparseMatrix m) 
  
  //// +
  
  override Matrix +(Matrix m)             { add(m) }       
  override DenseMatrix +(DenseMatrix m)   { add(m) }
  override SparseMatrix +(SparseMatrix m) { add(m) }
  
  override Matrix add(Matrix m) {
    return Matrix.super.add(m)
  }
  override DenseMatrix add(DenseMatrix m) {
    return StaticUtils::add(this, m);
  }
  override SparseMatrix add(SparseMatrix m) {
    return StaticUtils::add(this, m);
  }
  
  
  //// +=
  
  override void addInPlace(DenseMatrix m) {
    StaticUtils::addInPlace(this, m)
  }
  override void addInPlace(SparseMatrix m) {
    StaticUtils::addInPlace(this, m)
  }
  
  
  //// -
  
  override Matrix -(Matrix m)             { sub(m) }       
  override DenseMatrix -(DenseMatrix m)   { sub(m) }
  override SparseMatrix -(SparseMatrix m) { sub(m) }
  
  override Matrix sub(Matrix m) {
    return Matrix.super.sub(m)
  }
  override DenseMatrix sub(DenseMatrix m) {
    return StaticUtils::subtract(this, m);
  }
  override SparseMatrix sub(SparseMatrix m) {
    return StaticUtils::subtract(this, m);
  }
  
  
  //// +=
  
  override void subInPlace(DenseMatrix m) {
    StaticUtils::subtractInPlace(this, m)
  }
  override void subInPlace(SparseMatrix m) {
    StaticUtils::subtractInPlace(this, m)
  }
  
  
  //// slices
  
  override SparseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean makeReadOnly)
  override SparseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl) {
    return Matrix.super.slice(row0Incl, row1Excl, col0Incl, col1Excl) as SparseMatrix
  }
  override SparseMatrix row(int index) {
    return Matrix.super.row(index) as SparseMatrix
  }
  override SparseMatrix col(int index) {
    return Matrix.super.col(index) as SparseMatrix
  }
  override SparseMatrix readOnlyView() {
    return Matrix.super.readOnlyView() as SparseMatrix
  }
}