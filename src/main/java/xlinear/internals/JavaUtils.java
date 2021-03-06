package xlinear.internals;

import xlinear.Matrix;
import xlinear.StaticUtils;

/**
 * Things that would be awkward to write in Xtend. 
 * 
 * @author bouchard
 *
 */
public class JavaUtils {

  public static double[][] toArray(Matrix m) {
    double [][] result = new double[m.nRows()][m.nCols()];
    for (int r = 0; r < m.nRows(); r++) {
      for (int c = 0; c < m.nCols(); c++) {
        result[r][c] = m.get(r,c);
      }
    }
    return result;
  }
  
  public static double[] vectorToArray(Matrix m) {
    if (!m.isVector()) {
      throw StaticUtils.notAVectorException();
    }
    double [] result = new double[m.nEntries()];
    for (int i = 0; i < m.nEntries(); i++) {
      result[i] = m.get(i);
    }
    return result;
  }
}
