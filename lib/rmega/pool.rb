require 'thread'

class Thread
  # Helper to create a Pool instance.
  def self.pool(max)
    Pool.new(max)
  end

  class Pool
    def initialize(max)
      Thread.abort_on_exception = true
      @mutex = Mutex.new
      @threads = Array.new(max)
    end

    # Gets the first position of the pool in which
    # a thread could be started.
    def available_slot
      @threads.each_with_index do |thread, index|
        return index if thread.nil? or !thread.alive?
      end
      nil
    end

    def synchronize(&block)
      @mutex.synchronize(&block)
    end

    # Returns true if all the threads are finished,
    # false otherwise.
    def done?
      @threads.each { |thread| return false if thread and thread.alive? }
      true
    end

    # Blocking. Waits until all the threads are finished.
    def wait_done
      sleep 0.01 until done?
    end

    # Blocking. Waits until a pool's slot become available and
    # returns that position.
    # TODO: raise an error on wait timeout.
    def wait_available_slot
      while true
        index = available_slot
        return index if index
        sleep 0.01
      end
    end

    # Sends a KILL signal to all the threads.
    def shutdown
      @threads.each { |thread| thread.kill if thread.respond_to?(:kill) }
      @threads.map! { nil }
    end

    # Blocking. Starts a new thread with the given block when a pool's slot
    # become available.
    def defer(&block)
      index = wait_available_slot
      @threads[index].kill if @threads[index].respond_to?(:kill)
      @threads[index] = Thread.new(&block)
    end
  end
end
