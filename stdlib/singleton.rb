module Singleton
	def clone
		raise TypeError, "can't clone instance of singleton #{self.class}"
	end

	def dup
		raise TypeError, "can't dup instance of singleton #{self.class}"
	end

	def self.included (klass)
		super

		class << klass
			def new
				raise ArgumentError, "you can't call #new on a Singleton" if @instance

				@instance = super
			end

			undef_method :allocate

			def instance
				@instance ||= new()
			end
		end
	end
end
