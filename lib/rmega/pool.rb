require 'thread'

module Rmega
  class Pool
    MAX = 4

    def initialize(max = MAX)
      Thread.abort_on_exception = true

      @mutex = Mutex.new
      @resource = ConditionVariable.new
      @max = max || MAX

      @running = []
      @queue = []
    end

    def defer(&block)
      synchronize { @queue << block }
      process_queue
    end

    def wait_done
      synchronize { @resource.wait(@mutex) }
    end

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

    def thread_proc(&block)
      Proc.new do
        block.call
        @running.reject! { |thread| thread == Thread.current }
        process_queue
        signal_done if done?
      end
    end
  end
end
