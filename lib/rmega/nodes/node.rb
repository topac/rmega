module Rmega
  class Node
    attr_reader :data, :session

    def initialize session, data
      @session = session
      @data = data
    end

    def self.fabricate session, data
      type_name = type_by_number(data['t']).to_s
      node_class = Rmega.const_get("#{type_name}_node".camelize) rescue nil
      node_class ||= Rmega::Node
      node_class.new session, data
    end

    def self.initialize_by_public_url session, public_url
      public_handle, key = public_url.split('!')[1, 2]

      node = new session, public_data(session, public_handle)
      node.instance_variable_set '@public_url', public_url
      node
    end

    def self.types
      {file: 0, folder: 1, root: 2, inbox: 3, trash: 4}
    end

    def self.type_by_number number
      founded_type = types.find { |k, v| number == v }
      founded_type.first if founded_type
    end

    def logger
      Rmega.logger
    end

    # Member actions

    def public_url
      return @public_url if @public_url
      return nil if type != :file
      b64_dec_key = Utils.a32_to_base64 decrypted_file_key[0..7]
      "https://mega.co.nz/#!#{public_handle}!#{b64_dec_key}"
    end

    def trash
      trash_node_public_handle = storage.trash_node.public_handle
      request a: 'm', n: handle, t: trash_node_public_handle
    end


    # Delegate to session

    delegate :storage, :request, :to => :session


    # Other methods

    def self.public_data session, public_handle
      request a: 'g', g: 1, p: public_handle
    end

    def public_handle
      @public_handle ||= request(a: 'l', n: handle)
    end

    def handle
      data['h']
    end

    def parent_handle
      data['p']
    end

    def filesize
      data['s']
    end

    def owner_key
      data['k'].split(':').first
    end

    def name
      return attributes['n'] if attributes
    end

    def file_key
      data['k'].split(':').last
    end

    def decrypted_file_key
      if data['k']
        Crypto.decrypt_key session.master_key, Utils.base64_to_a32(file_key)
      else
        Utils.base64_to_a32 public_url.split('!').last
      end
    end

    def can_decrypt_attributes?
      !data['u'] or data['u'] == owner_key
    end

    def attributes
      @attributes ||= begin
        return nil unless can_decrypt_attributes?
        Crypto.decrypt_attributes decrypted_file_key, (data['a'] || data['at'])
      end
    end

    def type
      self.class.type_by_number data['t']
    end

    def delete
      request a: 'd', n: handle
    end
  end
end
