# NOTE: run bin/format-filters after changing this file
opal_filter "Matrix" do
  fails "Matrix#** returns the power for non integer powers" # RangeError: can't convert 7.000000000000007+8.881784197001252e-16i into Float
  fails "Matrix#/ returns the result of dividing self by a Bignum" # Expected Matrix[[1.0842021724855044e-19, 2.168404344971009e-19], [3.2526065174565133e-19, 4.336808689942018e-19]] == Matrix[[0, 0], [0, 0]] to be truthy but was false
  fails "Matrix#/ returns the result of dividing self by a Fixnum" # Expected Matrix[[0.5, 1], [1.5, 2]] == Matrix[[0, 1], [1, 2]] to be truthy but was false
  fails "Matrix#antisymmetric? returns false for non-antisymmetric matrices" # Expected true to be false
  fails "Matrix#each returns an Enumerator when called without a block" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix#each returns self" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix#each yields the elements starting with the those of the first row" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix#each_with_index with an argument raises an ArgumentError for unrecognized argument" # Expected ArgumentError but no exception was raised (Matrix[[1, 2, 3, 4], [5, 6, 7, 8]] was returned)
  fails "Matrix#eql? returns false if some elements are == but not eql?" # Expected true to be false
  fails "Matrix#find_index with a subselection argument and a generic argument returns the index of the requested value" # ArgumentError: [Matrix#[]] wrong number of arguments(0 for 2)
  fails "Matrix#find_index with a subselection argument and no generic argument returns the first index for which the block returns true" # ArgumentError: [Matrix#[]] wrong number of arguments(0 for 2)
  fails "Matrix#find_index with only a generic argument ignores a block" # Expected nil == [0, 3] to be truthy but was false
  fails "Matrix#find_index with only a generic argument returns the first index for of the requested value" # Expected nil == [0, 2] to be truthy but was false
  fails "Matrix#find_index with two arguments raises an ArgumentError for an unrecognized last argument" # Expected ArgumentError but no exception was raised (nil was returned)
  fails "Matrix#find_index without any argument returns the first index for which the block is true" # Expected nil == [0, 2] to be truthy but was false
  fails "Matrix#hash returns an Integer" # Expected "A,A,3,5" (String) to be an instance of Integer
  fails "Matrix#real? returns false if one element is a Complex whose imaginary part is 0" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix#real? returns false if one element is a Complex" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix#real? returns true for empty matrices" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix#real? returns true for matrices with all real entries" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix.diagonal? returns false for a non diagonal square Matrix" # Expected true to be false
  fails "Matrix.hermitian? returns false for a matrix with complex values on the diagonal" # Expected true to be false
  fails "Matrix.hermitian? returns false for an asymmetric Matrix" # Expected true to be false
  fails "Matrix.lower_triangular? returns false for a non lower triangular square Matrix" # Expected true to be false
  fails "Matrix.symmetric? returns false for an asymmetric Matrix" # Expected true to be false
  fails "Matrix.upper_triangular? returns false for a non upper triangular square Matrix" # Expected true to be false
  fails "Matrix.zero? returns false for matrices with non zero entries" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix.zero? returns true for empty matrices" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix.zero? returns true for matrices with zero entries" # ArgumentError: tried to create a Proc object without a block
  fails "Matrix::EigenvalueDecomposition#eigenvalue_matrix returns a diagonal matrix with the eigenvalues on the diagonal" # Expected Matrix[[-7.661903789690598, 0], [0, 15.661903789690601]] == Matrix[[6, 0], [0, 2]] to be truthy but was false
  fails "Matrix::EigenvalueDecomposition#eigenvalues returns an array of complex eigenvalues for a rotation matrix" # Expected [0, 1.9999999999999998] == [(1-1i), (1+1i)] to be truthy but was false
  fails "Matrix::EigenvalueDecomposition#eigenvalues returns an array of real eigenvalues for a matrix" # Expected [-7.6619037897, 15.6619037897] == [2, 6] to be truthy but was false
  fails "Matrix::EigenvalueDecomposition#eigenvector_matrix returns a complex eigenvector matrix given a rotation matrix" # Expected Matrix[[-0.7071067811865475, -0.7071067811865475], [-0.7071067811865475, 0.7071067811865475]] == Matrix[[1, 1], [(0+1i), (0-1i)]] to be truthy but was false
  fails "Matrix::EigenvalueDecomposition#eigenvectors returns an array of complex eigenvectors for a rotation matrix" # Expected [Vector[-0.7071067811865475, -0.7071067811865475],  Vector[-0.7071067811865475, 0.7071067811865475]] == [Vector[1, (0+1i)], Vector[1, (0-1i)]] to be truthy but was false
  fails "Matrix::EigenvalueDecomposition#to_a returns a factorization" # Expected Matrix[[14, -6], [-6, -6]] == Matrix[[14, 16], [-6, -6]] to be truthy but was false
  fails "Vector#eql? returns false when there are a pair corresponding elements which are not equal in the sense of Kernel#eql?" # Expected true to be false
end
