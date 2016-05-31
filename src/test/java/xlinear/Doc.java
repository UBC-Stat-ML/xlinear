package xlinear;


import tutorialj.Tutorial;

import static xlinear.MatrixOperations.*;

import org.junit.Assert;
import org.junit.Test;


public class Doc
{
  /**
   * 
   * Summary 
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
   * ### Importing
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
   * ### Basic usage
   * 
   * Here are some examples of how to use xlinear, which illustrate important 
   * concepts and design decisions:
   */
  @SuppressWarnings("unused")
  @Tutorial(showSource = true)
  @Test
  public void basics() 
  {
    // The recommended API is all in MatrixOperations
    // This API uses dispatch methods, so you are not required
    // to keep track of the detailed type of matrices (e.g. sparse vs dense)
    Matrix m1 = dense(3,100_000);  // create dense 3 x 100_000 initialized at 0's 
    Matrix m2 = sparse(100_000,3); // create sparse ..
	  
    // We generally follow Java conventions, e.g. matrices are 0-indexed
    m1.set(0, 0, 1);
    m2.set(0, 0, 1);
    System.out.println(m1.get(0, 0));
    // 1.0
    
    // Basic operations use a straightforward syntax: 
    
    // mult(mtxOrScalar1,mtxOrScalar2), add(mtx1,mtx2), sub(mtx1,mtx2), which do not modify the inputs
    // multEquals(mtx1, scalar), addEquals(mtx1, mtx2), subEquals(mtx1, mtx2), which modify mtx1
    
    // Examples:
    
    Matrix prod = mult(m1, m2);    // in Xtend: "var prod   = m1 * m2"
    Matrix scaled = mult(4, m1);   // in Xtend: "var scaled = 4 * m1"
    multEquals(scaled, 5.0);       // in Xtend: "scaled *= 5.0"
    
    addEquals(prod, prod);         // in Xtend: "var prod += prod"
    Matrix sum = add(prod, prod);  // in Xtend: "var sum = prod + prod"
    
    subEquals(sum, sum);           // in Xtend: "var prod -= prod"
    Matrix diff = sub(prod, prod); // in Xtend: "var sum = prod - prod"
    
    System.out.println(prod);  
    // 3 x 3 sparse matrix
    //       0        1        2      
    // 0 |   2.00000  0.00000  0.00000
    // 1 |   0.00000  0.00000  0.00000
    // 2 |   0.00000  0.00000  0.00000
  }
  
  /**
   * Sparsity is correctly inferred using these rules:
   * 
   * - Additions (same for subtraction):
   *     - ``sparse + sparse = sparse`` 
   *     - ``sparse + dense = dense`` (and vice versa, ``dense + sparse = dense``)
   *     - ``dense + dense = dense`` 
   * - Multiplications: 
   *     - ``sparse * sparse = sparse``
   *     - ``sparse * dense = sparse`` (and vice versa)
   *     - ``sparse * sparse = sparse``
   * - Scalings:
   *     - ``dense * cnst = dense`` (and vice versa)
   *     - ``sparse * cnst = sparse`` (and vice versa)
   */
  @Tutorial(showSource = false)
  public void sparsity() {}
  
  /**
   * Matrix/vector creation and slices
   * ---------------------------------
   * 
   * There is no special type for vectors, they are just nx1 matrices. They can therefore 
   * be sparse or dense as well. All bounds are checked at runtime. 
   */
  @Tutorial(showSource = true)
  @Test
  public void creationAndSlices() 
  {
    Matrix vector   = dense(100);        // creates dense 100 x 1 initialized at 0
    Matrix spVector = sparse(100_000);   // creates sparse 100k x 1 vector init at 0
    
    Matrix identity = identity(100_000); // creates sparse 100k x 100k identity matrix
  }
}
