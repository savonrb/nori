require "spec_helper"

describe Nori::Parser do
  let(:parser) { Nori::Parser }

  describe "::PARSERS" do
    it "should return a Hash of parser details" do
      Nori::Parser::PARSERS.should == { :rexml => "REXML", :nokogiri => "Nokogiri" }
    end
  end

  describe ".use" do
    it "should default to REXML" do
      parser.use.should == :rexml
    end

    it "should accept a parser to use" do
      parser.use = :nokogiri
      parser.use.should == :nokogiri

      # reset to default
      parser.use = Nori::Parser::DEFAULT
    end

    it "should raise an ArgumentError in case of an invalid parser" do
      lambda { parser.use = :unknown }.should raise_error(ArgumentError)
    end
  end

  describe ".parse" do
    it "should load the parser to use and parse the given xml" do
      parser.parse("<some>xml</some>").should == { "some" => "xml" }
    end
  end

end
