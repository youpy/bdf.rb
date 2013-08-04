require 'bdf'
require 'json'
require 'bitset'
require 'logger'
require 'leveldb'

$logger = Logger.new($stderr)
$db = LevelDB::DB.new 'similarities.db'

def main
  font = Bdf::Font.parse(open('/tmp/efont-unicode-bdf-0.4.2/f24_b.bdf'))
  chars = font.chars.map do |char|
    bitset = Bitset.from_s(char.to_s(font.bounding_box).gsub(/\n/, ''))
    {
      :c => [char.code[2..-1].to_i(16)].pack('U'),
      :bitset => bitset,
      :num_flagged => bitset.cardinality,
      :num_unflagged => bitset.size - bitset.cardinality
    }
  end

  chars.each_with_index do |a, index|
    $logger.info index
    x = []

    chars.each_with_index do |b, i|
      x << [b[:c], similarity(a, b)] if a != b
    end

    $db.put(a[:c],
      x.sort_by do |i, similarity|
        similarity
      end.reverse[0, 20].to_json
    )
  end
end

def similarity(a, b)
  avg_flagged = (a[:num_flagged] + b[:num_flagged]) / 2.0
  avg_unflagged = (a[:num_unflagged] + b[:num_unflagged]) / 2.0

  coincidence_flagged = (a[:bitset] & b[:bitset]).cardinality
  coincidence_unflagged = (~a[:bitset] & ~b[:bitset]).cardinality

  (coincidence_flagged / (avg_flagged + 0.001)) * (coincidence_unflagged / (avg_unflagged + 0.001))
end

main
