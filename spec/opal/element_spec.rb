require "spec_helper"

describe React::Element do
  context 'existing Element object defined' do
    subject { Element.new.do_stuff }

    # Don't want to step on opal-jquery's Element class, Opal bridged class get defined at the root scope
    it { is_expected.to eq 'nope'}
  end

  it "should be toll-free bridged to React.Element" do
    element = React.create_element('div')
    expect(`React.isValidElement(#{element})`).to eq(true)
  end

  describe "#new" do
    it "should raise error if invoked" do
      expect { React::Element.new }.to raise_error
    end
  end

  describe "#element_type" do
    it "should bridge to `type` of native" do
      element = React.create_element('div')
      expect(element.element_type).to eq("div")
      %x{
        var m = React.createClass({
          render:function(){ return React.createElement('div'); }
        });
        var ele = React.createElement(m);
      }
      expect(`ele`.element_type).to eq(`ele.type`)
    end
  end

  describe "#key" do
    it "should bridge to `key` of native" do
      element = React.create_element('div', key: "1")
      expect(element.key).to eq(`#{element}.key`)
    end

    it "should return nil if key is null" do
      element = React.create_element('div')
      expect(element.key).to be_nil
    end
  end

  describe "#ref" do
    it "should bridge to `ref` of native" do
      element = React.create_element('div', ref: "foo")
      expect(element.ref).to eq(`#{element}.ref`)
    end

    it "should return nil if ref is null" do
      element = React.create_element('div')
      expect(element.ref).to be_nil
    end
  end

  describe "Props.Children" do
    it "should return a Enumerable" do
      ele = React.create_element('div') { [React.create_element('a'), React.create_element('li')] }
      nodes = ele.children.map {|ele| ele.element_type }
      expect(nodes).to eq(["a", "li"])
    end

    it "should return a Enumerator when not providing a block" do
      ele = React.create_element('div') { [React.create_element('a'), React.create_element('li')] }
      nodes = ele.children.each
      expect(nodes).to be_a(Enumerator)
      expect(nodes.size).to eq(2)
    end

    describe "empty" do
      it "should work as Enumerable" do
        ele = React.create_element('div')
        expect(ele.children.count).to eq(0)
        expect(ele.children.none?).to eq(true)
      end
    end

    describe "single child" do
      it "should works as Enumerable" do
        ele = React.create_element('div') { [React.create_element('a')] }
        expect(ele.children.count).to eq(1)
        expect(ele.children.map {|node| node.element_type}).to eq(['a'])
      end
    end

    describe "single child as string" do
      it "should works as Enumerable" do
        ele = React.create_element('div') { "foo" }
        expect(ele.children.count).to eq(1)
        expect(ele.children.map {|node| node}).to eq(['foo'])
      end
    end

    describe "single child as number" do
      it "should works as Enumerable" do
        ele = React.create_element('div') { 123 }
        expect(ele.children.count).to eq(1)
        expect(ele.children.map {|node| node}).to eq([123])
      end
    end
  end
end
