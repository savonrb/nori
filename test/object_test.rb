require 'test_helper'

class CrackTest < Test::Unit::TestCase
  context "blank?" do
    should "be true for blank objects" do
      [nil, false, [], {}].each { |object| object.should be_blank }
    end

    should "be false for non-blank objects" do
      [true, [nil], 1, "string", { :key => "value" }].each { |object| object.should_not be_blank }
    end
  end
end