class ::Data
  def self.define(*members, &block)
    raise TypeError unless members.all?(::Symbol)
    raise ArgumentError if members.any?(/=\z/) || members.uniq != members

    Class.new(self) do |klass|
      @members = members

      klass.singleton_class.undef_method :define

      members.each do |member|
        klass.define_method(member) { @members[member] }
      end

      klass.class_eval(&block) if block_given?
    end
  end

  singleton_class.attr_reader :members

  def self.new(*args, &block)
    raise NoMethodError if self == ::Data

    members, kwargs = nil, nil
    %x{
      var object = #{allocate};

      kwargs = args[args.length - 1];

      function has_kwargs() {
        return kwargs != null && kwargs.$$is_hash && kwargs.$$kw;
      }

      if (has_kwargs()) {
        #{::Kernel.raise ::ArgumentError, 'too many arguments' if args.length > 1};
        #{members = kwargs};
      }
      else {
        #{::Kernel.raise ::ArgumentError, 'too many arguments' if args.length > self.members.length};
        #{members = self.members.map.with_index { |name, idx| [name, args[idx]] if args.length > idx }.compact.to_h};
      }

      var object = #{allocate};
      Opal.send(object, object.$initialize, [members]);
      return object;
    }
  end

  singleton_class.alias_method :[], :new

  def initialize(**kwargs)
    @members = {}
    self.class.members.each do |member|
      raise ArgumentError, "missing #{members}" unless kwargs.key? member
      @members[member] = kwargs.delete(member)
    end
    raise ArgumentError, 'too many arguments' unless kwargs.empty?
    freeze
  end

  def initialize_copy(*)
    super
    freeze
  end

  def freeze
    super
    @members.freeze
    self
  end

  def members
    self.class.members
  end

  def to_h(&block)
    @members.to_h(&block)
  end

  def ==(other)
    self.class == other.class && @members == other.to_h
  end

  alias eql? ==

  def deconstruct
    @members.values
  end

  def deconstruct_keys(keys)
    if keys
      ::Kernel.raise ::TypeError, 'expected Array or nil' unless ::Array === keys
      keys.map { |name| [name, @members[name]] if @members.key? name }.compact.to_h
    else
      self
    end
  end

  def to_s
    name = " #{self.class.name}" if self.class.name
    members = @members.map do |k, v|
      k = ":#{k}" if k.start_with? '@'
      "#{k}=#{v.inspect}"
    end.join(', ')
    "#<data#{name} #{members}>"
  end

  alias inspect to_s

  def hash
    [self.class, @members].hash
  end
end
