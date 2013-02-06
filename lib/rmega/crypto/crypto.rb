module Rmega
  module Crypto
    extend self

    def prepare_key array
      pkey = [0x93C467E3,0x7DB0C7A4,0xD1BE3F81,0x0152CB56]
      1.times do
        0.step(array.length-1, 4) do |j|
          key = [0,0,0,0]
          0.upto(3) do |i|
            if i+j < array.length
              key[i] = array[i+j]
            end
          end
        end
      end
      pkey
    end

  end
end
