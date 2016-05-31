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
  // TODO: once static analysis is restored, specialize the types in this 
  //       and add comments that hybrid approach works
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
   * Matrix/vector creation
   * -----------------------
   * 
   * There is no special type for vectors, they are just nx1 matrices. They can therefore 
   * be sparse or dense as well. All bounds are checked at runtime. 
   */
  @Tutorial(showSource = true)
  @SuppressWarnings("unused")
  @Test
  public void creation() 
  {
    DenseMatrix  vector   = dense(100);          // creates dense 100 x 1 initialized at 0
    SparseMatrix spVector = sparse(100_000);     // creates sparse 100k x 1 vector init at 0
    
    SparseMatrix identity = identity(100_000);   // creates sparse 100k x 100k identity matrix
    
    DenseMatrix fromArr   = denseCopy(new double[][]{{1.0, 2.0},{5.4, 6.1}});
                                                 // creates a matrix by copying array
                                                 // in Xtend: denseCopy(#[#[1.0, 2.0], #[5.4, 6.1]])
    
    DenseMatrix copy      = denseCopy(spVector); // copy existing sparse or dense into to a new dense
    
    DenseMatrix denseVec  = denseCopy(new double[]{234.3, 23.4, 0.0}); 
                                                 // N x 1 vector based on copying
    
    // sparseCopy(..) works in the same way as the previous three
  }
  
  /**
   * Slice and views
   * ---------------
   * 
   * Slices are read/write windows into an existing matrix. Changes in the slice will be reflected 
   * in the original matrix and vice versa. 
   * 
   * Read-only views work similarly except that exceptions are thrown if the user attempts to modify
   * the obtained slice. If a reference to the original matrix is kept, it is still possible to 
   * modify the underlying data though. The behavior is therefore similar to 
   * Collections.unmodifiableCollection(..).
   * 
   * One can create a slice of a slice, or a slice of a slice of a slice, etc with no running time 
   * penalty (the nesting is collapsed internally).
   * 
   * Slices work with both dense and sparse arrays. Creating them takes constant time. 
   * In the dense case, all operations on a pxq slice of an nxm matrix will 
   * have running times close to the running time of a concrete pxq matrix.
   * In the sparse case, this it true for random access, but currently the implementation of the 
   * iteration will internally loop over the entries of the carrier matrix.  
   * 
   * However in both dense and sparse slices, when a n^3 operation is computed, internally,
   * the matrix is copied to an optimal concrete implementation for maximum performance.
   */
  @Tutorial(showSource = true)
  @Test
  public void slices() 
  {
    DenseMatrix originalDense = dense(3, 3);
    DenseMatrix lastRow      = originalDense.row(2);
    
    lastRow.set(0,0,100);
    originalDense.set(2, 2, 10);
    originalDense.set(0, 0, 1);
    multEquals(lastRow, 2.0); 
    
    System.out.println(originalDense);
    // 3 x 3 dense matrix
    //         0        1         2      
    // 0 |     1.00000  0.00000   0.00000
    // 1 |     0.00000  0.00000   0.00000
    // 2 |   200.000    0.00000  20.0000 
    
    System.out.println(lastRow.slice(0, 1, 0, 2)); // sub slice to keep only first 2 cols
    // 1 x 3 dense matrix slice
    //         0      1          
    // 0 |   200.000  0.00000
    
    SparseMatrix originalSparse = sparse(100_000, 100_000);
    originalSparse.set(0, 0, 41);
    SparseMatrix sparseView = originalSparse.col(0).readOnlyView().slice(0, 3, 0, 1);
    System.out.println(sparseView);
    // 3 x 1 sparse matrix read-only slice
    //        0      
    // 0 |   41.0000 
    // 1 |    0.00000
    // 2 |    0.00000
    
    // multEquals(sparseView, 2); throws UnsupportedOperationException
  }
}
