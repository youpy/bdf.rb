require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Bdf
  describe Font do
    describe '.parse' do
      subject { Font.parse(open(filename)) }
      let(:filename) { fixture_path('sample.bdf') }

      its(:chars) { should have(2179).items }
      its(:bounding_box) { should eql([5, 10, 0, -2]) }
    end
  end
end
