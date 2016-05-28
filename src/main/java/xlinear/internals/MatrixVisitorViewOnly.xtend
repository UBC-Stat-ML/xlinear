package xlinear.internals

@FunctionalInterface 
public interface MatrixVisitorViewOnly {
  def void visit(int row, int col, double currentValue)
}
