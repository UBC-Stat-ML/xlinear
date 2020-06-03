package xlinear

import org.apache.commons.math3.analysis.differentiation.DerivativeStructure


import java.util.List
import org.apache.commons.math3.stat.correlation.Covariance
import xlinear.Matrix
import static extension xlinear.MatrixExtensions.*
import static  xlinear.MatrixOperations.*
import xlinear.internals.CommonsDenseMatrix
import org.apache.commons.math3.stat.descriptive.moment.Mean
import org.eclipse.xtend.lib.annotations.Data
import org.apache.commons.math3.distribution.NormalDistribution
import xlinear.AutoDiff.Differentiable
import static extension xlinear.AutoDiff.*

@Data
class DeltaMethod {
  
  /** 
   * data should be a n by p matrix where 
   * 
   * n = number of observations
   * p = number of parameters
   */
  val Matrix data 
  val Differentiable transformation
  
  @FunctionalInterface
  static interface Transformation {
    def DerivativeStructure apply(List<DerivativeStructure> arguments)
  }
  
 /**
   * Build a 95% confidence interval around the value given by estimate()
   */
  def double confidenceIntervalRadius() {
    confidenceIntervalRadius(0.95)
  }
  
  /**
   * Construct the radius of an interval I such that asymptotically in n,
   * P(Z \in I) = coverage
   * 
   * The interval is around the value given by estimate(), i.e.
   * I = [estimate - confidenceIntervalRadius, estimate + confidenceIntervalRadius]
   */
  def double confidenceIntervalRadius(double coverage) {
    if (coverage < 0.5 || coverage > 1.0)  // putting 0.5 instead of 0.0 to catch misinterpretations of input argument which is not alpha
      throw new RuntimeException
    val alpha = 1.0 - coverage
    val stdNormal = new NormalDistribution(0.0, 1.0)
    val z = stdNormal.inverseCumulativeProbability(1.0 - alpha/2.0)
    return z * Math.sqrt(asymptoticVariance / n)
  }
  
  def double estimate() {
    derivativeStructure.value
  }
  
  def double asymptoticVariance() {
    val gradient = derivativeStructure.gradient
    val result = gradient.transpose * covar(data) * gradient
    return result.doubleValue
  }
  
  def int n() { return data.nRows }
  def int p() { return data.nCols }
  
  /**
   * n = number of observations
   * p = number of parameters
   * Input: nxp matrix
   * Output: pxp covar matrix
   */
  def static Matrix covar(Matrix data) {
    return new CommonsDenseMatrix(new Covariance(data.toCommonsMatrix).covarianceMatrix)
  }
  
  def Matrix means() {
    val result = dense(p)
    for (i : 0 ..< p) {
      val m = new Mean()
      result.set(i, m.evaluate(data.col(i).vectorToArray))
    }
    return result
  }
  
  def DerivativeStructure derivativeStructure() {
    return autoDiff(means, transformation) 
  }
}