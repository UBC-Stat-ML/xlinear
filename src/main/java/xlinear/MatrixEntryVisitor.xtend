package xlinear

@FunctionalInterface
interface MatrixEntryVisitor {
  def double visit(int row, int col, double currentValue)
}