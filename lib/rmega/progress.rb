module Rmega
  class Progress

    def initialize(params)
      @total = params[:total]
      @caption = params[:caption]
      @bytes = 0
      @start_time = Time.now

      show
    end

    def show
      percentage = (100.0 * @bytes / @total).round(2)

      message = "[#{@caption}] #{humanize(@bytes)} of #{humanize(@total)}"

      if ended?
        message << ". Completed in #{elapsed_time} sec.\n"
      else
        message << " (#{percentage}%)"
      end

      blank_line = ' ' * (message.size + 15)
      print "\r#{blank_line}\r#{message}"
    end

    def elapsed_time
      (Time.now - @start_time).round(2)
    end

    def ended?
      @total == @bytes
    end

    def increment(bytes)
      @bytes += bytes
      show
    end

    def humanize(bytes, round = 2)
      units = ['bytes', 'kb', 'MB', 'GB', 'TB', 'PB']
      e = (bytes == 0 ? 0 : Math.log(bytes)) / Math.log(1024)
      value = bytes.to_f / (1024 ** e.floor)

      "#{value.round(round)} #{units[e]}"
    end
  end
end
