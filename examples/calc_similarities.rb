require 'k_means'
require 'bdf'
require 'json'
require 'bitset'
require 'logger'
require 'leveldb'

$logger = Logger.new($stderr)
$db = LevelDB::DB.new 'similarities.db'

class Array
  def sum
    inject(0.0) { |result, el| result + el }
  end

  def mean
    sum / size
  end
end

class CustomCentroid
  attr_accessor :position
  def initialize(position); @position = position; end
  def reposition(nodes, centroid_positions); end
end

def main
  font = Bdf::Font.parse(open('/tmp/efont-unicode-bdf-0.4.2/f24.bdf'))
  chars = font.chars.map do |char|
    {
      :c => [char.code[2..-1].to_i(16)].pack('U'),
      :num_used_pixels => char.to_s(font.bounding_box).count('1'),
      :bitset => Bitset.from_s(char.to_s(font.bounding_box).gsub(/\n/, ''))
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

  # cluster_items = chars.map {|char| [char[:num_used_pixels]] }
  # kmeans = KMeans.new(cluster_items, :custom_centroids => find_initial_centroids(cluster_items))
  # #kmeans = KMeans.new(cluster_items, :centroids => 20)
  # $logger.info kmeans.view.map {|c| c.size}
  # kmeans.view.each_with_index do |cluster, index|
  #   $logger.info index
  #   calc_similarities(cluster, chars).to_json
  # end
end

def find_initial_centroids(items, k = 20)
  items = items.map {|i| i[0] }
  n = items.size
  a = []
  m = 0

  while a.size < k
    a[m] = []
    closest = 999999
    closest_indexes = []

    $logger.info m
    items.each_with_index do |_, index|
      items.each_with_index do |item, i|
        if index != i
          if (distance = (items[index] - item).abs) < closest
            closest_indexes = [index, i]
            closest = distance
          end
        end
      end
    end

    a[m] = [items[closest_indexes[0]], items[closest_indexes[1]]]
    closest_indexes.each {|i| items.slice!(i) }

    while a[m].size < (0.75 * (n / k))
      closest = 999999
      closest_index = nil
      value = a[m].mean
      items.each_with_index do |item, index|
        if (item - value).abs < closest
          closest = item
          closest_index = index
        end
      end

      a[m] << closest
      items.slice!(closest_index)
    end

    m += 1
  end

  a.map do |items|
    CustomCentroid.new([items.mean])
  end
end

def calc_similarities(indexes, chars)
  indexes.each do |index|
    similarities = {}
    char = chars[index]

    indexes.each do |i|
      if chars[i] != char
        similarities[chars[i][:c]] = similarity(char, chars[i])
      end
    end

    puts(
      {
        char[:c] => similarities.sort_by do |k, v|
          -v
        end[0, 20]
      }.to_json
    )
  end
end

def similarity(a, b)
  avg_used = (a[:num_used_pixels] + b[:num_used_pixels]) / 2.0
  avg_empty = (
    (a[:bitset].size - a[:num_used_pixels]) +
    (b[:bitset].size - b[:num_used_pixels])
  ) / 2.0

  coincidence_used = (a[:bitset] & b[:bitset]).cardinality
  coincidence_empty = (~a[:bitset] & ~b[:bitset]).cardinality

  (coincidence_used / (avg_used + 0.001)) * (coincidence_empty / (avg_empty + 0.001))
end

main
