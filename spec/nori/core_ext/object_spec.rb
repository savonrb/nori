require "spec_helper"

describe Object do

  describe "#blank?" do
    [nil, false, [], {}].each do |object|
      it "should return true for: #{object.inspect}" do
        expect(object.blank?).to be_truthy
      end
    end

    [true, [nil], 1, "string", { :key => "value" }].each do |object|
      it "should return false for: #{object.inspect}" do
        expect(object.blank?).to be_falsey
      end
    end
  end

end
