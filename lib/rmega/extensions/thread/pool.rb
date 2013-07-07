require 'thread'

class Thread::BlockingPool
  def initialize(max)
    Thread.abort_on_exception = true
    @mutex = Mutex.new
    @threads = Array.new(max)
  end

  def first_available_slot
    @threads.each_with_index do |thread, index|
      return index if thread.nil? or !thread.alive?
    end
    -1
  end

  def synchronize(&block)
    @mutex.synchronize(&block)
  end

  def done?
    @threads.each { |thread| return false if thread and thread.alive? }
    true
  end

  def shutdown
    @threads.each { |thread| thread.kill if thread }
  end

  def defer(&block)
    # Wait until a sloot a slot became available
    index = -1

    while true
      sleep 0.001
      index = first_available_slot
      break if index >= 0
    end

    # puts "Adding a thread on index #{index}"
    @threads[index] = Thread.new(&block)
  end
end

class Thread
  # Helper to create a pool
  def self.blocking_pool(max)
    Thread::BlockingPool.new(max)
  end
end
