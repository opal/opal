class A
  def each
    return to_enum unless block_given?

    yield 1
    yield 2
    yield 3
  end
end

enum = A.new.each
enum.map { |e| e }

# a = A.new
# enum = Enumerator.new(a, :each)
# enum.each { |a| p a }
