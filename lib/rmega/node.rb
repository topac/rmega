module Rmega
  class Node
    attr_accessor :session, :data

    def initialize session, data
      self.session = session
      self.data = data
    end

    def self.types
      {file: 0, dir: 1, root: 2, inbox: 3, trash: 4}
    end

    def owner_key
      k.split(':').first
    end

    def name
      return attributes['n'] if attributes
    end

    def key
      k.split(':').last
    end

    def method_missing name
      name = name.to_s
      return data[name] if data.has_key?(name)
      raise NoMethodError.new(name)
    end

    def decrypt_attributes
      a32key = Crypto.decrypt_key session.master_key, Utils.base64_to_a32(key)
      if a32key.size > 4
        a32key = [a32key[0] ^ a32key[4], a32key[1] ^ a32key[5], a32key[2] ^ a32key[6], a32key[3] ^ a32key[7]]
      end
      attributes = Crypto::Aes.decrypt a32key, Utils.base64_to_a32(a)
      attributes = Utils.a32_to_str attributes
      JSON.parse attributes.gsub(/^MEGA/, '').rstrip
    end

    def owned_by_me?
      u == owner_key
    end

    def attributes
      @attributes ||= begin
        decrypt_attributes if owned_by_me?
      end
    end

    def type
      founded_type = self.class.types.find { |k, v| data['t'] == v }
      founded_type.first if founded_type
    end
  end
end
