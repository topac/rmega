require 'rmega/loggable'
require 'rmega/utils'
require 'rmega/pool'

module Rmega
  class Uploader
    include Loggable

    attr_reader :pool, :base_url, :filesize, :local_path

    def initialize(params)
      @pool = Pool.new(params[:threads])
      @filesize = params[:filesize]
      @base_url = params[:base_url]
      @local_path = params[:local_path]
    end

    def upload_chunk(start, buffer)
      size = buffer.length
      stop = start + size - 1
      url = "#{base_url}/#{start}-#{stop}"
      logger.debug "#{Thread.current} uploading chunk @ #{start}"
      HTTPClient.new.post(url, buffer).body
    end

    # Writes a buffer in the local file, starting from the start-n byte.
    def write_chunk(start, buffer)
      # logger.debug "#{Thread.current} writing chunk @ #{position}"
      @local_file.seek(start)
      @local_file.write(buffer)
    end

    # Shows the progress bar in console
    def show_progress(increment)
      Utils.show_progress(:download, filesize, increment)
    end

    def chunks
      Utils.chunks(filesize)
    end

    # TODO: checksum check
    def download(&block)
      @local_file = allocate

      show_progress(0)

      chunks.each do |start, size|
        pool.defer do
          buffer = download_chunk(start, size)
          buffer = yield(start, buffer) if block_given?
          show_progress(size)
          pool.synchronize { write_chunk(start, buffer) }
        end
      end

      # waits for the last running threads to finish
      pool.wait_done

      @local_file.flush

      pool.shutdown
    ensure
      @local_file.close rescue nil
    end

    # def upload_chunk(url, start, chunk)
    #   response = HTTPClient.new.post "#{url}/#{start}", chunk, timeout: Rmega.options.upload_timeout
    #   response.body
    # end

    # def upload(local_path, parent_node = root)
    #   local_path = File.expand_path local_path
    #   filesize = File.size local_path
    #   upld_url = upload_url filesize

    #   ul_key = Crypto.random_key
    #   aes_key = ul_key[0..3]
    #   nonce = ul_key[4..5]
    #   local_file = File.open local_path, 'rb'
    #   file_handle = nil
    #   file_mac = [0, 0, 0, 0]

    #   Utils.show_progress :upload, filesize

    #   Utils.chunks(filesize).each do |chunk_start, chunk_size|
    #     buffer = local_file.read chunk_size

    #     # TODO: should be (chunk_start/0x1000000000) >>> 0, (chunk_start/0x10) >>> 0
    #     nonce = [nonce[0], nonce[1], (chunk_start/0x1000000000) >> 0, (chunk_start/0x10) >> 0]

    #     encrypted_buffer = Crypto::AesCtr.encrypt aes_key, nonce, buffer
    #     chunk_mac = encrypted_buffer[:mac]

    #     file_handle = upload_chunk upld_url, chunk_start, encrypted_buffer[:data]

    #     file_mac = [file_mac[0] ^ chunk_mac[0], file_mac[1] ^ chunk_mac[1],
    #                 file_mac[2] ^ chunk_mac[2], file_mac[3] ^ chunk_mac[3]]
    #     file_mac = Crypto::Aes.encrypt ul_key[0..3], file_mac
    #     Utils.show_progress :upload, filesize, chunk_size
    #   end

    #   attribs = {n: File.basename(local_path)}
    #   encrypt_attribs = Utils.a32_to_base64 Crypto.encrypt_attributes(ul_key[0..3], attribs)

    #   meta_mac = [file_mac[0] ^ file_mac[1], file_mac[2] ^ file_mac[3]]

    #   key = [ul_key[0] ^ ul_key[4], ul_key[1] ^ ul_key[5], ul_key[2] ^ meta_mac[0],
    #          ul_key[3] ^ meta_mac[1], ul_key[4], ul_key[5], meta_mac[0], meta_mac[1]]

    #   encrypted_key = Utils.a32_to_base64 Crypto.encrypt_key(session.master_key, key)
    #   session.request a: 'p', t: parent_node.handle, n: [{h: file_handle, t: 0, a: encrypt_attribs, k: encrypted_key}]

    #   nil
    # ensure
    #   local_file.close if local_file
    # end
  end
end
