module Bdf
  class Font
    attr_reader :chars, :bounding_box

    class << self
      def parse(io)
        chars = []
        bounding_box = []

        while line = io.gets
          case line
          when /^STARTCHAR/
            io.seek(- line.size, IO::SEEK_CUR)
            chars << Char.parse(io)
          when /^FONTBOUNDINGBOX ([-\d]+) ([-\d]+) ([-\d]+) ([-\d]+)/
            bounding_box = [$1, $2, $3, $4].map(&:to_i)
          end
        end

        new(
          :chars => chars,
          :bounding_box => bounding_box
        )
      end
    end

    def initialize(args)
      @chars = args[:chars]
      @bounding_box = args[:bounding_box]
    end
  end
end
