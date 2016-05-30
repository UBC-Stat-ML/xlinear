package xlinear;


import tutorialj.Tutorial;

import static xlinear.MatrixOperations.*;

import org.junit.Test;


public class Doc
{
  /**
   * 
   * Summary [![Build Status](https://travis-ci.org/alexandrebouchard/xlinear.png?branch=master)](https://travis-ci.org/alexandrebouchard/xlinear)
   * -------
   * 
   * There are several excellent linear algebra libraries for Java, but they generally have a 
   * high learning curve compared to Matlab/Numpy/Julia.
   * 
   * This library uses the best of several of these under hood (Apache Commons, parallel COLT, and JEigen), 
   * but exposes only a simple API that will be familiar to Matlab/Numpy/Julia users.
   * 
   * Both dense and sparse matrices are supported. The library is fully compatible with both 
   * Java and Xtend, the only advantage of the latter being that operator overloading allows 
   * you to write expressions like ``A * B + 2 * C`` or ``C += D``, etc. Otherwise, the API 
   * is the same in the two languages (the library itself is written in Xtend, which gets compiled 
   * into readable Java code).
   * 
   * 
   * Installation
   * ------------
   * 
   * There are several options available to install the package:
   * 
   * ### Integrate to a gradle script
   * 
   * Simply add the following lines (replacing 1.0.0 by the current version (see git tags)):
   * 
   * ```groovy
   * repositories {
   *  mavenCentral()
   *  jcenter()
   *  maven {
   *     url "http://www.stat.ubc.ca/~bouchard/maven/"
   *   }
   * }
   * 
   * dependencies {
   *   compile group: 'ca.ubc.stat', name: 'xlinear', version: '1.0.0'
   * }
   * ```
   * 
   * ### Compile using the provided gradle script
   * 
   * - Check out the source ``git clone git@github.com:alexandrebouchard/xlinear.git``
   * - Compile using ``gradle installApp``
   * - Add the jars in ``build/install/xlinear/lib/`` into your classpath
   * 
   * ### Use in eclipse
   * 
   * - Check out the source ``git clone git@github.com:alexandrebouchard/xlinear.git``
   * - Type ``gradle eclipse`` from the root of the repository
   * - From eclipse:
   *   - ``Import`` in ``File`` menu
   *   - ``Import existing projects into workspace``
   *   - Select the root
   *   - Deselect ``Copy projects into workspace`` to avoid having duplicates
   */
  @Tutorial(startTutorial = "README.md", showSource = false)
  public void installInstructions() {}
  
  /**
   * Quick start
   * -----------
   * 
   * To use xlinear in a Java file, add the following import statement:
   * 
   * ```java
   * import static xlinear.MatrixOperations.*;
   * ```
   * 
   * and to use xlinear in an Xtend file, add the following import statement:
   * 
   * ```Xtend
   * import static extension xlinear.MatrixOperations.*
   * ```
   * 
   * Here are some examples of how to use xlinear, which illustrate important 
   * concepts and design decisions:
   */
  @Tutorial(showSource = true)
  @Test
  public void basics() 
  {
    // The recommended API is all in MatrixOperations
    // This API uses dispatch methods, so you are not required
    // to keep track of the detailed type of matrices (e.g. sparse vs dense)
	  Matrix m1 = dense(3,100_000);
	  Matrix m2 = sparse(100_000,3);
	  
	  // We generally follow Java conventions, e.g. matrices are 0-indexed
	  m1.set(0, 0, 1);
	  m2.set(0, 0, 1);
	  
	  Matrix prod = mult(m1, m2); // in Xtend: "val prod = m1 * m2"
	  System.out.println(prod);  
	  
	  // 3 x 3 sparse matrix
    //       0        1        2      
    // 0 |   1.00000  0.00000  0.00000
    // 1 |   0.00000  0.00000  0.00000
    // 2 |   0.00000  0.00000  0.00000
	  
	  // Note that sparsity is automatically inferred using these rules:
	  
	  // sparse + sparse = sparse (same for -)
	  // sparse + dense = dense (and vice versa, and same for -)
	  // dense + dense = dense (same for -)
	  
	  // sparse * sparse = sparse
	  // sparse * dense = sparse (and vice versa)
	  // sparse * sparse = sparse
	  
	  // dense * cnst = dense
	  // sparse * cnst = sparse
	  
	  Matrix another = mult(prod, 4);
  }
}
