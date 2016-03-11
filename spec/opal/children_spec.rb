require "spec_helper"

describe React::Children do
  describe '#children' do
    it "should return a Enumerable" do
      ele = React.create_element('div') { [React.create_element('a'), React.create_element('li')] }
      nodes = ele.children.map { |ele| ele.element_type }
      expect(nodes).to eq(["a", "li"])
    end

    it "should return a Enumerator when not providing a block" do
      ele = React.create_element('div') { [React.create_element('a'), React.create_element('li')] }
      nodes = ele.children.each
      expect(nodes).to be_a(Enumerator)
      expect(nodes.size).to eq(2)
    end

    context "empty" do
      it "should work as Enumerable" do
        ele = React.create_element('div')
        expect(ele.children.count).to eq(0)
        expect(ele.children.none?).to eq(true)
      end
    end

    context "single child" do
      it "should works as Enumerable" do
        ele = React.create_element('div') { [React.create_element('a')] }
        expect(ele.children.count).to eq(1)
        expect(ele.children.map { |node| node.element_type }).to eq(['a'])
      end
    end

    context "single child as string" do
      it "should works as Enumerable" do
        ele = React.create_element('div') { "foo" }
        expect(ele.children.count).to eq(1)
        expect(ele.children.map { |node| node }).to eq(['foo'])
      end
    end

    context "single child as number" do
      it "should works as Enumerable" do
        ele = React.create_element('div') { 123 }
        expect(ele.children.count).to eq(1)
        expect(ele.children.map { |node| node }).to eq([123])
      end
    end
  end
end
