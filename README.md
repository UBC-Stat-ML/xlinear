Summary 
-------

There are several excellent linear algebra libraries for Java, but they generally have a 
high learning curve compared to Matlab/Numpy/Julia.

This library uses the best of several of these under hood (Apache Commons, parallel COLT, and JEigen), 
but exposes only a simple API that will be familiar to Matlab/Numpy/Julia users.

Both dense and sparse matrices are supported. The library is fully compatible with both 
Java and Xtend, the only advantage of the latter being that operator overloading allows 
you to write expressions like ``A * B + 2 * C`` or ``C += D``, etc. Otherwise, the API 
is the same in the two languages (the library itself is written in Xtend, which gets compiled 
into readable Java code).


Installation
------------

There are several options available to install the package:

### Integrate to a gradle script

Simply add the following lines (replacing 1.0.0 by the current version (see git tags)):

```groovy
repositories {
 mavenCentral()
 jcenter()
 maven {
    url "http://www.stat.ubc.ca/~bouchard/maven/"
  }
}

dependencies {
  compile group: 'ca.ubc.stat', name: 'xlinear', version: '1.0.0'
}
```

### Compile using the provided gradle script

- Check out the source ``git clone git@github.com:alexandrebouchard/xlinear.git``
- Compile using ``gradle installApp``
- Add the jars in ``build/install/xlinear/lib/`` into your classpath

### Use in eclipse

- Check out the source ``git clone git@github.com:alexandrebouchard/xlinear.git``
- Type ``gradle eclipse`` from the root of the repository
- From eclipse:
  - ``Import`` in ``File`` menu
  - ``Import existing projects into workspace``
  - Select the root
  - Deselect ``Copy projects into workspace`` to avoid having duplicates


Quick start
-----------

### Importing

To use xlinear in a Java file, add the following import statement:

```java
import static xlinear.MatrixOperations.*;
import static xlinear.MatrixExtensions.*;
```

and to use xlinear in an Xtend file, add the following import statement:

```Xtend
import static extension xlinear.MatrixExtensions.*
import static xlinear.MatrixOperations.*
```

### Basic usage

Here are some examples of how to use xlinear, which illustrate important 
concepts and design decisions:

```java
// The recommended API is all in MatrixOperations
// This API uses dispatch methods, so you are not required
// to keep track of the detailed type of matrices (e.g. sparse vs dense)
DenseMatrix  m1 = dense(3,100_000);  // create dense 3 x 100_000 initialized at 0's 
SparseMatrix m2 = sparse(100_000,3); // create sparse ..

// We generally follow Java conventions, e.g. matrices are 0-indexed
m1.set(0, 0, 1);
m2.set(0, 0, 1);
System.out.println(m1.get(0, 0));
// 1.0

// Basic operations use a straightforward syntax: 

// mtx1.mul(mtxOrScalar), mtx1.add(mtx2), mtx1.sub(mtx2), which do not modify the inputs
// mtx1.mulInPlace(scalar), mtx1.addInPlace(mtx2), mtx1.subInPlace(mtx2), which modify mtx1

// Examples:

DenseMatrix prod  = m1.mul(m2);     // in Xtend: "var prod   = m1 * m2"
DenseMatrix scaled = m1.mul(4);     // in Xtend: "var scaled = 4 * m1"
scaled.mulInPlace(5.0);             // in Xtend: "scaled *= 5.0"

prod.addInPlace(prod);              // in Xtend: "var prod += prod"
DenseMatrix sum = prod.add(prod);   // in Xtend: "var sum = prod + prod"

sum.subInPlace(sum);                // in Xtend: "var prod -= prod"
DenseMatrix diff = prod.sub(prod);  // in Xtend: "var sum = prod - prod"

System.out.println(prod);  
// 3 x 3 dense matrix
//       0        1        2      
// 0 |   2.00000  0.00000  0.00000
// 1 |   0.00000  0.00000  0.00000
// 2 |   0.00000  0.00000  0.00000

// DenseMatrix inverse = prod.inverse(); // throw exception as it is not invertible
```

Sparsity is correctly inferred using these rules:

- Additions (same for subtraction):
    - ``sparse + sparse = sparse`` 
    - ``sparse + dense = dense`` (and vice versa, ``dense + sparse = dense``)
    - ``dense + dense = dense`` 
- Multiplications: 
    - ``sparse * sparse = sparse``
    - ``sparse * dense = dense`` (and vice versa)
    - ``dense * dense = dense``
- Scalings:
    - ``dense * cnst = dense`` (and vice versa)
    - ``sparse * cnst = sparse`` (and vice versa)
    
If you forget these rules, you can rely on static analysis, e.g.
try both ``SparseMatrix prod  = m1.mul(m2);`` and 
``DenseMatrix prod  = m1.mul(m2);`` in the code above and you will 
see that only the latter compiles. If you are in a hurry, you can also just 
write ``Matrix prod  = m1.mul(m2);`` and subsequent operations taking prod 
as argument will still work the same (in other words we use a hybrid of static and
dispatch method binding, where static is used if available, and we fall 
back to dispatch if static type if not provided, to ensure the optimal 
algorithm is always selected for the types of matrices provided).


Matrix/vector creation
-----------------------

There is no special type for vectors, they are just nx1 matrices. They can therefore 
be sparse or dense as well. All bounds are checked at runtime. 

```java
DenseMatrix  vector   = dense(100);          // creates dense 100 x 1 initialized at 0
SparseMatrix spVector = sparse(100_000);     // creates sparse 100k x 1 vector init at 0

SparseMatrix identity = identity(100_000);   // creates sparse 100k x 100k identity matrix
DenseMatrix  ones     = ones(10,2);          // creates a 10 x 2, all entries set to 1

DenseMatrix fromArr   = denseCopy(new double[][]{{1.0, 2.0},{5.4, 6.1}});
                                             // creates a matrix by copying array
                                             // in Xtend: denseCopy(#[#[1.0, 2.0], #[5.4, 6.1]])

DenseMatrix copy      = denseCopy(spVector); // copy existing sparse or dense into to a new dense

DenseMatrix denseVec  = denseCopy(new double[]{234.3, 23.4, 0.0}); 
                                             // N x 1 vector based on copying

// sparseCopy(..) works in the same way as the previous three
```

Various common operations
-------------------------

```java
// Dot product
dot(sparse(100_000), sparse(100_000)); // In Xtend, also allowed: sparse(100_000).dot(sparse(100_000))
double [][] converted = toArray(dense(10,10)); // In Xtend, also allowed: dense(10,10).toArray
double [] converted = toArray(sparse(10));
double euclideanNorm = norm(ones(10));
double sum = sum(identity(10));
```


Slice and views
---------------

Slices are read/write windows into an existing matrix. Changes in the slice will be reflected 
in the original matrix and vice versa. 

Read-only views work similarly except that exceptions are thrown if the user attempts to modify
the obtained slice. If a reference to the original matrix is kept, it is still possible to 
modify the underlying data though. The behavior is therefore similar to 
Collections.unmodifiableCollection(..).

One can create a slice of a slice, or a slice of a slice of a slice, etc with no running time 
penalty (the nesting is collapsed internally).

Slices work with both dense and sparse matrices. Creating them takes constant time. 
In the dense case, all operations on a p-by-q slice of an n-by-m matrix will 
have running times close to the running time of a concrete p-by-q matrix.
In the sparse case, this it true for random access, but currently the implementation of the 
iteration will internally loop over the entries of the carrier matrix.  

However in both dense and sparse slices, when a n^3 operation is computed, internally,
the matrix is copied to an optimal concrete implementation for maximum performance.

```java
DenseMatrix originalDense = dense(3, 3);
DenseMatrix lastRow       = originalDense.row(2);

lastRow.set(0,0,100);
originalDense.set(2, 2, 10);
originalDense.set(0, 0, 1);
lastRow.mulInPlace(2.0); 

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

// sparseView.mulInPlace(2); throws UnsupportedOperationException
```

Decompositions
--------------

Both dense and sparse Cholesky decompositions are supported. In both case, 
simply use ``matrix.cholesky()``. Other common decompositions to be added 
shortly.

```java
SparseMatrix posDef = sparseCopy(TestData.smallPositiveDefiniteExample);
System.out.println(posDef);
// 3 x 3 sparse matrix
//        0         1         2      
// 0 |    2.00000  -1.00000   0.00000
// 1 |   -1.00000   2.00000  -1.00000
// 2 |    0.00000  -1.00000   2.00000
    
Matrix L = posDef.cholesky().L;
System.out.println(L.mul(L.transpose()));
// 3 x 3 sparse matrix
//        0         1         2      
// 0 |    2.00000  -1.00000   0.00000
// 1 |   -1.00000   2.00000  -1.00000
// 2 |    0.00000  -1.00000   2.00000

// Find log | determinant | from Cholesky:
System.out.println(posDef.cholesky().logDet());

// solve A*x = b for x
DenseMatrix b = ones(3);
DenseMatrix x = posDef.cholesky().solve(b);
System.out.println(b);
System.out.println(A.mul(x));
```
