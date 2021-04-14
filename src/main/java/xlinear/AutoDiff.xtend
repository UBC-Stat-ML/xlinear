package xlinear

import org.apache.commons.math3.analysis.differentiation.DerivativeStructure
import static xlinear.MatrixOperations.*
import xlinear.DenseMatrix
import xlinear.Matrix
import java.util.List
import java.util.ArrayList

class AutoDiff {
  
  /**
   * A variation on Common's MultivariateDifferentiableFunction
   * which is more straightforward to implement
   */
  @FunctionalInterface
  static interface Differentiable {
    def DerivativeStructure apply(List<DerivativeStructure> arguments)
  }
  
  def static DerivativeStructure autoDiff(Matrix point, Differentiable function) {
    autoDiff(point, 1, function)
  }
  
  def static DerivativeStructure autoDiff(Matrix point, int order, Differentiable function) {
    val dim = point.nEntries
    val List<DerivativeStructure> args = new ArrayList(dim)
    for (i : 0 ..< dim)
      args.add(new DerivativeStructure(dim, order, i, point.get(i)))
    return function.apply(args) 
  }

  
  def static DenseMatrix gradient(Matrix point, Differentiable f) {
    return gradient(autoDiff(point, f))
  }
  
  def static DenseMatrix gradient(DerivativeStructure structure) {
    val p = structure.freeParameters
    val result = dense(p)
    val indices = newIntArrayOfSize(p)
    for (i : 0 ..< p) {
      if (i > 0) indices.set(i-1,0)
      indices.set(i, 1)
      result.set(i, structure.getPartialDerivative(indices)) 
    }
    return result
  }
  
  def static DerivativeStructure *(Number a, DerivativeStructure x) {
    return x.multiply(a.doubleValue) 
  }
  
  def static DerivativeStructure *(DerivativeStructure x, DerivativeStructure y) {
    return x.multiply(y) 
  }
  
  def static DerivativeStructure *(DerivativeStructure x, Number a) {
    return x.multiply(a.doubleValue)
  }
  
  def static DerivativeStructure +(DerivativeStructure x, DerivativeStructure y) {
    return x.add(y) 
  }
  
  def static DerivativeStructure +(Number a, DerivativeStructure x) {
    return x.add(a.doubleValue) 
  }
  
  def static DerivativeStructure +(DerivativeStructure x, Number a) {
    return x.add(a.doubleValue) 
  }
  
  def static DerivativeStructure -(DerivativeStructure x, DerivativeStructure y) {
    return x.add(y.negate)
  }
  
  def static DerivativeStructure -(DerivativeStructure x, Number a) {
    return x.add(-a.doubleValue)
  }
  
  def static DerivativeStructure -(Number a, DerivativeStructure x) {
    return x.negate.add(a.doubleValue)
  }
  
  def static DerivativeStructure /(DerivativeStructure x, DerivativeStructure y) {
    return x.divide(y)
  }
  
  def static DerivativeStructure /(DerivativeStructure x, Number a) {
    return x.divide(a.doubleValue)
  }
  
  def static DerivativeStructure /(Number a, DerivativeStructure y) {
    y.reciprocal.multiply(a.doubleValue)
  }
}