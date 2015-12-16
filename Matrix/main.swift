//
//  main.swift
//  Matrix
//
//  Created by Matt Egan on 12/15/15.
//  Copyright © 2015 Matt Egan. All rights reserved.
//

import Foundation


print(Matrix.I(3))
print(Matrix.diagonal([1, 2, 3, 4, 5, 6], pad: 2.5))
var x = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
var y = Matrix([[20, 1, 5], [20, 1, 5], [20, 1, 5]])
var z = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]])
print(x + y)
print(Matrix.I(3).transpose())
print(x.transpose())
print(z.transpose())
print(x.multiply(y))
print(y.multiply(x))
