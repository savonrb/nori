require "spec_helper"

describe Nori::Parser do
  let(:parser) { Nori::Parser }

  describe ".use" do
    it "should default to REXML" do
      parser.use.should == :rexml
    end

    it "should accept an parser to use"

    it "should raise an ArgumentError in case of an invalid parser" do
      lambda { parser.use = :unknown }.should raise_error(ArgumentError)
    end
  end

  describe ".parsers" do
    it "should return a Hash of parser details" do
      parser.parsers.should == {
        :rexml => { :class => Nori::Parser::REXML, :require => "rexml/document" }
      }
    end

    it "should return a memoized Hash" do
      parser.parsers.should equal(parser.parsers)
    end
  end

  describe ".parse" do
    it "should load the parser to use and parse the given xml" do
      parser.parse("<some>xml</some>").should == { "some" => "xml" }
    end
  end

end
