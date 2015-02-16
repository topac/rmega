module Rmega
  class Pool
    include Options

    def initialize
      threads_raises_exceptions

      @mutex = Mutex.new
      @resource = ConditionVariable.new
      @max = options.thread_pool_size

      @running = []
      @queue = []
    end

    def threads_raises_exceptions
      Thread.abort_on_exception = true
    end

    def defer(&block)
      synchronize { @queue << block }
      process_queue
    end

    alias :process :defer

    def wait_done
      return if done?
      synchronize { @resource.wait(@mutex) }
    end

    alias :shutdown :wait_done

    private

    def synchronize(&block)
      @mutex.synchronize(&block)
    end

    def process_queue
      synchronize do
        if @running.size < @max
          proc = @queue.shift
          @running << Thread.new(&thread_proc(&proc)) if proc
        end
      end
    end

    def done?
      synchronize { @queue.empty? && @running.empty? }
    end

    def signal_done
      synchronize { @resource.signal }
    end

    def thread_terminated
      synchronize { @running.reject! { |thread| thread == Thread.current } }
    end

    def thread_proc(&block)
      Proc.new do
        block.call
        thread_terminated
        process_queue
        signal_done if done?
      end
    end
  end
end
