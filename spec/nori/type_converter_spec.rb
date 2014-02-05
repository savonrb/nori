require 'spec_helper'

describe Nori::TypeConverter do
  describe "#detect_namespace_prefixes!" do
    let(:namespaces) { {} }
    let(:type_converter) { Nori::TypeConverter.new.tap {|c| c.detect_namespace_prefixes!(xml, namespaces)} }

    describe 'namespace prefixes' do
      context 'when document is empty' do
        let(:xml) { '' }
        subject { type_converter }
        its(:attribute_prefix) { should be_nil }
        its(:type_prefix) { should be_nil }
      end

      context 'when document has no XML header' do
        let(:xml) { '<foo>1</foo>' }
        subject { type_converter }
        its(:attribute_prefix) { should be_nil }
        its(:type_prefix) { should be_nil }
      end

      context 'when no namespaces are declared' do
        let(:xml) {
          <<-EOT
            <?xml version="1.0" encoding="UTF-8"?>
            <Envelope>
              <Body>
              </Body>
            </Envelope>
          EOT
        }
        subject { type_converter }
        its(:attribute_prefix) { should be_nil }
        its(:type_prefix) { should be_nil }
      end

      context 'when XMLSchema namespace is declared' do
        let(:xml) {
          <<-EOT
            <?xml version="1.0" encoding="UTF-8"?>
            <Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
              <Body>
              </Body>
            </Envelope>
          EOT
        }
        subject { type_converter }
        its(:attribute_prefix) { should eq('xsi') }
        its(:type_prefix) { should eq('xsd') }
      end

      context 'when custom namespace is declared' do
        let(:namespaces) {
          { :attribute_namespace => 'http://company.com/foo', :type_namespace => 'http://company.com/bar' }
        }
        let(:xml) {
          <<-EOT
            <?xml version="1.0" encoding="UTF-8"?>
            <Envelope xmlns:foo="http://company.com/foo" xmlns:bar="http://company.com/bar" >
              <Body>
              </Body>
            </Envelope>
          EOT
        }
        subject { type_converter }
        its(:attribute_prefix) { should eq('foo') }
        its(:type_prefix) { should eq('bar') }
      end
    end
  end

  describe ".namespace_prefix_matches?" do
    subject { Nori::TypeConverter }

    specify { subject.namespace_prefix_matches?('foo', 'foo:bar').should be_true }
    specify { subject.namespace_prefix_matches?('', 'bar').should be_true }
    specify { subject.namespace_prefix_matches?(nil, 'bar').should be_true }
    specify { subject.namespace_prefix_matches?('foo', 'foo:bar').should be_true }

    specify { subject.namespace_prefix_matches?('foo', ':bar').should be_false }
    specify { subject.namespace_prefix_matches?('foo', 'bar').should be_false }
    specify { subject.namespace_prefix_matches?(nil, ':bar').should be_false }
  end
end

### custom conversions

class ToIntRange
  def self.convert(value)
    return nil if (value.nil? || value.length == 0)
    range = value.split('..')
    return range.first.to_i..range.last.to_i
  end
end

describe "type conversions" do
  describe ToIntRange do
    let(:xml) {
      <<-EOT
          <?xml version="1.0" encoding="UTF-8"?>
            <officeHours type="interval">8..17</officeHours>
      EOT
    }

    it "converts node value to Range of integers" do
      type_converter = Nori::TypeConverter.new('intRange|integerRange|interval' => ToIntRange)
      nori = Nori.new(:type_converter => type_converter)
      parsed = nori.parse(xml)
      parsed.should eq("officeHours" => 8..17)
    end
  end
end
