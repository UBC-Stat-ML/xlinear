package xlinear

import xlinear.internals.MatrixVisitorViewOnly
import xlinear.internals.MatrixVisitorEditInPlace
import java.util.stream.DoubleStream
import java.util.List
import java.util.ArrayList

interface SparseMatrix extends Matrix {
    
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
  
  /**
   * Default behavior for views: convert to concrete implementation 
   * and then compute the Cholesky
   */
  override cholesky() {
    return StaticUtils::convertToColtSparseMatrix(this).cholesky()
  }
  
  /**
   * Default behavior for views: convert to concrete implementation 
   * and then compute the LU
   */
  override lu() {
    return StaticUtils::convertToColtSparseMatrix(this).lu()
  }

  override inverse() {
    throw new UnsupportedOperationException(
      "Inverting a sparse matrix does not exploit sparsity.\n" +
      "Copy to dense matrix if this is really what you intend to do.")
  }
  
  override DoubleStream nonZeroEntries() {
    // TODO: memory efficiency can be improved by factor 2 here
    val List<Double> values = new ArrayList
    visitNonZeros[int row, int col, double value |
      values.add(value)
    ]
    return values.stream().mapToDouble[doubleValue]
  }
  
  override SparseMatrix transpose() {
    val SparseMatrix result = createEmpty(nCols, nRows)
    visitNonZeros[int row, int col, double value |
      result.set(col, row, value)
    ]
    return result
  }
  
  //// scalar * or /
  
  override SparseMatrix *(Number n)   { return mul(n) }
  override SparseMatrix mul(Number n) {
    return StaticUtils::scale(this, n.doubleValue)
  }
  
  override SparseMatrix /(Number n) { return div(n) }
  override SparseMatrix div(Number n) {
    return mul(1.0/n)
  }
  
  //// scalar *=
  
  override void mulInPlace(Number n) {
    StaticUtils::scaleInPlace(this, n.doubleValue)
  }
  
  //// matrix * 
  override Matrix *(Matrix m)              { mul(m) }
  override DenseMatrix *(DenseMatrix m)    { mul(m) }
  override SparseMatrix *(SparseMatrix m)  { mul(m) }
  
  override DenseMatrix mul(DenseMatrix m) {
    return StaticUtils::multiply(this, m)
  }
  override SparseMatrix mul(SparseMatrix m) 
  
  //// +
  
  override Matrix +(Matrix m)             { add(m) }       
  override DenseMatrix +(DenseMatrix m)   { add(m) }
  override SparseMatrix +(SparseMatrix m) { add(m) }
  
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