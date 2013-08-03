require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Bdf
  describe Char do
    let(:filename) { fixture_path('sample.bdf') }
    subject(:font) { Font.parse(open(filename)).chars[100] }

    describe '#to_s' do
      context 'without bounding box' do
        it do
          font.to_s.should eql(<<EOM.chomp)
00000
00000
00000
10001
01110
01010
01110
10001
00000
00000
EOM
        end
      end

      context 'with bounding box' do
        it do
          font.to_s([5, 10, 0, -2]).should eql(<<EOM.chomp)
00000
00000
00000
10001
01110
01010
01110
10001
00000
00000
EOM
        end

        it do
          font.to_s([5, 10, 0, -3]).should eql(<<EOM.chomp)
00000
00000
10001
01110
01010
01110
10001
00000
00000
00000
EOM
        end

        it do
          font.to_s([5, 10, 0, -1]).should eql(<<EOM.chomp)
00000
00000
00000
00000
10001
01110
01010
01110
10001
00000
EOM
        end

        it do
          font.to_s([5, 10, -1, -2]).should eql(<<EOM.chomp)
00000
00000
00000
01000
00111
00101
00111
01000
00000
00000
EOM
        end

        it do
          font.to_s([5, 10, 1, -2]).should eql(<<EOM.chomp)
00000
00000
00000
00010
11100
10100
11100
00010
00000
00000
EOM
        end

        it do
          font.to_s([6, 10, 0, -2]).should eql(<<EOM.chomp)
000000
000000
000000
100010
011100
010100
011100
100010
000000
000000
EOM
        end

        it do
          font.to_s([4, 10, 0, -2]).should eql(<<EOM.chomp)
0000
0000
0000
1000
0111
0101
0111
1000
0000
0000
EOM
        end

        it do
          font.to_s([5, 11, 0, -2]).should eql(<<EOM.chomp)
00000
00000
00000
00000
10001
01110
01010
01110
10001
00000
00000
EOM
        end

        it do
          font.to_s([5, 9, 0, -2]).should eql(<<EOM.chomp)
00000
00000
10001
01110
01010
01110
10001
00000
00000
EOM
        end
      end
    end
  end
end
