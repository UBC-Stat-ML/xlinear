package xlinear

import org.jblas.DoubleMatrix
import com.google.common.base.Stopwatch
import java.util.concurrent.TimeUnit
import org.apache.commons.math3.linear.RealMatrix
import org.apache.commons.math3.linear.BlockRealMatrix
import org.apache.commons.math3.linear.Array2DRowRealMatrix
import org.apache.commons.math3.linear.AbstractRealMatrix

//import static extension xlinear.MatrixOperators

// make abstract Matrix with as root

import static extension xlinear.MatrixOperations.*
import org.ojalgo.matrix.store.PhysicalStore
import org.ojalgo.matrix.store.PrimitiveDenseStore
import org.ojalgo.random.Weibull
import org.ojalgo.matrix.store.SparseStore
import cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D
import cern.colt.matrix.tdouble.impl.DenseDoubleMatrix2D

class Demo {
  


  def static void main(String [] args) {
    
    val m = new SparseDoubleMatrix2D(100000,100000)
    
    println("ok")
    
//    test(null)
//    
//    val anotherSp = new SparseDoubleMatrix2D(100000, 100000)
//    val anotherSp2 = new SparseDoubleMatrix2D(100000, 100000)
//    val anotherSp3 = new SparseDoubleMatrix2D(100000, 100000)
//    
//    anotherSp.zMult(anotherSp2,anotherSp3)
//    
//    println("ok")
//    
////    val spMtx = SparseStore.PRIMITIVE.make(100000, 100000)
////    val spMtx2 = SparseStore.PRIMITIVE.make(100000, 100000)
////    
////    spMtx.multiply(spMtx2).get
//    
//    println("ok")
    
//    val mtx = matrix(
//      #[
//        #[1, 2], 
//        #[3, 4]
//      ]
//    )
//    
//    val mtx2 = inv(mtx)
//    
//    var mtx3 = mtx2*mtx2 + 2*mtx
//    mtx3 += mtx2
//    
//    println(mtx3)
//    
//    val aSparseOne = sparse(10000, 10000)
//    val anotherSparseOne = sparse(10000, 10000)
//    
//    val sum = anotherSparseOne + aSparseOne
//    
//    
//    
//    println("done!")
//    
//    if (true) return; 
    
    
//    var m1 = matrix(#[#[1, 2], #[3, 4]])
//    
//    println(m1)
//    
//    m1 += m1
    
//    println(m1)
    
    val size = 200
    val rep = 100
    
    for (var j = 0; j < 3; j++) {
      val test = DoubleMatrix::zeros(size,size)
      test.put(0,0,1)
      test.put(0,1,2)
      test.put(1,0,3)
      test.put(1,1,4)
      
      var Stopwatch watch
      
      var RealMatrix test2
      
      println("COLT")
      
      val DenseDoubleMatrix2D ddm2d = new DenseDoubleMatrix2D(test.toArray2)
      watch = Stopwatch::createStarted
      for (var i = 0; i < rep; i++) {
        val another = ddm2d.copy
        another.zMult(another, ddm2d)
      }
      println(watch.elapsed(TimeUnit::MILLISECONDS))
      
      println("eigen")
      
      val jeigen.DenseMatrix dm1 = jeigen.DenseMatrix::zeros(size, size)
      watch = Stopwatch::createStarted
      for (var i = 0; i < rep; i++)
        dm1.mmul(dm1)
      println(watch.elapsed(TimeUnit::MILLISECONDS))
      
      
      println("JBlas")
      
      watch = Stopwatch::createStarted
      for (var i = 0; i < rep; i++)
        test.mmul(test)
      println(watch.elapsed(TimeUnit::MILLISECONDS))
      
//      println("Array2D")
//      
//      var AbstractRealMatrix test2 = new Array2DRowRealMatrix(test.toArray2)
//      watch = Stopwatch::createStarted
//      for (var i = 0; i < 10; i++)
//        test2.multiply(test2)
//      println(watch.elapsed(TimeUnit::MILLISECONDS)) 
      
      println("Block")
      
      test2 = new BlockRealMatrix(test.toArray2)
      watch = Stopwatch::createStarted
      for (var i = 0; i < rep; i++)
        test2.multiply(test2)
      println(watch.elapsed(TimeUnit::MILLISECONDS)) 
      
//      println("us")
//      
//      var m1 = matrix(#[#[1, 2], #[3, 4]])
//      
//      watch = Stopwatch::createStarted
//      for (var i = 0; i < 10; i++)
//        m1 * m1
//      println(watch.elapsed(TimeUnit::MILLISECONDS)) 
      
      
      println("ojAlgo")
      
          
      val PhysicalStore.Factory<Double, PrimitiveDenseStore> tmpFactory = PrimitiveDenseStore.FACTORY;
      val anotherMtx = tmpFactory.makeEye(size, size)
    
      watch = Stopwatch::createStarted
      for (var i = 0; i < rep; i++) {
//        val oneMore = tmpFactory.makeEye(size, size)
//        anotherMtx.fillByMultiplying(oneMore, oneMore);
        val oneMore = tmpFactory.makeEye(size, size)
        anotherMtx.multiplyLeft(oneMore).get
      }
      println(watch.elapsed(TimeUnit::MILLISECONDS)) 
      
      println("----")
      
    }
  
  }
  
//  def DoubleMatrix +(DoubleMatrix m1, DoubleMatrix m2) {
//    m1.add(m2)
//  }
//  
//  def DoubleMatrix *(Number scalar, DoubleMatrix m) {
//    m.mul(scalar.doubleValue)
//  }
//  
//  def DoubleMatrix *(DoubleMatrix m, Number scalar) {
//    operator_multiply(scalar, m)
//  }
//  
//  def DoubleMatrix *(DoubleMatrix m1, DoubleMatrix m2) {
//    m1.mmul(m2)
//  }
//  
//  def DoubleMatrix +=(DoubleMatrix m1, DoubleMatrix m2) {
//    m1.addi(m2)
//  }
//  
//  def DoubleMatrix *=(DoubleMatrix m1, DoubleMatrix m2) {
//    m1.mmuli(m2)
//  }
//  
//  def DoubleMatrix *=(DoubleMatrix m1, Number scalar) {
//    m1.muli(scalar.doubleValue)
//  }
//  
//  def run() {
//    
//    for (var j = 0; j < 3; j++) {
//      val test = DoubleMatrix::zeros(2,2)
//      
//      println("JBlas")
//      
//      var watch = Stopwatch::createStarted
//      for (var i = 0; i < 1000000; i++)
//        test.mmul(test)
//      println(watch.elapsed(TimeUnit::MILLISECONDS))
//      
//      println("Array2D")
//      
//      var AbstractRealMatrix test2 = new Array2DRowRealMatrix(test.toArray2)
//      watch = Stopwatch::createStarted
//      for (var i = 0; i < 1000000; i++)
//        test2.multiply(test2)
//      println(watch.elapsed(TimeUnit::MILLISECONDS)) 
//      
//      println("Block")
//      
//      test2 = new BlockRealMatrix(test.toArray2)
//      watch = Stopwatch::createStarted
//      for (var i = 0; i < 1000000; i++)
//        test2.multiply(test2)
//      println(watch.elapsed(TimeUnit::MILLISECONDS)) 
//    }
//    
////    while (true) {
////      var DoubleMatrix m = DoubleMatrix::ones(2,2)
////      
////      m += m * m
////      
////      m *= 5
////      
////    }    
//  }
//  
//  def static void main(String [] args) {
//    new Demo().run
//  }
//  
////  static class NaiveMtx {
////    double[] data
////    new() {
////      data = newDoubleArrayOfSize(4)
////    } 
////    
////    override toString() {
////      Arrays.toString(data)
////    }
////    
////  }
////  
////  def static void main(String [] args) {
////    new Demo().run()
////  }
////  
////  def void run() {
////    
////    "Hello".say("Bastien")
////    
////    var NaiveMtx m = new NaiveMtx
////    m.data.set(0,1)
////    
////    m = m + m
////    
////    println(m)
////  }
////  
////  def void say(String s, String name) {
////    println(s + " " + name)
////  }
////  
////  def NaiveMtx +(NaiveMtx mtx1, NaiveMtx mtx2) {
////    val mtx = new NaiveMtx()
////    for (var i = 0; i < 4; i++)
////      mtx.data.set(i, mtx1.data.get(i) + mtx1.data.get(i))
////    return mtx
////  }
  
  
}