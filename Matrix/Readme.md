# Matrix
> It's a matrix.

## Example
```javascript
print(Matrix.I(3))
print((Matrix.ones(3) * 10.0) + (Matrix.zeros(3) + 5.0))
print(Matrix([[1, 2]]).transpose())
print(Matrix([[1, 2], [3, 4]]) * Matrix([[1, 2]]).transpose())
print(Matrix([[0, 30], [60, 90]]).map{sin($0 * 3.14159 / 180)}.toString(10))
```
