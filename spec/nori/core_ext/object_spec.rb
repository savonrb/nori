require "spec_helper"

describe Object do

  describe "#blank?" do
    it "should return true for blank objects" do
      [nil, false, [], {}].each { |object| object.should be_blank }
    end

    it "should return false for non-blank objects" do
      [true, [nil], 1, "string", { :key => "value" }].each { |object| object.should_not be_blank }
    end
  end

end
