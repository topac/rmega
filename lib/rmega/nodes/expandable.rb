require 'rmega/utils'
require 'rmega/uploader'
require 'rmega/crypto/crypto'

module Rmega
  module Nodes
    module Expandable
      def create_folder(name)
        key = Crypto.random_key
        encrypted_attributes = Utils.a32_to_base64 Crypto.encrypt_attributes(key[0..3], {n: name.strip})
        encrypted_key = Utils.a32_to_base64 Crypto.encrypt_key(session.master_key, key)
        n = [{h: 'xxxxxxxx', t: 1, a: encrypted_attributes, k: encrypted_key}]
        data = session.request a: 'p', t: handle, n: n
        Folder.new(session, data['f'][0])
      end

      def upload_url(filesize)
        session.request(a: 'u', s: filesize)['p']
      end

      def upload(local_path)
        local_path = ::File.expand_path(local_path)
        filesize = ::File.size(local_path)

        ul_key = Crypto.random_key
        aes_key = ul_key[0..3]
        nonce = ul_key[4..5]

        file_mac = [0, 0, 0, 0]

        uploader = Uploader.new(filesize: filesize, base_url: upload_url(filesize), local_path: local_path)

        uploader.upload do |start, clean_buffer|
          # TODO: should be (chunk_start/0x1000000000) >>> 0, (chunk_start/0x10) >>> 0
          nonce = [nonce[0], nonce[1], (start/0x1000000000) >> 0, (start/0x10) >> 0]

          encrypted = Crypto::AesCtr.encrypt(aes_key, nonce, clean_buffer)
          chunk_mac = encrypted[:mac]

          file_mac = [file_mac[0] ^ chunk_mac[0], file_mac[1] ^ chunk_mac[1],
                      file_mac[2] ^ chunk_mac[2], file_mac[3] ^ chunk_mac[3]]
          file_mac = Crypto::Aes.encrypt(ul_key[0..3], file_mac)

          encrypted[:data]
        end

        file_handle = uploader.last_result

        attribs = {n: ::File.basename(local_path)}
        encrypt_attribs = Utils.a32_to_base64 Crypto.encrypt_attributes(ul_key[0..3], attribs)

        meta_mac = [file_mac[0] ^ file_mac[1], file_mac[2] ^ file_mac[3]]

        key = [ul_key[0] ^ ul_key[4], ul_key[1] ^ ul_key[5], ul_key[2] ^ meta_mac[0],
               ul_key[3] ^ meta_mac[1], ul_key[4], ul_key[5], meta_mac[0], meta_mac[1]]

        encrypted_key = Utils.a32_to_base64 Crypto.encrypt_key(session.master_key, key)
        session.request a: 'p', t: handle, n: [{h: file_handle, t: 0, a: encrypt_attribs, k: encrypted_key}]

        attribs[:n]
      end
    end
  end
end
