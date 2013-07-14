module Rmega
  class Progress

    def initialize(params)
      @filesize = params[:filesize]
      @verb = params[:verb].capitalize
      @progress = 0

      render
    end

    def render
      percentage = (100.0 * @progress / @filesize).round(2)
      message = "#{@verb} in progress #{format_bytes(@progress)} of #{format_bytes(@filesize)} (#{percentage}%)"
      rtrn = "\n" if @filesize == @progress

      print "\r#{' '*(message.size + 15)}\r#{message}#{rtrn}"
    end

    def increment(bytes)
      @progress += bytes

      render
    end

    def format_bytes(bytes, round = 2)
      units = ['bytes', 'kb', 'MB', 'GB', 'TB', 'PB']
      e = (bytes == 0 ? 0 : Math.log(bytes)) / Math.log(1024)
      value = bytes.to_f / (1024 ** e.floor)

      "#{value.round(round)}#{units[e]}"
    end
  end
end
