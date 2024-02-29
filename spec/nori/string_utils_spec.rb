require "spec_helper"

describe Nori::StringUtils do

  describe ".snakecase" do
    it "lowercases one word CamelCase" do
      expect(Nori::StringUtils.snakecase("Merb")).to eq("merb")
    end

    it "makes one underscore snakecase two word CamelCase" do
      expect(Nori::StringUtils.snakecase("MerbCore")).to eq("merb_core")
    end

    it "handles CamelCase with more than 2 words" do
      expect(Nori::StringUtils.snakecase("SoYouWantContributeToMerbCore")).to eq("so_you_want_contribute_to_merb_core")
    end

    it "handles CamelCase with more than 2 capital letter in a row" do
      expect(Nori::StringUtils.snakecase("CNN")).to eq("cnn")
      expect(Nori::StringUtils.snakecase("CNNNews")).to eq("cnn_news")
      expect(Nori::StringUtils.snakecase("HeadlineCNNNews")).to eq("headline_cnn_news")
    end

    it "does NOT change one word lowercase" do
      expect(Nori::StringUtils.snakecase("merb")).to eq("merb")
    end

    it "leaves snake_case as is" do
      expect(Nori::StringUtils.snakecase("merb_core")).to eq("merb_core")
    end
  end

end
