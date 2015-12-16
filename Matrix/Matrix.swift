//
//  Matrix.swift
//  noglRenderer
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
            let cEnd = rows.maxElement()!
            assert(rangeInBounds(rStart...rEnd, cStart...cEnd), "Getting [Rows, Cols] Out Of Bounds")
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
                assert(fill.rangeInBounds(0...(rows.count - 1), 0...(cols.count - 1)), "Supplied Matrix Is Insufficiently Sized")
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

    //  rows and cols can be indexed by ranges or by integer strides
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
    
    //  a single row or column can be called out using an integer
    //  this is more convenient than a single element list, range or stride
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
    // MARK: Initalizers
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

    //  returns a rows*cols matrix filled with zeros
    class func zeros(rows: Int, _ cols: Int) -> Matrix {
        return Matrix.prefilled(rows, cols, pad: 0.0)
    }
    
    //  returns a rows*cols matrix filled with ones
    class func ones(rows: Int, _ cols: Int) -> Matrix {
        return Matrix.prefilled(rows, cols, pad: 1.0)
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
            indexInBounds(rows.endIndex - 1, cols.endIndex - 1))
    }
    
    class func dimensionsEqual(first: Matrix, _ second: Matrix) -> Bool {
        return (first.nr == second.nr && first.nc == second.nc)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: CustomStringConvertable Protocol
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    var description: String {
        get {
            return self.toString()
        }
    }
    
    //  generates a string with rows separated by newlines, with inteligent column spacing for
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

//  add two equivilently sized matrices, element by element
func + (left: Matrix, right: Matrix) -> Matrix {
    assert(Matrix.dimensionsEqual(left, right), "Dimension Mismatch: Addition")
    let result = Matrix.zeros(left.nr, left.nc)
    for row in left.allRows {
        for col in left.allCols {
            result[row, col] = left[row, col] + right[row, col]
        }
    }
    return result
}

//  subtract two equivilently sized matricies, element by element
func - (left: Matrix, right: Matrix) -> Matrix {
    return left + (-1.0 * right)
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//  MARK: Matrix-Scalar Operators
///////////////////////////////////////////////////////////////////////////////////////////////////

//  scalar addition
func + (m: Matrix, s: Double) -> Matrix {
    let result = Matrix.zeros(m.nr, m.nc)
    for row in m.allRows {
        for col in m.allCols {
            result[row, col] = s + m[row, col]
        }
    }
    return result
}

//  scalar subtraction (A - s = B)
func - (m: Matrix, s: Double) -> Matrix {
    return m + (-1.0 * s)
}

//  scalar multiplication (A * s = B)
func * (m: Matrix, s: Double) -> Matrix {
    let result = Matrix.zeros(m.nr, m.nc)
    for row in m.allRows {
        for col in m.allCols {
            result[row, col] = m[row, col] * s
        }
    }
    return result
}

//  scalar division (A / s = B)
func / (m: Matrix, s: Double) -> Matrix {
    return m * (1.0 / s)
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// MARK : Scalar-Matrix Operations
///////////////////////////////////////////////////////////////////////////////////////////////////

func + (s: Double, m: Matrix) -> Matrix {
    return m + s
}

func - (s: Double, m: Matrix) -> Matrix {
    return s + (-1.0 * m)
}

func * (s: Double, m: Matrix) -> Matrix {
    return m * s
}

func / (s: Double, m: Matrix) -> Matrix {
    //  couldn't figure out a way to implement this using some cobination of the other operators
    //  I am possibly just not clever enough
    let result = Matrix.zeros(m.nr, m.nc)
    for row in m.allRows {
        for col in m.allCols {
            result[row, col] = s / m[row, col]
        }
    }
    return result
}