package xlinear.internals

import java.util.HashMap
import java.util.List
import java.util.HashSet

class TablePrettyPrinter {
  val data = new HashMap<List<Integer>,String>
  val widths = new HashMap<Integer,Integer>
  val leftJustified = new HashSet<Integer>
  var nCols = 0
  var nRows = 0
  def void set(int row, int col, String string) {
    data.put(key(row, col), string)
    widths.put(col, Math.max(width(col), string.length))
    nRows = Math.max(nRows, row + 1)
    nCols = Math.max(nCols, col + 1)
  }
  def void makeJustificationToLeft(int col) {
    leftJustified.add(col)
  }
  def private int width(int col) {
    if (widths.containsKey(col)) widths.get(col) else 0
  }
  def private List<Integer> key(int row, int col) {
    #[row, col]
  }
  def String get(int row, int col) {
    val String value = data.get(key(row, col))
    if (value === null) "" else value
  }
  def String toString(String tab) {
    val StringBuilder result = new StringBuilder()
    for (var int row = 0; row < nRows; row++) {
      for (var int col = 0; col < nCols; col++) {
         val String str = get(row, col)
         val int colWidth = width(col)
         val boolean leftJustified = leftJustified.contains(col)
         if (!leftJustified)
           for (var int i = 0; i < colWidth - str.length; i++)
             result.append(" ")
         result.append(str)
         if (leftJustified)
           for (var int i = 0; i < colWidth - str.length; i++)
             result.append(" ")
         if (col != nCols - 1)
          result.append(tab)
      }
      if (row != nRows - 1)
        result.append("\n")
    }
    return result.toString()
  }
}