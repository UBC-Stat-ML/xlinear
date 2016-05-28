package xlinear.internals

@FunctionalInterface
interface MatrixVisitorEditInPlace {
  def double editInPlace(int row, int col, double currentValue)
}