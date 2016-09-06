package xlinear

import xlinear.internals.MatrixVisitorViewOnly
import xlinear.internals.MatrixVisitorEditInPlace
import java.util.stream.DoubleStream
import java.util.stream.IntStream

interface DenseMatrix extends Matrix {
    
  // note: impl should eventually include Symmetric, etc
  
  /**
   * Efficient traversal of all entries. 
   * 
   * Specific order at which these entries are visited is up to 
   * the implementation.
   */
  def void visit(MatrixVisitorViewOnly visitor)
  def void editInPlace(MatrixVisitorEditInPlace visitor)
  
  override DenseMatrix createEmpty(int nRows, int nCols)
    
  override CholeskyDecomposition cholesky() {
    return StaticUtils::convertToCommonsDenseMatrix(this).cholesky()
  }
  
  override DenseMatrix transpose() {
    val DenseMatrix result = createEmpty(nCols, nRows)
    result.editInPlace[int row, int col, double value |
      return this.get(col, row)
    ]
    return result
  }
  
  override DoubleStream nonZeroEntries() {
    val DoubleStream result = 
      if (isVector) {
        IntStream.range(0, nEntries).mapToDouble[int entry | this.get(entry)]
      } else {
        IntStream.range(0, nRows).mapToObj[int row | this.row(row)].flatMapToDouble[Matrix rowMatrix | rowMatrix.nonZeroEntries()]
      }
    return result.filter[double entry | entry != 0.0]
  }
  
  //// scalar * 
  
  override DenseMatrix *(Number n)   { return mul(n) }
  override DenseMatrix mul(Number n) {
    return StaticUtils::scale(this, n.doubleValue)
  }
  
  //// scalar *=
  
  override void mulInPlace(Number n) {
    StaticUtils::scaleInPlace(this, n.doubleValue)
  }
  
  //// matrix * 
  
  override DenseMatrix *(Matrix m)        { mul(m) }       
  override DenseMatrix *(DenseMatrix m)   { mul(m) }
  override DenseMatrix *(SparseMatrix m)  { mul(m) }
  
  override DenseMatrix mul(Matrix m) {
    return Matrix.super.mul(m) as DenseMatrix
  }
  override DenseMatrix mul(DenseMatrix m) 
  override DenseMatrix mul(SparseMatrix m) {
    return StaticUtils::multiply(this, m)
  }
  
  //// +
  
  override DenseMatrix +(Matrix m)       { add(m) }       
  override DenseMatrix +(DenseMatrix m)  { add(m) }
  override DenseMatrix +(SparseMatrix m) { add(m) }
  
  override DenseMatrix add(Matrix m) {
    return Matrix.super.add(m) as DenseMatrix
  }
  override DenseMatrix add(DenseMatrix m) {
    return StaticUtils::add(this, m)
  }
  override DenseMatrix add(SparseMatrix m) {
    return StaticUtils::add(m, this);
  }
  
  
  //// +=
  
  override void addInPlace(DenseMatrix m) {
    StaticUtils::addInPlace(this, m)
  }
  override void addInPlace(SparseMatrix m) {
    StaticUtils::addInPlace(this, m)
  }
  
  
  //// -
  
  override DenseMatrix -(Matrix m)       { sub(m) }       
  override DenseMatrix -(DenseMatrix m)  { sub(m) }
  override DenseMatrix -(SparseMatrix m) { sub(m) }
  
  override DenseMatrix sub(Matrix m) {
    return Matrix.super.sub(m) as DenseMatrix
  }
  override DenseMatrix sub(DenseMatrix m) {
    return StaticUtils::subtract(this, m)
  }
  override DenseMatrix sub(SparseMatrix m) {
    return StaticUtils::subtract(this, m);
  }
  
  //// -=
  
  override void subInPlace(DenseMatrix m) {
    StaticUtils::subtractInPlace(this, m)
  }
  override void subInPlace(SparseMatrix m) {
    StaticUtils::subtractInPlace(this, m)
  }
  
  
  //// slices
  
  override DenseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl, boolean readOnly)
  override DenseMatrix slice(int row0Incl, int row1Excl, int col0Incl, int col1Excl) {
    return Matrix.super.slice(row0Incl, row1Excl, col0Incl, col1Excl) as DenseMatrix
  }
  override DenseMatrix row(int index) {
    return Matrix.super.row(index) as DenseMatrix
  }
  override DenseMatrix col(int index) {
    return Matrix.super.col(index) as DenseMatrix
  }
  override DenseMatrix readOnlyView() {
    return Matrix.super.readOnlyView() as DenseMatrix
  }
}