class Class
  def self.new(superclass = Object, &block)
    %x{
      superclass.$inherited(klass)
    }
  end
end
