require "spec_helper"

describe Hash do

  describe "#to_params" do

    {
      { "foo" => "bar", "baz" => "bat" } => "foo=bar&baz=bat",
      { "foo" => [ "bar", "baz" ] } => "foo[]=bar&foo[]=baz",
      { "foo" => [ {"bar" => "1"}, {"bar" => 2} ] } => "foo[][bar]=1&foo[][bar]=2",
      { "foo" => { "bar" => [ {"baz" => 1}, {"baz" => "2"}  ] } } => "foo[bar][][baz]=1&foo[bar][][baz]=2",
      { "foo" => {"1" => "bar", "2" => "baz"} } => "foo[1]=bar&foo[2]=baz"
    }.each do |hash, params|
      it "should covert hash: #{hash.inspect} to params: #{params.inspect}" do
        expect(hash.to_params.split('&').sort).to eq(params.split('&').sort)
      end
    end

    it "should not leave a trailing &" do
      expect({
        :name => 'Bob',
        :address => {
          :street => '111 Ruby Ave.',
          :city => 'Ruby Central',
          :phones => ['111-111-1111', '222-222-2222']
        }
      }.to_params).not_to match(/&$/)
    end

    it "should URL encode unsafe characters" do
      expect({:q => "?&\" +"}.to_params).to eq("q=%3F%26%22%20%2B")
    end
  end

  describe "#normalize_param" do
    it "should have specs"
  end

  describe "#to_xml_attributes" do

    it "should turn the hash into xml attributes" do
      attrs = { :one => "ONE", "two" => "TWO" }.to_xml_attributes
      expect(attrs).to match(/one="ONE"/m)
      expect(attrs).to match(/two="TWO"/m)
    end

    it "should preserve _ in hash keys" do
      attrs = {
        :some_long_attribute => "with short value",
        :crash               => :burn,
        :merb                => "uses extlib"
      }.to_xml_attributes

      expect(attrs).to match(/some_long_attribute="with short value"/)
      expect(attrs).to match(/merb="uses extlib"/)
      expect(attrs).to match(/crash="burn"/)
    end
  end

end
