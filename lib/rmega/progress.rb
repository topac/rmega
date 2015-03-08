module Rmega
  class Progress
    include Options

    def initialize(total, options = {})
      @total = total
      @caption = options[:caption]
      @bytes = 0
      @real_bytes = 0
      @mutex = Mutex.new
      @start_time = Time.now

      show
    end

    def show?
      options.show_progress
    end

    def show
      return unless show?

      message = @caption ? "[#{@caption}] " : ""
      message << "#{humanize_bytes(@bytes)} of #{humanize_bytes(@total)}"

      if ended?
        message << ". Completed in #{elapsed_time} sec.\n"
      else
        message << ", #{percentage}% @ #{humanize_bytes(speed, 1)}/s, #{options.thread_pool_size} threads"
      end

      print_r(message)
    end

    def stty_size_columns
      return @stty_size_columns unless @stty_size_columns.nil?
      @stty_size_columns ||= (`stty size`.split[1].to_i rescue false)
    end

    def columns
      stty_size_columns || 80
    end

    def print_r(message)
      if message.size + 10 > columns
        puts message
      else
        blank_line = ' ' * (message.size + 10)
        print "\r#{blank_line}\r#{message}"
      end
    end

    def percentage
      (100.0 * @bytes / @total).round(2)
    end

    def speed
      @real_bytes.to_f / (Time.now - @start_time).to_f
    end

    def elapsed_time
      (Time.now - @start_time).round(2)
    end

    def ended?
      @total == @bytes
    end

    def increment(bytes, options = {})
      @mutex.synchronize do
        @bytes += bytes
        @real_bytes += bytes unless options[:real] == false
        show
      end
    end

    def humanize_bytes(*args)
      self.class.humanize_bytes(*args)
    end

    def self.humanize_bytes(bytes, round = 2)
      units = ['bytes', 'kb', 'MB', 'GB', 'TB', 'PB']
      e = (bytes == 0 ? 0 : Math.log(bytes)) / Math.log(1024)
      value = bytes.to_f / (1024 ** e.floor)

      return "#{value.round(round)} #{units[e]}"
    end
  end
end
