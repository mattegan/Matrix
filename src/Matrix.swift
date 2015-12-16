//
//  Matrix.swift
//  Matrix
//
//  Created by Matt Egan on 12/13/15.
//  Copyright © 2015 Matt Egan. All rights reserved.
//

import Foundation

class Matrix : CustomStringConvertible {
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: Instance Variables
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    //  matrix dimensions
    var nc: Int
    var nr: Int

    //  elements are stored in row-major order
    //  e = elements[(row * nc) + col]
    var elements: Array<Double>
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK : Computed Properties
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    //  return row and column ranges
    var allRows: Range<Int> {
        get {
            return 0..<nr
        }
    }
    
    var allCols: Range<Int> {
        get {
            return 0..<nc
        }
    }
    
    //returns the sum of all of the elements in the matrix
    var sum: Double {
        get {
            return elements.reduce(0, combine: +)
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: Subscript Accessors
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // this array subscript accessor is the basis for the rest of the other accessors, it allows for
    // getting and setting groupings of rows and columns in any order, when setting, the fill matrix
    // must either be equal to the size of the submatrix that is being set, or a singular element
    // that is to be filled in all spaces defined in 'rows' and 'cols'
    subscript(rows: Array<Int>, cols: Array<Int>) -> Matrix {
        get {
            let rStart = rows.minElement()!
            let rEnd = rows.maxElement()!
            let cStart = cols.minElement()!
            let cEnd = cols.maxElement()!
            assert(rangeInBounds(rStart..<rEnd, cStart..<cEnd), "Getting [Rows, Cols] Out Of Bounds")
            let result = Matrix.zeros(rows.count, cols.count)
            for (placeRow, getRow) in rows.enumerate() {
                for (placeCol, getCol) in cols.enumerate() {
                    result.elements[(placeRow * cols.count) + placeCol] = elements[(getRow * nc) + getCol]
                }
            }
            return result
        }
        set (fill) {
            let rStart = rows.minElement()!
            let rEnd = rows.maxElement()!
            let cStart = cols.minElement()!
            let cEnd = rows.maxElement()!
            assert(rangeInBounds(rStart...rEnd, cStart...cEnd), "Setting [Rows, Cols] Out Of Bounds")
            let singular = fill.elements.count == 1
            if !singular {
                assert(fill.rangeInBounds(0..<(rows.count - 1), 0..<(cols.count - 1)), "Supplied Matrix Is Insufficiently Sized")
            }
            for (getRow, placeRow) in rows.enumerate() {
                for (getCol, placeCol) in cols.enumerate() {
                    elements[(placeRow * nc) + placeCol] = singular ? fill.elements[0] : fill.elements[(getRow * fill.nc) + getCol]
                }
            }
        }
    }
    
    //  a single value can be pulled with two integers, doesn't rely on the array based
    //  accessor for efficiency
    subscript(row: Int, col: Int) -> Double {
        get {
            assert(indexInBounds(row, col), "Getting [Row, Column] Out Of Bounds")
            return elements[(row * nc) + col]
        }
        set(element) {
            assert(indexInBounds(row, col), "Setting [Row, Column] Out Of Bounds")
            elements[(row * nc) + col] = element
        }
    }

    //  rows and cols can be indexed by ranges or by integer strides too
    subscript(rows: Range<Int>, cols: Range<Int>) -> Matrix {
        get {
            return self[[Int](rows), [Int](cols)]
        }
        set(fill) {
            self[[Int](rows), [Int](cols)] = fill
        }
    }
    
    subscript(rows: StrideThrough<Int>, cols: StrideThrough<Int>) -> Matrix {
        get {
            return self[[Int](rows), [Int](cols)]
        }
        set(fill) {
            self[[Int](rows), [Int](cols)] = fill
        }
    }
    
    //  a single row or column can be called out using an integer combined with an array, range or stride
    //  this is more convenient than a single element list, range or stride
    subscript(row: Int, cols: Array<Int>) -> Matrix {
        get {
            return self[[row], cols]
        }
        set(fill) {
            self[[row],  cols] = fill
        }
    }

    subscript(row: Int, cols: Range<Int>) -> Matrix {
        get {
            return self[[row], [Int](cols)]
        }
        set(fill) {
            self[[row],  [Int](cols)] = fill
        }
    }
    
    subscript(row: Int, cols: StrideThrough<Int>) -> Matrix {
        get {
            return self[[row], [Int](cols)]
        }
        set(fill) {
            self[[row], [Int](cols)] = fill
        }
    }

    subscript(rows: Array<Int>, col: Int) -> Matrix {
        get {
            return self[rows, [col]]
        }
        set(fill) {
            self[rows, [col]] = fill
        }
    }
    
    subscript(rows: Range<Int>, col: Int) -> Matrix {
        get {
            return self[[Int](rows), [col]]
        }
        set(fill) {
            self[[Int](rows), [col]] = fill
        }
    }
    
    subscript(rows: StrideThrough<Int>, col: Int) -> Matrix {
        get {
            return self[[Int](rows), [col]]
        }
        set(fill) {
            self[[Int](rows), [col]] = fill
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: Initializers
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    init(nr: Int, nc: Int, elements: Array<Double>) {
        self.nr = nr
        self.nc = nc
        self.elements = elements
    }
    
    //  accepts a list of rows, infers row and column count from fill count and fill[0] count
    //  respectively, sufficient data must be supplied
    init(_ fill: Array<Array<Double>>) {
        self.nr = fill.count
        if(self.nr >= 1) {
            self.nc = fill[0].count
        } else {
            self.nc = 0
        }
        self.elements = Array(fill.flatten())
        assert((self.nr * self.nc) == self.elements.count, "Insufficient Data Provided: Init")
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK : Convenience Initializers
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    //  returns a rows*cols matrix with all elements equal to 'prefill'
    class func prefilled(rows: Int, _ cols: Int, pad: Double) -> Matrix {
        let elements = [Double](count: rows * cols, repeatedValue: pad)
        return Matrix.init(nr: rows, nc: cols, elements: elements)
    }
    
    //  returns a square prefilled matrix
    class func prefilled(size: Int, pad: Double) -> Matrix {
        return Matrix.prefilled(size, size, pad: pad)
    }

    //  returns a rows*cols matrix filled with zeros
    class func zeros(rows: Int, _ cols: Int) -> Matrix {
        return Matrix.prefilled(rows, cols, pad: 0.0)
    }
    
    //  returns a square zeros matrix
    class func zeros(size: Int) -> Matrix {
        return Matrix.zeros(size, size)
    }
    
    //  returns a rows*cols matrix filled with ones
    class func ones(rows: Int, _ cols: Int) -> Matrix {
        return Matrix.prefilled(rows, cols, pad: 1.0)
    }
    
    //  returns a square ones matrix
    class func ones(size: Int) -> Matrix {
        return Matrix.ones(size, size)
    }
    
    //  returns a fill.count*fill.count matrix with the diagonal elements equal to the elements in
    //  fill, from top-left to bottom-right, and all other elements equal to 'pad'
    class func diagonal(fill: [Double], pad: Double) -> Matrix {
        let result = Matrix.prefilled(fill.count, fill.count, pad: pad)
        for (row, element) in fill.enumerate() {
            result.elements[(row * fill.count) + row] = element
        }
        return result
    }
    
    //  same as diagonal(fill:, pad:), but uses a default pad of zero
    class func diagonal(fill: [Double]) -> Matrix {
        return Matrix.diagonal(fill, pad: 0.0)
    }
    
    //  returns an size*size sized identity matrix
    class func I(size: Int) -> Matrix {
        let ones = [Double](count: size, repeatedValue: 1.0)
        return Matrix.diagonal(ones)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: Range Checks
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    func indexInBounds(row: Int, _ col: Int) -> Bool {
        return (row >= 0 && row < nr) && (col >= 0 && col < nc)
    }
    
    func rangeInBounds(rows: Range<Int>, _ cols: Range<Int>) -> Bool {
        return (indexInBounds(rows.startIndex, cols.startIndex) &&
            indexInBounds(rows.endIndex, cols.endIndex))
    }
    
    class func dimensionsEqual(first: Matrix, _ second: Matrix) -> Bool {
        return (first.nr == second.nr && first.nc == second.nc)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: Operations
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    //  apply a function to every element
    func map(function: (Double) -> Double) -> Matrix {
        let result = Matrix.zeros(nr, nc)
        for (index, element) in elements.enumerate() {
            result.elements[index] = function(element)
        }
        return result
    }
    
    //  combine two equally sized matrices into one using a function
    func combine(matrix: Matrix, operation: (Double, Double) -> Double) -> Matrix {
        assert(Matrix.dimensionsEqual(self, matrix), "Dimension Mismatch: Dimensions Must Equal")
        let result = Matrix.zeros(nr, nc)
        for (index, element) in elements.enumerate() {
            result.elements[index] = operation(element, matrix.elements[index])
        }
        return result
    }
    
    //  element-wise addition, subtraction, multiplication and division
    func add(matrix: Matrix) -> Matrix {
        return self.combine(matrix, operation: +)
    }
    
    func subtract(matrix: Matrix) -> Matrix {
        return self.combine(matrix, operation: -)
    }
    
    func multiplyElements(matrix: Matrix) -> Matrix {
        return self.combine(matrix, operation: *)
    }
    
    func divideElements(matrix: Matrix) -> Matrix {
        return self.combine(matrix, operation: /)
    }
    
    //  add, subtract, multiply and divide by a scalar
    func add(scalar: Double) -> Matrix {
        return self.map{$0 + scalar}
    }
    
    func subtract(scalar: Double) -> Matrix {
        return self.map{$0 - scalar}
    }
    
    func multiply(scalar: Double) -> Matrix {
        return self.map{$0 * scalar}
    }
    
    func divide(scalar: Double) -> Matrix {
        return self.map{$0 * scalar}
    }
    
    // multiply or divide two matrices
    func multiply(matrix: Matrix) -> Matrix {
        assert(nc == matrix.nr, "Multiplication Dimension Mismatch")
        let result = Matrix.zeros(nr, matrix.nc)
        for row in result.allRows {
            for col in result.allCols {
                let value = self[row, allCols].multiplyElements(matrix[matrix.allRows, col].transpose()).sum
                result[row, col] = value
            }
        }
        return result
    }
    
    //  get the transpose of the matrix, (rows -> cols, cols -> rows)
    func transpose() -> Matrix{
        let result = Matrix.zeros(self.nc, self.nr)
        for row in self.allRows {
            for col in self.allCols {
                result[col, row] = self[row, col]
            }
        }
        return result
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: CustomStringConvertable Protocol
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    var description: String {
        get {
            return self.toString()
        }
    }
    
    //  generates a string with rows separated by newlines, with intelligent column spacing for
    //  different precision outputs (rounds to precision)
    func toString(precision: Int = 3) -> String{
        //  determine the column width
        var longest = 0
        for element in elements {
            let whole = (element == floor(element))
            var length = 0
            if whole {
                length = String(floor(element)).characters.count
            } else {
                let format = "%." + String(precision) + "f"
                length = String(format: format, arguments: [element]).characters.count
            }
            longest = length > longest ? length : longest
        }
        var output = ""
        let format = "%" + String(longest) + "." + String(precision) + "f"
        for (var row = 0; row < nr; row++) {
            for (var col = 0; col < nc; col++) {
                let element = self[row, col]
                output += String(format: format, arguments: [element]);
                output += "\t"
            }
            output += "\n"
        }
        return output
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  MARK: Matrix-Matrix Operators
///////////////////////////////////////////////////////////////////////////////////////////////////

//  add two equivalently sized matrices, element by element
func + (left: Matrix, right: Matrix) -> Matrix {
    return left.add(right)
}

//  subtract two equivalently sized matrices, element by element
func - (left: Matrix, right: Matrix) -> Matrix {
    return left.subtract(right)
}

//  element-wise multiplication
infix operator ∆* { associativity left precedence 150 }
func ∆* (left: Matrix, right: Matrix) -> Matrix {
    return left.multiplyElements(right)
}

//  element-wise division
infix operator ∆/ { associativity left precedence 150 }
func ∆/ (left: Matrix, right: Matrix) -> Matrix {
    return left.divideElements(right)
}

//  multiply two matrices
func * (left: Matrix, right: Matrix) -> Matrix {
    return left.multiply(right)
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  MARK: Matrix-Scalar Operators
///////////////////////////////////////////////////////////////////////////////////////////////////

//  scalar addition
func + (m: Matrix, s: Double) -> Matrix {
    return m.add(s)
}

//  scalar subtraction (A - s = B)
func - (m: Matrix, s: Double) -> Matrix {
    return m.subtract(s)
}

//  scalar multiplication (A * s = B)
func * (m: Matrix, s: Double) -> Matrix {
    return m.multiply(s)
}

//  scalar division (A / s = B)
func / (m: Matrix, s: Double) -> Matrix {
    return m.divide(s)
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// MARK : Scalar-Matrix Operations
///////////////////////////////////////////////////////////////////////////////////////////////////

func + (s: Double, m: Matrix) -> Matrix {
    return m + s
}

func - (s: Double, m: Matrix) -> Matrix {
    return (m * -1.0).add(s)
}

func * (s: Double, m: Matrix) -> Matrix {
    return m * s
}

func / (s: Double, m: Matrix) -> Matrix {
    return m.map{s / $0}
}