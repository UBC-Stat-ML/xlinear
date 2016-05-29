package xlinear.internals

@FunctionalInterface
interface MatrixVisitorEditInPlace {
  /**
   * Return the value to be written in place of currentValue
   */
  def double editInPlace(int row, int col, double currentValue)
}