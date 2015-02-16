module Rmega
  module NotInspectable
    def inspect(attributes = {})
      memaddr = (__send__(:object_id) << 1).to_s(16)
      string = "#<#{self.class.name}:#{memaddr}"
      attributes.each { |k, v| string << " #{k}=#{v}" }
      string << ">"
    end
  end
end
