module Bdf
  class Char
    attr_reader :code, :bitmaps, :bbx

    class << self
      def parse(io)
        code = nil
        bbx = nil
        bitmap = false
        bitmaps = []

        while line = io.gets
          case line
          when /^STARTCHAR (.+)/
            code = $1
          when /^BITMAP/
            bitmap = true
          when /^BBX ([-\d]+) ([-\d]+) ([-\d]+) ([-\d]+)/
            bbx = [$1, $2, $3, $4].map(&:to_i)
          when /^ENDCHAR/
            break
          else
            if bitmap
              bitmaps << line.chomp.to_i(16)
            end
          end
        end

        new(
          :code => code,
          :bitmaps => bitmaps,
          :bbx => bbx
        )
      end
    end

    def initialize(args)
      @code = args[:code]
      @bitmaps = args[:bitmaps]
    end
  end
end
