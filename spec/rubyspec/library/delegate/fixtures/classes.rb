require 'delegate'
module DelegateSpecs
  class Simple
    def pub
      :foo
    end

    def respond_to_missing?(method, priv=false)
      method == :pub_too ||
        (priv && method == :priv_too)
    end
  end
end
