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
      @bbx = args[:bbx]
    end

    def to_s(bounding_box = nil)
      bounding_box ||= bbx

      x_offset = bbx[2] - bounding_box[2]
      y_offset = bbx[3] - bounding_box[3]

      lines = self.lines.map do |line|
        if x_offset < 0
          line = line.rjust(width, '0')[x_offset.abs .. -1]
        else
          line = line.rjust(width + x_offset, '0')
        end

        line[0, bounding_box[0]]
      end

      if y_offset > 0
        lines = lines + (['0' * lines[0].size] * y_offset)
      else
        y_offset.abs.times do
          lines.pop
        end
      end

      if lines.size > bounding_box[1]
        (lines.size - bounding_box[1]).times do
          lines.shift
        end
      else
        (bounding_box[1] - lines.size).times do
          lines.unshift('0' * lines[0].size)
        end
      end

      lines.join("\n")
    end

    def lines
      @lines ||= bitmaps.map do |bitmap|
        bitmap.to_s(2)
      end
    end

    def width
      @width ||= lines.map(&:size).max
    end
  end
end
