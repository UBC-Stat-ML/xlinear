package xlinear

import org.junit.Test

import static xlinear.MatrixOperations.*
import static extension java.lang.Math.*
import static extension xlinear.MatrixExtensions.*

import static extension xlinear.AutoDiff.*


class TestMathCommonsAutoDiff {
  
  @Test
  def void test() {
    val point = denseCopy(#[1.5, 2.9])
    val auto = autoDiff(point)[
      val x = get(0)
      val y = get(1)
      return  x.pow(y) - x*y / 5
    ]
    val grad = gradient(auto)
    println(grad)
    println(analyticDx(point.get(0), point.get(1)))
    println(analyticDy(point.get(0), point.get(1)))
  }
  
  def analyticDx(double x, double y) {
    y * (x.pow(y - 1) - 1.0/5.0)
  }
  
  def analyticDy(double x, double y) {
    x.pow(y) * log(x) - x/5
  }
}