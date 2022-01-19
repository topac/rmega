module Rmega
  class Pool
    include Options
    
    def initialize
      threads_raises_exceptions

      @queue = Queue.new
      @queue_closed = false
      @threads = []
      @cv = ConditionVariable.new
      @working_threads = 0
      
      options.thread_pool_size.times do
        @threads << Thread.new do
          while proc = @queue.pop
            mutex.synchronize do
              @working_threads += 1
            end
            
            proc.call

            mutex.synchronize do
              @working_threads -= 1
              
              if @queue_closed and @queue.empty? and @working_threads == 0
                @cv.signal
              end
            end
          end
        end
      end
    end

    def mutex
      @mutex ||= Mutex.new
    end

    def threads_raises_exceptions
      Thread.abort_on_exception = true
    end

    def process(&block)
      @queue << block
    end
    
    def wait_done
      @queue.close if @queue.respond_to?(:close)
      @queue_closed = true

      mutex.synchronize do
        @cv.wait(mutex)
      end

      @threads.each(&:kill)
    end
  end
end
